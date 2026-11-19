package de.wiederinordnung.app.background

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The app's channel `wio/background` (D-374): Dart sends `schedule`; the
 * worker asks Dart to `run` and to `stop`. Main thread only.
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

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
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

    /** Asks Dart for one run; [done] gets "done", "retry", "skip" or null. */
    fun run(
        deadlineMs: Long,
        files: Boolean,
        done: (String?) -> Unit,
    ) {
        channel.invokeMethod(
            "run",
            mapOf("deadlineMs" to deadlineMs, "files" to files),
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

    /** The run ends at its next safe point (D-375). */
    fun stop() {
        channel.invokeMethod("stop", null)
    }
}
