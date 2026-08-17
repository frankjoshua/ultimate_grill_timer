package com.tesseractmobile.ultimate_grill_timer

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.concurrent.futures.CallbackToFutureAdapter
import androidx.wear.protolayout.ActionBuilders
import androidx.wear.protolayout.ColorBuilders.argb
import androidx.wear.protolayout.DimensionBuilders.dp
import androidx.wear.protolayout.DimensionBuilders.sp
import androidx.wear.protolayout.LayoutElementBuilders
import androidx.wear.protolayout.ModifiersBuilders
import androidx.wear.protolayout.ResourceBuilders
import androidx.wear.protolayout.TimelineBuilders
import androidx.wear.protolayout.TypeBuilders
import androidx.wear.protolayout.expression.DynamicBuilders
import androidx.wear.tiles.RequestBuilders
import androidx.wear.tiles.TileBuilders
import androidx.wear.tiles.TileService
import com.google.common.util.concurrent.ListenableFuture
import java.nio.ByteBuffer
import java.time.Instant

/**
 * Wear OS tile: running timers (food icon + elapsed time) and an add button
 * that opens the app, whose bottom row is the food picker.
 *
 * Reads the same SharedPreferences state the Flutter app saves on every change,
 * so it needs no channel to the Dart side. Running rows tick every second via
 * ProtoLayout dynamic expressions (platform clock), no polling.
 */
@RequiresApi(Build.VERSION_CODES.O)
class GrillTileService : TileService() {

    override fun onTileRequest(
        requestParams: RequestBuilders.TileRequest
    ): ListenableFuture<TileBuilders.Tile> =
        CallbackToFutureAdapter.getFuture { completer ->
            val timers = readTimers()
            completer.set(
                TileBuilders.Tile.Builder()
                    .setResourcesVersion(resourcesVersion(timers))
                    .setTileTimeline(TimelineBuilders.Timeline.fromLayoutElement(layout(timers)))
                    .build()
            )
            "onTileRequest"
        }

    override fun onTileResourcesRequest(
        requestParams: RequestBuilders.ResourcesRequest
    ): ListenableFuture<ResourceBuilders.Resources> =
        CallbackToFutureAdapter.getFuture { completer ->
            val builder = ResourceBuilders.Resources.Builder().setVersion(requestParams.version)
            readTimers().take(MAX_ROWS * 2).map { it.image }.distinct().forEach { path ->
                runCatching { builder.addIdToImageMapping(resourceId(path), inlineImage(path)) }
            }
            completer.set(builder.build())
            "onTileResourcesRequest"
        }

    private fun readTimers(): List<TileTimer> {
        val json = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            .getString("flutter.grillItems", null) ?: return emptyList()
        return runCatching { GrillTileParser.parse(json) }.getOrDefault(emptyList())
    }

    private fun resourcesVersion(timers: List<TileTimer>): String =
        timers.take(MAX_ROWS * 2).map { it.image }.distinct().hashCode().toString()

    // --- layout ---

    private fun layout(timers: List<TileTimer>): LayoutElementBuilders.LayoutElement {
        // Tiles cannot scroll (no scroll container in ProtoLayout); tapping the
        // tile opens the app, which has the full scrolling list. No timers ->
        // the whole tile is a "Tap to add" that opens the picker.
        val column = LayoutElementBuilders.Column.Builder()
            .setHorizontalAlignment(LayoutElementBuilders.HORIZONTAL_ALIGN_CENTER)
        when {
            timers.isEmpty() -> column.addContent(
                LayoutElementBuilders.Text.Builder()
                    .setText("Tap to add")
                    .setFontStyle(
                        LayoutElementBuilders.FontStyle.Builder()
                            .setSize(sp(20f))
                            .setColor(argb(WHITE))
                            .build()
                    )
                    .build()
            )
            timers.size <= MAX_ROWS -> timers.forEach { column.addContent(timerRow(it)) }
            else -> {
                // Two columns, left column first: row i pairs item i with item i+half.
                val shown = timers.take(MAX_ROWS * 2)
                val half = (shown.size + 1) / 2
                for (i in 0 until half) {
                    val pair = LayoutElementBuilders.Row.Builder()
                        .setVerticalAlignment(LayoutElementBuilders.VERTICAL_ALIGN_CENTER)
                        .addContent(timerRow(shown[i]))
                    if (i + half < shown.size) {
                        pair.addContent(
                            LayoutElementBuilders.Spacer.Builder().setWidth(dp(14f)).build()
                        )
                        pair.addContent(timerRow(shown[i + half]))
                    }
                    column.addContent(pair.build())
                }
            }
        }
        return LayoutElementBuilders.Box.Builder()
            .setHorizontalAlignment(LayoutElementBuilders.HORIZONTAL_ALIGN_CENTER)
            .setVerticalAlignment(LayoutElementBuilders.VERTICAL_ALIGN_CENTER)
            .setModifiers(
                ModifiersBuilders.Modifiers.Builder()
                    .setClickable(
                        ModifiersBuilders.Clickable.Builder()
                            .setId(if (timers.isEmpty()) "add" else "open")
                            .setOnClick(if (timers.isEmpty()) launchAdd() else launchApp())
                            .build()
                    )
                    .build()
            )
            .addContent(column.build())
            .build()
    }

    private fun launchApp(): ActionBuilders.LaunchAction =
        ActionBuilders.LaunchAction.Builder()
            .setAndroidActivity(
                ActionBuilders.AndroidActivity.Builder()
                    .setPackageName(packageName)
                    .setClassName("$packageName.MainActivity")
                    .build()
            )
            .build()

    private fun launchAdd(): ActionBuilders.LaunchAction =
        ActionBuilders.LaunchAction.Builder()
            .setAndroidActivity(
                ActionBuilders.AndroidActivity.Builder()
                    .setPackageName(packageName)
                    .setClassName("$packageName.MainActivity")
                    .addKeyToExtraMapping(
                        "mode",
                        ActionBuilders.AndroidStringExtra.Builder().setValue("add").build()
                    )
                    .build()
            )
            .build()

    private fun timerRow(t: TileTimer): LayoutElementBuilders.LayoutElement =
        LayoutElementBuilders.Row.Builder()
            .setVerticalAlignment(LayoutElementBuilders.VERTICAL_ALIGN_CENTER)
            .addContent(
                LayoutElementBuilders.Image.Builder()
                    .setResourceId(resourceId(t.image))
                    .setWidth(dp(19f))
                    .setHeight(dp(19f))
                    .build()
            )
            .addContent(
                LayoutElementBuilders.Spacer.Builder().setWidth(dp(8f)).build()
            )
            .addContent(timeText(t))
            .build()

    private fun timeText(t: TileTimer): LayoutElementBuilders.LayoutElement {
        val nowElapsedSeconds =
            ((System.currentTimeMillis() - t.effectiveStartMs) / 1000).coerceAtLeast(0)
        // H:MM:SS at an hour and beyond, MM:SS below — matches GrillTimer.getFormattedElapsedTime.
        // The format is chosen at render time; a row crossing the hour mark keeps
        // counting minutes until the next tile refresh restructures it.
        val showHours = t.isPaused && t.pausedElapsedSeconds >= 3600 ||
            !t.isPaused && nowElapsedSeconds >= 3600
        val font = LayoutElementBuilders.FontStyle.Builder()
            .setSize(sp(if (showHours) 18f else 22f))
            .setColor(argb(if (t.isPaused) PAUSED_GRAY else WHITE))
            .build()
        val text = LayoutElementBuilders.Text.Builder().setFontStyle(font)
        if (t.isPaused) {
            text.setText(formatElapsed(t.pausedElapsedSeconds))
        } else {
            val elapsed = DynamicBuilders.DynamicInstant
                .withSecondsPrecision(Instant.ofEpochMilli(t.effectiveStartMs))
                .durationUntil(DynamicBuilders.DynamicInstant.platformTimeWithSecondsPrecision())
            val twoDigits = DynamicBuilders.DynamicInt32.IntFormatter.Builder()
                .setMinIntegerDigits(2)
                .setGroupingUsed(false)
                .build()
            val noPad = DynamicBuilders.DynamicInt32.IntFormatter.Builder()
                .setMinIntegerDigits(1)
                .setGroupingUsed(false)
                .build()
            val colon = DynamicBuilders.DynamicString.constant(":")
            val ticking = if (showHours) {
                elapsed.toIntHours().format(noPad)
                    .concat(colon)
                    .concat(elapsed.minutesPart.format(twoDigits))
                    .concat(colon)
                    .concat(elapsed.secondsPart.format(twoDigits))
            } else {
                elapsed.toIntMinutes().format(noPad)
                    .concat(colon)
                    .concat(elapsed.secondsPart.format(twoDigits))
            }
            // Static value doubles as the fallback on renderers without dynamic expressions.
            text.setText(
                TypeBuilders.StringProp.Builder(formatElapsed(nowElapsedSeconds))
                    .setDynamicValue(ticking)
                    .build()
            )
            text.setLayoutConstraintsForDynamicText(
                TypeBuilders.StringLayoutConstraint.Builder(if (showHours) "000:00:00" else "00:00")
                    .build()
            )
        }
        return text.build()
    }

    // --- resources ---

    private fun resourceId(assetPath: String): String =
        "img_" + assetPath.substringAfterLast('/').substringBefore('.').replace('-', '_')

    // Flutter bundles app assets in the APK under flutter_assets/. Tiles want raw RGB_565
    // pixels for inline images; drawing onto a black bitmap flattens the PNG transparency
    // to match the black tile background.
    private fun inlineImage(assetPath: String): ResourceBuilders.ImageResource {
        val src = assets.open("flutter_assets/$assetPath").use(BitmapFactory::decodeStream)
        val bmp = Bitmap.createBitmap(ICON_PX, ICON_PX, Bitmap.Config.RGB_565)
        val paint = Paint().apply { isFilterBitmap = true }
        Canvas(bmp).drawBitmap(src, null, Rect(0, 0, ICON_PX, ICON_PX), paint)
        src.recycle()
        val buffer = ByteBuffer.allocate(bmp.byteCount)
        bmp.copyPixelsToBuffer(buffer)
        return ResourceBuilders.ImageResource.Builder()
            .setInlineResource(
                ResourceBuilders.InlineImageResource.Builder()
                    .setData(buffer.array())
                    .setWidthPx(ICON_PX)
                    .setHeightPx(ICON_PX)
                    .setFormat(ResourceBuilders.IMAGE_FORMAT_RGB_565)
                    .build()
            )
            .build()
    }

    private fun formatElapsed(totalSeconds: Long): String {
        val clamped = totalSeconds.coerceAtLeast(0)
        val hours = clamped / 3600
        return if (hours > 0) {
            "%d:%02d:%02d".format(hours, clamped / 60 % 60, clamped % 60)
        } else {
            "%d:%02d".format(clamped / 60, clamped % 60)
        }
    }

    companion object {
        // ponytail: fixed row cap (tiles cannot scroll); tap the list for the full app list
        private const val MAX_ROWS = 7
        private const val ICON_PX = 96
        private const val WHITE = 0xFFFFFFFF.toInt()
        private const val PAUSED_GRAY = 0xFF9E9E9E.toInt()
        private const val BUTTON_GRAY = 0xFF3C3C3C.toInt()
    }
}
