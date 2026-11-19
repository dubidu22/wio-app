package de.wiederinordnung.app.voice

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/** The guard's rules (D-46, D-61, D-287). */
class VoiceGuardTest {
    @Test
    fun androidOlderThan13RecordsOnly() {
        assertEquals(VoiceGuard.ANDROID_TOO_OLD, VoiceGuard.beforeLanguages(32, true))
        assertEquals(VoiceGuard.ANDROID_TOO_OLD, VoiceGuard.beforeLanguages(31, false))
    }

    @Test
    fun noOnDeviceRecognizerRecordsOnly() {
        assertEquals(VoiceGuard.NO_ON_DEVICE, VoiceGuard.beforeLanguages(34, false))
    }

    @Test
    fun android13WithOnDeviceAsksForLanguages() {
        assertNull(VoiceGuard.beforeLanguages(33, true))
        assertNull(VoiceGuard.beforeLanguages(35, true))
    }

    @Test
    fun installedGermanIsReady() {
        assertEquals(VoiceGuard.READY, VoiceGuard.fromLanguages(listOf("en-US", "de-DE"), emptyList(), emptyList()))
        assertEquals(VoiceGuard.READY, VoiceGuard.fromLanguages(listOf("de"), emptyList(), emptyList()))
    }

    @Test
    fun germanOnlyPendingOrSupportedIsMissing() {
        assertEquals(VoiceGuard.GERMAN_MISSING, VoiceGuard.fromLanguages(listOf("en-US"), listOf("de-DE"), emptyList()))
        assertEquals(VoiceGuard.GERMAN_MISSING, VoiceGuard.fromLanguages(emptyList(), emptyList(), listOf("de-AT")))
    }

    @Test
    fun noGermanAnywhereRecordsOnly() {
        assertEquals(VoiceGuard.NO_ON_DEVICE, VoiceGuard.fromLanguages(listOf("en-US"), listOf("fr-FR"), listOf("en-DE")))
        assertEquals(VoiceGuard.NO_ON_DEVICE, VoiceGuard.fromLanguages(emptyList(), emptyList(), emptyList()))
    }

    @Test
    fun germanTags() {
        assertTrue(VoiceGuard.isGerman("de-DE"))
        assertTrue(VoiceGuard.isGerman("DE_ch"))
        assertFalse(VoiceGuard.isGerman("dsb"))
        assertFalse(VoiceGuard.isGerman("en-DE"))
        assertFalse(VoiceGuard.isGerman("dv"))
    }
}
