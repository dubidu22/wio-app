package dev.wio.speech_spike

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
 * The on-device recognizer, fed with our own PCM through a pipe
 * (EXTRA_AUDIO_SOURCE, Android 13+). A segmented session runs until the
 * pipe is closed, so pauses in speech do not end it. Must be used on the
 * main thread.
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
        val r = SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        recognizer = r
        r.setRecognitionListener(this)
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, SpeechChannel.LANGUAGE)
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
        // No match or speech timeout after some segments is a normal end.
        val benign = error == SpeechRecognizer.ERROR_NO_MATCH || error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT
        finish(if (benign && segments.isNotEmpty()) null else errorName(error))
    }

    override fun onReadyForSpeech(params: Bundle?) {}
    override fun onBeginningOfSpeech() {}
    override fun onRmsChanged(rmsdB: Float) {}
    override fun onBufferReceived(buffer: ByteArray?) {}
    override fun onEndOfSpeech() {}
    override fun onEvent(eventType: Int, params: Bundle?) {}
}
