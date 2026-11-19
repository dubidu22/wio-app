package de.wiederinordnung.app.background

import android.content.Context
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import java.util.concurrent.TimeUnit

/** Turns [BackgroundPlan] steps into WorkManager requests (D-376). */
object BackgroundScheduler {
    fun apply(
        context: Context,
        steps: List<BackgroundPlan.Step>,
    ) {
        val manager = WorkManager.getInstance(context)
        for (step in steps) {
            when (step) {
                is BackgroundPlan.Step.Cancel -> step.names.forEach { manager.cancelUniqueWork(it) }
                is BackgroundPlan.Step.Keep -> keep(manager, step.work)
            }
        }
    }

    private fun keep(
        manager: WorkManager,
        work: BackgroundPlan.Work,
    ) {
        val constraints =
            Constraints
                .Builder()
                .setRequiredNetworkType(
                    when (work.network) {
                        BackgroundPlan.Network.CONNECTED -> NetworkType.CONNECTED
                        BackgroundPlan.Network.UNMETERED -> NetworkType.UNMETERED
                    },
                ).setRequiresBatteryNotLow(work.batteryNotLow)
                .build()
        val input = workDataOf(BackgroundPlan.KEY_NAME to work.name)
        val period = work.periodMinutes
        if (period != null) {
            val request =
                PeriodicWorkRequestBuilder<SyncWorker>(
                    period,
                    TimeUnit.MINUTES,
                    work.flexMinutes ?: period,
                    TimeUnit.MINUTES,
                ).setConstraints(constraints)
                    .setInputData(input)
                    .build()
            manager.enqueueUniquePeriodicWork(work.name, ExistingPeriodicWorkPolicy.UPDATE, request)
        } else {
            val request =
                OneTimeWorkRequestBuilder<SyncWorker>()
                    .setConstraints(constraints)
                    .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, BackgroundPlan.BACKOFF_SECONDS, TimeUnit.SECONDS)
                    .setInputData(input)
                    .build()
            manager.enqueueUniqueWork(work.name, ExistingWorkPolicy.KEEP, request)
        }
    }
}
