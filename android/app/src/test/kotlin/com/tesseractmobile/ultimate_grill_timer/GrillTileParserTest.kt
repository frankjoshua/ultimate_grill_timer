package com.tesseractmobile.ultimate_grill_timer

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.Instant
import java.time.ZoneId

class GrillTileParserTest {

    @Test
    fun parsesRunningAndPausedItemsSortedByStartTime() {
        val json = """
        {"grillItems":[
          {"id":"a",
           "timer":{"startTime":"2026-08-09T10:00:00.000","isPaused":false,"pauseDuration":60,"pauseStartTime":null},
           "flipTimer":null,"image":"assets/images/burger.png","flips":0,"isPaused":false},
          {"id":"b",
           "timer":{"startTime":"2026-08-09T09:00:00.000","isPaused":true,"pauseDuration":0,"pauseStartTime":"2026-08-09T09:05:30.000"},
           "flipTimer":null,"image":"assets/images/corn.png","flips":1,"isPaused":true},
          {"id":"broken","timer":{"startTime":"garbage"},"image":"x.png"}
        ],"saveTime":123}
        """.trimIndent()

        val timers = GrillTileParser.parse(json, ZoneId.of("UTC"))

        assertEquals(2, timers.size) // broken item skipped

        val corn = timers[0] // earliest startTime first
        assertEquals("assets/images/corn.png", corn.image)
        assertTrue(corn.isPaused)
        assertEquals(330, corn.pausedElapsedSeconds) // 09:05:30 - 09:00:00

        val burger = timers[1]
        assertFalse(burger.isPaused)
        // elapsed excludes the 60s pause: effective start = startTime + pauseDuration
        assertEquals(
            Instant.parse("2026-08-09T10:01:00Z").toEpochMilli(),
            burger.effectiveStartMs
        )
    }
}
