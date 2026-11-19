package de.wiederinordnung.app.voice

import android.content.Context
import android.content.Intent
import android.media.AudioFormat
import android.os.Bundle
import android.os.Handler
import android.os.ParcelFileDescriptor
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.annotation.TargetApi

/**
 * The on-device recognizer (D-286), fed with our own PCM through a pipe
 * (EXTRA_AUDIO_SOURCE, Android 13+). A segmented session runs until the
 * pipe is closed, so pauses in speech do not end it. Must be used on the
 * main thread. Only createOnDeviceSpeechRecognizer is used: there is no
 * path to an online recognizer (D-46). Moved from the speech spike's mode 2
 * (D-58, D-284).
 */
@TargetApi(33)
class PipeRecognizer(
    private val context: Context,
    private val main: Handler,
    private val source: ParcelFileDescriptor,
    private val sampleRate: Int,
    private val onPartial: (String) -> Unit,
    private val onDone: (transcript: String, error: String?) -> Unit,
) : RecognitionListener {

    private var recognizer: SpeechRecognizer? = null
    private val segments = mutableListOf<String>()
    private var finished = false

    private val transcript get() = segments.filter { it.isNotBlank() }.joinToString(" ")

    fun start() {
        if (finished) return
        val r = SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        recognizer = r
        r.setRecognitionListener(this)
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, VoiceChannel.LANGUAGE)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE, source)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_CHANNEL_COUNT, 1)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_SAMPLING_RATE, sampleRate)
            putExtra(RecognizerIntent.EXTRA_SEGMENTED_SESSION, RecognizerIntent.EXTRA_AUDIO_SOURCE)
        }
        r.startListening(intent)
    }

    /** Ends with what has been recognized so far. */
    fun finishNow(error: String?) = finish(error)

    private fun finish(error: String?) {
        if (finished) return
        finished = true
        main.post {
            recognizer?.destroy()
            recognizer = null
            try { source.close() } catch (_: Exception) {}
            onDone(transcript, error)
        }
    }

    private fun best(bundle: Bundle?): String =
        bundle?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull() ?: ""

    override fun onSegmentResults(segmentResults: Bundle) {
        segments.add(best(segmentResults))
        onPartial(transcript)
    }

    override fun onEndOfSegmentedSession() = finish(null)

    override fun onResults(results: Bundle?) {
        segments.add(best(results))
        finish(null)
    }

    override fun onPartialResults(partialResults: Bundle?) {
        val p = best(partialResults)
        onPartial(listOf(transcript, p).filter { it.isNotBlank() }.joinToString(" "))
    }

    override fun onError(error: Int) {
        // No match or a speech timeout is a normal end: silence, or the
        // text so far.
        val benign = error == SpeechRecognizer.ERROR_NO_MATCH || error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT
        finish(if (benign) null else errorName(error))
    }

    override fun onReadyForSpeech(params: Bundle?) {}
    override fun onBeginningOfSpeech() {}
    override fun onRmsChanged(rmsdB: Float) {}
    override fun onBufferReceived(buffer: ByteArray?) {}
    override fun onEndOfSpeech() {}
    override fun onEvent(eventType: Int, params: Bundle?) {}
}

fun errorName(code: Int): String = when (code) {
    SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "ERROR_NETWORK_TIMEOUT"
    SpeechRecognizer.ERROR_NETWORK -> "ERROR_NETWORK"
    SpeechRecognizer.ERROR_AUDIO -> "ERROR_AUDIO"
    SpeechRecognizer.ERROR_SERVER -> "ERROR_SERVER"
    SpeechRecognizer.ERROR_CLIENT -> "ERROR_CLIENT"
    SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "ERROR_SPEECH_TIMEOUT"
    SpeechRecognizer.ERROR_NO_MATCH -> "ERROR_NO_MATCH"
    SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "ERROR_RECOGNIZER_BUSY"
    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "ERROR_INSUFFICIENT_PERMISSIONS"
    else -> "ERROR_$code"
}
