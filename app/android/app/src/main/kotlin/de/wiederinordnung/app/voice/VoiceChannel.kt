package de.wiederinordnung.app.voice

import android.Manifest
import android.annotation.TargetApi
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionSupport
import android.speech.RecognitionSupportCallback
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.view.WindowManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Method channel "wio/voice" (D-284): the microphone permission (D-293),
 * one voice note at a time (D-58), the on-device guard for German (D-46,
 * D-287) and the phone's own German model download.
 *
 * Every recognizer here comes from createOnDeviceSpeechRecognizer; there is
 * no code path to an online recognizer.
 */
class VoiceChannel(
    private val activity: Activity,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {

    companion object {
        const val NAME = "wio/voice"
        const val LANGUAGE = "de-DE"
        const val PERMISSION_REQUEST = 6001
        const val GUARD_TIMEOUT_MS = 3_000L
    }

    private val main = Handler(Looper.getMainLooper())
    private var session: VoiceSession? = null
    private var pendingPermission: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "permission" -> result.success(permissionState())
                "requestPermission" -> requestPermission(result)
                "start" -> start(call.argument<String>("path")!!, result)
                "stop" -> stop(result)
                "cancel" -> {
                    cancel()
                    result.success(null)
                }
                "downloadGerman" -> downloadGerman(result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("failed", e.toString(), null)
        }
    }

    private fun permissionState(): String =
        if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
        ) "granted" else "refused"

    private fun requestPermission(result: MethodChannel.Result) {
        if (permissionState() == "granted") {
            result.success("granted")
            return
        }
        pendingPermission?.success("refused")
        pendingPermission = result
        activity.requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), PERMISSION_REQUEST)
    }

    /** From MainActivity.onRequestPermissionsResult. */
    fun onPermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != PERMISSION_REQUEST) return false
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingPermission?.success(if (granted) "granted" else "refused")
        pendingPermission = null
        return true
    }

    private fun start(path: String, result: MethodChannel.Result) {
        if (session != null) {
            result.error("busy", "a voice note is already recording", null)
            return
        }
        if (permissionState() != "granted") {
            result.error("refused", "RECORD_AUDIO not granted", null)
            return
        }
        val next = VoiceSession(activity, main, path, ::partial)
        try {
            next.start()
        } catch (e: Exception) {
            result.error("busy", e.toString(), null)
            return
        }
        session = next
        keepScreenOn(true)
        result.success(null)
        // The call is answered: from here on nothing may throw back into
        // onMethodCall's catch (PR 73 review S2).
        val apply = { status: String ->
            if (session === next) {
                var answer = status
                if (status == VoiceGuard.READY && Build.VERSION.SDK_INT >= 33) {
                    try {
                        next.transcribe()
                    } catch (e: Exception) {
                        next.drop()
                        answer = VoiceGuard.NO_ON_DEVICE
                    }
                } else {
                    next.drop()
                }
                channel.invokeMethod("onTranscription", answer)
            }
        }
        try {
            guard(apply)
        } catch (e: Exception) {
            main.post { apply(VoiceGuard.NO_ON_DEVICE) }
        }
    }

    private fun stop(result: MethodChannel.Result) {
        val current = session
        if (current == null) {
            result.error("notStarted", "no voice note is recording", null)
            return
        }
        session = null
        keepScreenOn(false)
        current.stop { outcome ->
            result.success(
                mapOf(
                    "millis" to outcome.millis,
                    "transcript" to outcome.transcript,
                    "error" to outcome.error,
                )
            )
        }
    }

    private fun cancel() {
        session?.cancel()
        session = null
        keepScreenOn(false)
    }

    /** Screen stays on while recording (D-297). */
    private fun keepScreenOn(on: Boolean) {
        if (on) {
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }

    private fun partial(text: String) = main.post { channel.invokeMethod("onPartial", text) }

    /**
     * The guard (D-46, D-287): Android 13+, an on-device recognizer, German
     * installed. Answers once on the main thread: ready, androidTooOld,
     * noOnDevice or germanMissing; no answer in time counts as noOnDevice.
     */
    private fun guard(answer: (String) -> Unit) {
        val onDevice = Build.VERSION.SDK_INT >= 31 &&
            SpeechRecognizer.isOnDeviceRecognitionAvailable(activity)
        val early = VoiceGuard.beforeLanguages(Build.VERSION.SDK_INT, onDevice)
        if (early != null || Build.VERSION.SDK_INT < 33) {
            answer(early ?: VoiceGuard.ANDROID_TOO_OLD)
            return
        }
        checkGerman(answer)
    }

    @TargetApi(33)
    private fun checkGerman(answer: (String) -> Unit) {
        var answered = false
        var recognizer: SpeechRecognizer? = null
        var executor: java.util.concurrent.ExecutorService? = null
        fun once(status: String) = main.post {
            if (!answered) {
                answered = true
                try { recognizer?.destroy() } catch (_: Exception) {}
                executor?.shutdown()
                answer(status)
            }
        }
        main.postDelayed({ once(VoiceGuard.NO_ON_DEVICE) }, GUARD_TIMEOUT_MS)
        try {
            val r = SpeechRecognizer.createOnDeviceSpeechRecognizer(activity)
            recognizer = r
            val pool = Executors.newSingleThreadExecutor()
            executor = pool
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
                .putExtra(RecognizerIntent.EXTRA_LANGUAGE, LANGUAGE)
            r.checkRecognitionSupport(intent, pool,
                object : RecognitionSupportCallback {
                    override fun onSupportResult(support: RecognitionSupport) {
                        once(
                            VoiceGuard.fromLanguages(
                                support.installedOnDeviceLanguages,
                                support.pendingOnDeviceLanguages,
                                support.supportedOnDeviceLanguages,
                            )
                        )
                    }

                    override fun onError(error: Int) {
                        once(VoiceGuard.NO_ON_DEVICE)
                    }
                })
        } catch (e: Exception) {
            once(VoiceGuard.NO_ON_DEVICE)
        }
    }

    private fun downloadGerman(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33) {
            result.success(false)
            return
        }
        triggerDownload()
        result.success(true)
    }

    @TargetApi(33)
    private fun triggerDownload() {
        val recognizer = SpeechRecognizer.createOnDeviceSpeechRecognizer(activity)
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
            .putExtra(RecognizerIntent.EXTRA_LANGUAGE, LANGUAGE)
        recognizer.triggerModelDownload(intent)
        main.postDelayed({ recognizer.destroy() }, 2_000)
    }

    fun dispose() {
        cancel()
        pendingPermission?.success("refused")
        pendingPermission = null
    }
}
