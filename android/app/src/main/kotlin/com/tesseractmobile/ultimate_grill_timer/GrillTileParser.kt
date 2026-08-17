package com.tesseractmobile.ultimate_grill_timer

import org.json.JSONObject
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId

/**
 * One running or paused timer, decoded from the Flutter save state
 * (SharedPreferences key "flutter.grillItems", written by SaveGrillItemsUseCase).
 */
data class TileTimer(
    val image: String,
    val rawStartMs: Long,
    /** startTime shifted by pauseDuration, so elapsed = now - effectiveStartMs. */
    val effectiveStartMs: Long,
    val isPaused: Boolean,
    val pausedElapsedSeconds: Long,
)

object GrillTileParser {

    fun parse(json: String, zone: ZoneId = ZoneId.systemDefault()): List<TileTimer> {
        val items = JSONObject(json).getJSONArray("grillItems")
        return (0 until items.length()).mapNotNull { i ->
            runCatching {
                val item = items.getJSONObject(i)
                val timer = item.getJSONObject("timer")
                val start = parseDartDateTime(timer.getString("startTime"), zone)
                val pauseMs = timer.optLong("pauseDuration", 0) * 1000
                val isPaused = timer.optBoolean("isPaused", false)
                val pauseStart =
                    if (timer.isNull("pauseStartTime")) null
                    else parseDartDateTime(timer.getString("pauseStartTime"), zone)
                // Mirrors GrillTimer.elapsedTime: pauseStartTime - startTime - pauseDuration
                val pausedElapsedSeconds =
                    if (isPaused && pauseStart != null) {
                        (pauseStart.toEpochMilli() - start.toEpochMilli() - pauseMs) / 1000
                    } else 0
                TileTimer(
                    image = item.optString("image", ""),
                    rawStartMs = start.toEpochMilli(),
                    effectiveStartMs = start.toEpochMilli() + pauseMs,
                    isPaused = isPaused,
                    pausedElapsedSeconds = pausedElapsedSeconds.coerceAtLeast(0),
                )
            }.getOrNull()
        }.sortedBy { it.rawStartMs }
    }

    // Dart DateTime.toIso8601String(): local time without zone ("2026-08-09T10:00:00.123456"),
    // or with trailing Z when UTC.
    private fun parseDartDateTime(s: String, zone: ZoneId): Instant =
        if (s.endsWith("Z")) Instant.parse(s) else LocalDateTime.parse(s).atZone(zone).toInstant()
}
