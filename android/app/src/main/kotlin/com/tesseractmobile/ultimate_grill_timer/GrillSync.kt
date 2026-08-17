package com.tesseractmobile.ultimate_grill_timer

import android.content.Context
import android.os.Build
import android.util.Log
import androidx.wear.tiles.TileService
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import org.json.JSONObject

/**
 * Two-way state sync over the Wearable Data Layer.
 *
 * Single source of truth: the synced save-state JSON itself. GrillItemsSaveState
 * carries saveTime (epoch millis); the newest save wins on every device.
 * Phone and watch run the same code — each pushes its saves and applies newer
 * remote saves into FlutterSharedPreferences, then tells the tile and the
 * running Flutter app to reload.
 */
object GrillSync {
    const val PATH = "/grill_items"
    const val KEY_JSON = "json"
    private const val TAG = "GrillSync"
    private const val PREFS = "FlutterSharedPreferences"
    private const val PREF_KEY = "flutter.grillItems"

    // Guard against echoing a remote save straight back to the Data Layer.
    @Volatile
    private var lastAppliedSaveTime = -1L

    // MainActivity hooks this to ping the running Flutter app to reload.
    @Volatile
    var onRemoteApplied: (() -> Unit)? = null

    fun saveTimeOf(json: String?): Long {
        if (json == null) return -1L
        return runCatching { JSONObject(json).optLong("saveTime", -1L) }.getOrDefault(-1L)
    }

    private fun localJson(context: Context): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(PREF_KEY, null)

    /** Push the local save state, unless it is the remote state we just applied. */
    fun pushLocalState(context: Context) {
        val json = localJson(context) ?: return
        val saveTime = saveTimeOf(json)
        if (saveTime <= lastAppliedSaveTime) return
        val request = PutDataMapRequest.create(PATH).apply {
            dataMap.putString(KEY_JSON, json)
        }.asPutDataRequest().setUrgent()
        Wearable.getDataClient(context).putDataItem(request)
        Log.d(TAG, "pushed saveTime=$saveTime")
    }

    /** Apply a received save state when it is newer than the local one. */
    fun applyIfNewer(context: Context, json: String) {
        val incoming = saveTimeOf(json)
        val local = saveTimeOf(localJson(context))
        if (incoming <= local) {
            Log.d(TAG, "ignored saveTime=$incoming (local=$local)")
            return
        }
        lastAppliedSaveTime = incoming
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(PREF_KEY, json).commit()
        Log.d(TAG, "applied saveTime=$incoming (local was $local)")
        refreshTile(context)
        onRemoteApplied?.invoke()
    }

    /** Reconcile at startup: pull the Data Layer state, and offer ours upward. */
    fun syncNow(context: Context) {
        Wearable.getDataClient(context).dataItems.addOnSuccessListener { buffer ->
            buffer.use { items ->
                for (item in items) {
                    if (item.uri.path == PATH) {
                        DataMapItem.fromDataItem(item).dataMap.getString(KEY_JSON)
                            ?.let { applyIfNewer(context, it) }
                    }
                }
            }
            pushLocalState(context)
        }
    }

    fun refreshTile(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            runCatching {
                TileService.getUpdater(context).requestUpdate(GrillTileService::class.java)
            }
        }
    }
}
