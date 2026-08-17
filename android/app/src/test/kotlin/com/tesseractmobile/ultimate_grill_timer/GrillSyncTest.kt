package com.tesseractmobile.ultimate_grill_timer

import org.junit.Assert.assertEquals
import org.junit.Test

class GrillSyncTest {
    @Test
    fun saveTimeParsing() {
        assertEquals(1786304013033, GrillSync.saveTimeOf("""{"grillItems":[],"saveTime":1786304013033}"""))
        assertEquals(-1, GrillSync.saveTimeOf("""{"grillItems":[]}"""))
        assertEquals(-1, GrillSync.saveTimeOf("not json"))
        assertEquals(-1, GrillSync.saveTimeOf(null))
    }
}
