package de.wiederinordnung.app.background

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The app's channel `wio/background` (D-374): Dart sends `ready` and
 * `schedule`; workers ask Dart to `run` and to `stop`. A `run` asked for
 * before Dart is ready waits here, so a cold start never loses one to the
 * engine's one-message channel buffer (PR 87 review S1). Main thread only.
 */
class BackgroundChannel(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val NAME = "wio/background"

        /** Whether the network now is unmetered, so files may go (D-378). */
        fun unmetered(context: Context): Boolean {
            val manager = context.getSystemService(ConnectivityManager::class.java) ?: return false
            val caps = manager.getNetworkCapabilities(manager.activeNetwork) ?: return false
            return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
        }
    }

    private val channel = MethodChannel(messenger, NAME).also { it.setMethodCallHandler(this) }
    private var ready = false
    private val waiting = mutableListOf<() -> Unit>()
    private val stoppedWhileWaiting = mutableSetOf<String>()

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "ready" -> {
                ready = true
                val queued = waiting.toList()
                waiting.clear()
                queued.forEach { it() }
                result.success(null)
            }
            "schedule" -> {
                val steps =
                    BackgroundPlan.steps(
                        active = call.argument<Boolean>("active") == true,
                        pending = call.argument<Boolean>("pending") == true,
                        files = call.argument<Boolean>("files") == true,
                    )
                try {
                    BackgroundScheduler.apply(context, steps)
                } catch (e: IllegalStateException) {
                    // WorkManager not ready; the next schedule tries again.
                    android.util.Log.w("wio", "background work not scheduled", e)
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Asks Dart for run [id]; [done] gets "done", "retry", "skip" or null.
     * Waits until Dart is ready.
     */
    fun run(
        id: String,
        deadlineMs: Long,
        files: Boolean,
        done: (String?) -> Unit,
    ) {
        if (!ready) {
            waiting.add {
                // Stopped before Dart was ready: never started.
                if (stoppedWhileWaiting.remove(id)) done("retry") else run(id, deadlineMs, files, done)
            }
            return
        }
        channel.invokeMethod(
            "run",
            mapOf("id" to id, "deadlineMs" to deadlineMs, "files" to files),
            object : MethodChannel.Result {
                override fun success(result: Any?) = done(result as? String)

                override fun error(
                    errorCode: String,
                    errorMessage: String?,
                    errorDetails: Any?,
                ) = done(null)

                override fun notImplemented() = done(null)
            },
        )
    }

    /** Run [id] ends at its next safe point, or does not start (D-375). */
    fun stop(id: String) {
        if (!ready) {
            stoppedWhileWaiting.add(id)
            return
        }
        channel.invokeMethod("stop", mapOf("id" to id))
    }
}
