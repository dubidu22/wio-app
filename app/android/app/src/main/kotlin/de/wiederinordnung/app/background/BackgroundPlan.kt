package de.wiederinordnung.app.background

/**
 * What WorkManager keeps for background sync (plan 052, D-376, D-377), as
 * plain values so JVM tests can check them without a phone.
 */
object BackgroundPlan {
    /** One-off work for unsent changes; any network. */
    const val RECORDS = "wio-sync-records"

    /** One-off work for files; unmetered networks only (D-378). */
    const val FILES = "wio-sync-files"

    /** The hourly pull while signed in. */
    const val HOURLY = "wio-sync-hourly"

    /** Input key holding the work's name. */
    const val KEY_NAME = "name"

    /** WorkManager stops a worker after 10 minutes; a run ends before that. */
    const val RUN_TIME_MS = 9 * 60 * 1000L

    /** First wait after a one-off run answered "retry"; then exponential. */
    const val BACKOFF_SECONDS = 30L

    enum class Network { CONNECTED, UNMETERED }

    data class Work(
        val name: String,
        val network: Network,
        /** Null for one-off work. */
        val periodMinutes: Long?,
        val flexMinutes: Long?,
        val batteryNotLow: Boolean,
    )

    sealed interface Step {
        data class Cancel(val names: List<String>) : Step

        data class Keep(val work: Work) : Step
    }

    val recordsWork = Work(RECORDS, Network.CONNECTED, null, null, false)
    val filesWork = Work(FILES, Network.UNMETERED, null, null, false)
    val hourlyWork = Work(HOURLY, Network.CONNECTED, 60, 15, true)

    /**
     * The steps for Dart's `schedule` (D-374): nothing while signed out,
     * without a server or too old (D-377); otherwise the hourly pull, plus
     * one-off work for what waits.
     */
    fun steps(active: Boolean, pending: Boolean, files: Boolean): List<Step> {
        if (!active) return listOf(Step.Cancel(listOf(RECORDS, FILES, HOURLY)))
        val steps = mutableListOf<Step>(Step.Keep(hourlyWork))
        if (pending) steps.add(Step.Keep(recordsWork))
        if (files) steps.add(Step.Keep(filesWork))
        return steps
    }

    /**
     * Whether WorkManager should run this work again after its back-off.
     * Periodic work just waits for its next period. No answer (Dart did not
     * reply) counts as "retry".
     */
    fun retry(name: String, answer: String?): Boolean =
        name != HOURLY && (answer == null || answer == "retry")
}
