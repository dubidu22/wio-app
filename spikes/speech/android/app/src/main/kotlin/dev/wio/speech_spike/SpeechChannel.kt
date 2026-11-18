package dev.wio.speech_spike

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionSupport
import android.speech.RecognitionSupportCallback
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Method channel "wio.spike/speech": the on-device guard (D-46), the
 * one-microphone session (mode 2) and file transcription (mode 3).
 * Everything here uses SpeechRecognizer.createOnDeviceSpeechRecognizer only;
 * there is no code path to an online recognizer.
 */
class SpeechChannel(
    private val context: Context,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {

    companion object {
        const val NAME = "wio.spike/speech"
        const val LANGUAGE = "de-DE"
    }

    private val main = Handler(Looper.getMainLooper())
    private var oneMic: OneMicSession? = null
    private var fileJob: FileTranscription? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "deviceInfo" -> result.success(
                    mapOf(
                        "model" to Build.MODEL,
                        "manufacturer" to Build.MANUFACTURER,
                        "sdkInt" to Build.VERSION.SDK_INT,
                    )
                )
                "checkOnDevice" -> checkOnDevice(call.argument<Boolean>("needsAudioSource") == true, result)
                "downloadGerman" -> downloadGerman(result)
                "oneMicStart" -> oneMicStart(call.argument<String>("path")!!, result)
                "oneMicStop" -> oneMicStop(result)
                "transcribeFile" -> transcribeFile(call.argument<String>("path")!!, result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("native", e.toString(), null)
        }
    }

    private fun guard(status: String, detail: String = "") = mapOf("status" to status, "detail" to detail)

    private fun checkOnDevice(needsAudioSource: Boolean, result: MethodChannel.Result) {
        val sdk = Build.VERSION.SDK_INT
        if (needsAudioSource && Build.VERSION.SDK_INT < 33) {
            result.success(guard("androidTooOld", "sdk $sdk"))
            return
        }
        // Below Android 12 there is no on-device recognizer API; the plugin
        // would silently use the default (possibly online) recognizer.
        if (Build.VERSION.SDK_INT < 31 || !SpeechRecognizer.isOnDeviceRecognitionAvailable(context)) {
            result.success(guard("noOnDevice", "sdk $sdk"))
            return
        }
        if (Build.VERSION.SDK_INT < 33) {
            // Android 12 cannot report the installed languages; the hand test
            // in airplane mode shows whether German works.
            result.success(guard("ready", "sdk $sdk, language not checkable"))
            return
        }
        checkGerman(result)
    }

    private fun checkGerman(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33) return
        val recognizer = SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
        var answered = false
        fun answer(map: Map<String, String>) = main.post {
            if (!answered) {
                answered = true
                recognizer.destroy()
                result.success(map)
            }
        }
        recognizer.checkRecognitionSupport(intent, Executors.newSingleThreadExecutor(),
            object : RecognitionSupportCallback {
                override fun onSupportResult(support: RecognitionSupport) {
                    val installed = support.installedOnDeviceLanguages
                    val pending = support.pendingOnDeviceLanguages
                    val supported = support.supportedOnDeviceLanguages
                    val detail = "installed=$installed pending=$pending supported=$supported"
                    fun hasGerman(list: List<String>) = list.any { it.lowercase().startsWith("de") }
                    answer(
                        when {
                            hasGerman(installed) -> guard("ready", detail)
                            hasGerman(pending) || hasGerman(supported) -> guard("germanMissing", detail)
                            else -> guard("noOnDevice", detail)
                        }
                    )
                }

                override fun onError(error: Int) {
                    answer(guard("noOnDevice", "checkRecognitionSupport error ${errorName(error)}"))
                }
            })
        main.postDelayed({ answer(guard("noOnDevice", "checkRecognitionSupport timeout")) }, 5000)
    }

    private fun downloadGerman(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33) {
            result.error("androidTooOld", "triggerModelDownload needs Android 13", null)
            return
        }
        val recognizer = SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
            .putExtra(RecognizerIntent.EXTRA_LANGUAGE, LANGUAGE)
        recognizer.triggerModelDownload(intent)
        main.postDelayed({ recognizer.destroy() }, 2000)
        result.success(null)
    }

    private fun partial(text: String) = main.post { channel.invokeMethod("onPartial", text) }

    private fun oneMicStart(path: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33) {
            result.error("androidTooOld", "needs Android 13", null)
            return
        }
        oneMic?.cancel()
        oneMic = OneMicSession(context, main, path, ::partial).also { it.start() }
        result.success(null)
    }

    private fun oneMicStop(result: MethodChannel.Result) {
        val session = oneMic
        if (session == null || Build.VERSION.SDK_INT < 33) {
            result.error("notStarted", "no session", null)
            return
        }
        oneMic = null
        session.stop { transcript, peakDbfs, error ->
            result.success(mapOf("transcript" to transcript, "peakDbfs" to peakDbfs, "error" to error))
        }
    }

    private fun transcribeFile(path: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33) {
            result.error("androidTooOld", "needs Android 13", null)
            return
        }
        fileJob?.cancel()
        fileJob = FileTranscription(context, main, path).also { job ->
            job.run { transcript, error ->
                fileJob = null
                result.success(mapOf("transcript" to transcript, "error" to error))
            }
        }
    }

    fun dispose() {
        oneMic?.cancel()
        fileJob?.cancel()
    }
}

fun errorName(code: Int): String = when (code) {
    1 -> "ERROR_NETWORK_TIMEOUT"
    2 -> "ERROR_NETWORK"
    3 -> "ERROR_AUDIO"
    4 -> "ERROR_SERVER"
    5 -> "ERROR_CLIENT"
    6 -> "ERROR_SPEECH_TIMEOUT"
    7 -> "ERROR_NO_MATCH"
    8 -> "ERROR_RECOGNIZER_BUSY"
    9 -> "ERROR_INSUFFICIENT_PERMISSIONS"
    10 -> "ERROR_TOO_MANY_REQUESTS"
    11 -> "ERROR_SERVER_DISCONNECTED"
    12 -> "ERROR_LANGUAGE_NOT_SUPPORTED"
    13 -> "ERROR_LANGUAGE_UNAVAILABLE"
    14 -> "ERROR_CANNOT_CHECK_SUPPORT"
    15 -> "ERROR_CANNOT_LISTEN_TO_DOWNLOAD_EVENTS"
    else -> "ERROR_$code"
}
