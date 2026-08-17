package com.tesseractmobile.ultimate_grill_timer

import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService

/** Receives grill state from the other device, even when the app is not running. */
class GrillDataListenerService : WearableListenerService() {
    override fun onDataChanged(events: DataEventBuffer) {
        for (event in events) {
            if (event.type == DataEvent.TYPE_CHANGED && event.dataItem.uri.path == GrillSync.PATH) {
                DataMapItem.fromDataItem(event.dataItem).dataMap.getString(GrillSync.KEY_JSON)
                    ?.let { GrillSync.applyIfNewer(this, it) }
            }
        }
    }
}
