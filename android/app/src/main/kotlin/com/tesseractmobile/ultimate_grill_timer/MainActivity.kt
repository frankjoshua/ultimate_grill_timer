package com.tesseractmobile.ultimate_grill_timer

import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.Bundle
import androidx.wear.tiles.TileService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var syncChannel: MethodChannel? = null

    // Tile "Add" button launches with mode=add -> picker screen. On watch
    // hardware the home screen is the watch list, not the phone layout.
    override fun getInitialRoute(): String? = when {
        intent?.getStringExtra("mode") == "add" -> "/add"
        packageManager.hasSystemFeature(android.content.pm.PackageManager.FEATURE_WATCH) -> "/watch"
        else -> super.getInitialRoute()
    }

    // Already-running app relaunched from the tile: navigate instead.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.getStringExtra("mode") == "add") {
            syncChannel?.invokeMethod("showAdd", null)
        }
    }

    // Fires on every Flutter save (SaveGrillItemsUseCase writes this key).
    // Must stay a field: SharedPreferences holds listeners weakly.
    private val prefsListener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
        if (key == "flutter.grillItems") GrillSync.pushLocalState(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        syncChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "grill_sync")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GrillSync.onRemoteApplied = {
            runOnUiThread { syncChannel?.invokeMethod("reload", null) }
        }
        getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            .registerOnSharedPreferenceChangeListener(prefsListener)
        GrillSync.syncNow(this)
    }

    override fun onDestroy() {
        getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            .unregisterOnSharedPreferenceChangeListener(prefsListener)
        GrillSync.onRemoteApplied = null
        super.onDestroy()
    }

    override fun onPause() {
        super.onPause()
        // Timer state may have changed; refresh the tile. No-op where no tile is added.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                TileService.getUpdater(this).requestUpdate(GrillTileService::class.java)
            } catch (e: Exception) {
                android.util.Log.w("GrillTile", "tile update request failed", e)
            }
        }
    }
}
