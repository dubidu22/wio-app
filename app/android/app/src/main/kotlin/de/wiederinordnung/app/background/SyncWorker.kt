package de.wiederinordnung.app.background

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume

/**
 * One background sync run (D-376): asks the app's one engine (D-373) to run
 * sync until it is done, the deadline passes or WorkManager stops the
 * worker. Files only on an unmetered network (D-378). No foreground service,
 * so no notification (D-379).
 */
class SyncWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        val name = inputData.getString(BackgroundPlan.KEY_NAME) ?: BackgroundPlan.RECORDS
        val answer = withContext(Dispatchers.Main) { runInEngine() }
        return if (BackgroundPlan.retry(name, answer)) Result.retry() else Result.success()
    }

    private suspend fun runInEngine(): String? =
        suspendCancellableCoroutine { continuation ->
            val context = applicationContext
            val runId = id.toString()
            val background = WioEngine.beginBackground(context)
            // WorkManager stopped the worker: end the run at a safe point;
            // the engine is let go when Dart answers.
            continuation.invokeOnCancellation {
                Handler(Looper.getMainLooper()).post { background.stop(runId) }
            }
            background.run(
                runId,
                System.currentTimeMillis() + BackgroundPlan.RUN_TIME_MS,
                BackgroundChannel.unmetered(context),
            ) { answer ->
                WioEngine.endBackground()
                if (continuation.isActive) continuation.resume(answer)
            }
        }
}
