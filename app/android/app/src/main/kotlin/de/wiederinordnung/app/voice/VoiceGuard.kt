package de.wiederinordnung.app.voice

/**
 * The rules of the on-device guard (D-46, D-287), apart from Android so
 * they have unit tests. A transcript is made only with Android 13+ (D-61),
 * an on-device recognizer and German installed on it; never through an
 * online recognizer.
 */
object VoiceGuard {
    const val READY = "ready"
    const val ANDROID_TOO_OLD = "androidTooOld"
    const val NO_ON_DEVICE = "noOnDevice"
    const val GERMAN_MISSING = "germanMissing"

    /** The answer before languages are asked for, or null to ask. */
    fun beforeLanguages(sdkInt: Int, onDeviceAvailable: Boolean): String? = when {
        sdkInt < 33 -> ANDROID_TOO_OLD
        !onDeviceAvailable -> NO_ON_DEVICE
        else -> null
    }

    /** The answer from the recognizer's language lists. */
    fun fromLanguages(
        installed: List<String>,
        pending: List<String>,
        supported: List<String>,
    ): String = when {
        installed.any(::isGerman) -> READY
        pending.any(::isGerman) || supported.any(::isGerman) -> GERMAN_MISSING
        else -> NO_ON_DEVICE
    }

    /** "de", "de-DE", "de_AT" and the like; not "dsb" or "en-DE". */
    fun isGerman(tag: String): Boolean {
        val t = tag.trim().lowercase()
        return t == "de" || t.startsWith("de-") || t.startsWith("de_")
    }
}
