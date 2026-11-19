package de.wiederinordnung.app.background

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/** What WorkManager keeps for background sync (plan 052 T7, D-376..D-378). */
class BackgroundPlanTest {
    @Test
    fun inactiveCancelsAllThreeWorks() {
        assertEquals(
            listOf(
                BackgroundPlan.Step.Cancel(
                    listOf(BackgroundPlan.RECORDS, BackgroundPlan.FILES, BackgroundPlan.HOURLY),
                ),
            ),
            BackgroundPlan.steps(active = false, pending = true, files = true),
        )
    }

    @Test
    fun signedInKeepsOnlyTheHourlyPullWhenNothingWaits() {
        assertEquals(
            listOf(BackgroundPlan.Step.Keep(BackgroundPlan.hourlyWork)),
            BackgroundPlan.steps(active = true, pending = false, files = false),
        )
    }

    @Test
    fun waitingChangesAndFilesGetOneOffWork() {
        assertEquals(
            listOf(
                BackgroundPlan.Step.Keep(BackgroundPlan.hourlyWork),
                BackgroundPlan.Step.Keep(BackgroundPlan.recordsWork),
                BackgroundPlan.Step.Keep(BackgroundPlan.filesWork),
            ),
            BackgroundPlan.steps(active = true, pending = true, files = true),
        )
    }

    @Test
    fun recordsGoOnAnyNetworkFilesOnlyUnmetered() {
        assertEquals(BackgroundPlan.Network.CONNECTED, BackgroundPlan.recordsWork.network)
        assertEquals(BackgroundPlan.Network.UNMETERED, BackgroundPlan.filesWork.network)
        assertEquals(BackgroundPlan.Network.CONNECTED, BackgroundPlan.hourlyWork.network)
    }

    @Test
    fun theHourlyPullRunsAboutHourlyAndNotOnALowBattery() {
        val hourly = BackgroundPlan.hourlyWork
        assertEquals(60L, hourly.periodMinutes)
        assertEquals(15L, hourly.flexMinutes)
        assertTrue(hourly.batteryNotLow)
        assertEquals(null, BackgroundPlan.recordsWork.periodMinutes)
        assertFalse(BackgroundPlan.recordsWork.batteryNotLow)
    }

    @Test
    fun aRunEndsBeforeWorkManagersTenMinutes() {
        assertTrue(BackgroundPlan.RUN_TIME_MS < 10 * 60 * 1000L)
    }

    @Test
    fun oneOffWorkRetriesOnRetryOrNoAnswerPeriodicWaitsForItsPeriod() {
        assertTrue(BackgroundPlan.retry(BackgroundPlan.RECORDS, "retry"))
        assertTrue(BackgroundPlan.retry(BackgroundPlan.FILES, null))
        assertFalse(BackgroundPlan.retry(BackgroundPlan.RECORDS, "done"))
        assertFalse(BackgroundPlan.retry(BackgroundPlan.FILES, "skip"))
        assertFalse(BackgroundPlan.retry(BackgroundPlan.HOURLY, "retry"))
        assertFalse(BackgroundPlan.retry(BackgroundPlan.HOURLY, null))
    }
}
