package de.wiederinordnung.app.voice

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.ParcelFileDescriptor
import java.io.File
import java.util.concurrent.LinkedBlockingQueue
import kotlin.math.max

/** What a finished session hands back to Dart. */
data class VoiceOutcome(val millis: Long, val transcript: String, val error: String?)

/**
 * One voice note (D-58, D-284): one AudioRecord; every PCM block goes to the
 * M4A writer and, once the on-device guard has passed (D-287), through a
 * queue and a pipe to the recognizer. Recording starts at once; blocks wait
 * in the queue while the guard runs, so the first words are heard (D-288).
 * Closing the pipe on stop ends the recognizer's segmented session; the last
 * text is awaited for at most [FINAL_WAIT_MS] (D-289).
 *
 * Created and driven on the main thread; capture runs on its own thread.
 */
class VoiceSession(
    private val context: Context,
    private val main: Handler,
    private val path: String,
    private val onPartial: (String) -> Unit,
) {
    companion object {
        const val SAMPLE_RATE = 16_000
        const val FINAL_WAIT_MS = 5_000L
        private val END = ByteArray(0)
    }

    private enum class Feed { WAITING, FEEDING, DROPPED }

    @Volatile private var running = false
    @Volatile private var feed = Feed.WAITING
    @Volatile private var samples = 0L
    @Volatile private var writerError: String? = null
    private var record: AudioRecord? = null
    private var captureThread: Thread? = null
    private var pipeThread: Thread? = null
    private var recognizer: PipeRecognizer? = null
    private val queue = LinkedBlockingQueue<ByteArray>()
    private var heard: Pair<String, String?>? = null
    private var stopped: ((VoiceOutcome) -> Unit)? = null
    private var captureDone = false

    /** Starts recording; throws when the microphone cannot be had. */
    @SuppressLint("MissingPermission") // Dart asks for RECORD_AUDIO first (D-293).
    fun start() {
        val minBuffer = AudioRecord.getMinBufferSize(
            SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT,
        )
        if (minBuffer <= 0) throw IllegalStateException("no buffer size: $minBuffer")
        val r = AudioRecord(
            MediaRecorder.AudioSource.VOICE_RECOGNITION, SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT,
            max(minBuffer, SAMPLE_RATE) * 2,
        )
        if (r.state != AudioRecord.STATE_INITIALIZED) {
            r.release()
            throw IllegalStateException("AudioRecord not initialized")
        }
        val writer = try {
            AacM4aWriter(path, SAMPLE_RATE)
        } catch (e: Exception) {
            r.release()
            throw e
        }
        r.startRecording()
        if (r.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
            // Another app holds the microphone (a call, a recorder).
            r.release()
            try { writer.finish() } catch (_: Exception) {}
            File(path).delete()
            throw IllegalStateException("microphone busy")
        }
        record = r
        running = true
        captureThread = Thread {
            val buffer = ByteArray(3200) // 100 ms
            try {
                while (running) {
                    val n = r.read(buffer, 0, buffer.size)
                    if (n <= 0) continue
                    if (feed != Feed.DROPPED) queue.put(buffer.copyOf(n))
                    writer.write(buffer, n)
                    samples += n / 2
                }
            } catch (e: Exception) {
                writerError = e.toString()
            } finally {
                try {
                    writer.finish()
                } catch (e: Exception) {
                    writerError = writerError ?: e.toString()
                }
                queue.put(END)
            }
        }.also { it.start() }
    }

    /** The guard passed (D-287): the recognizer starts on what was queued. */
    @TargetApi(33)
    fun transcribe() {
        if (feed != Feed.WAITING || stopped != null) {
            drop()
            return
        }
        val (readEnd, writeEnd) = ParcelFileDescriptor.createPipe()
        recognizer = PipeRecognizer(context, main, readEnd, SAMPLE_RATE, onPartial) { text, error ->
            // Ended early (an error): later blocks go only to the file.
            feed = Feed.DROPPED
            queue.clear()
            heard = text to error
            deliver()
        }.also { it.start() }
        feed = Feed.FEEDING
        pipeThread = Thread {
            ParcelFileDescriptor.AutoCloseOutputStream(writeEnd).use { out ->
                while (true) {
                    val block = queue.take()
                    if (block === END) break
                    try {
                        out.write(block)
                    } catch (_: Exception) {
                        feed = Feed.DROPPED
                        queue.clear()
                        break
                    }
                }
            }
        }.also { it.start() }
    }

    /** The guard refused: no transcript, the recording goes on (D-61). */
    fun drop() {
        if (feed == Feed.FEEDING) return
        feed = Feed.DROPPED
        queue.clear()
    }

    /** Ends recording; [onStopped] runs on the main thread. */
    fun stop(onStopped: (VoiceOutcome) -> Unit) {
        if (stopped != null) return
        stopped = onStopped
        running = false
        if (feed == Feed.WAITING) drop()
        Thread {
            captureThread?.join(3_000)
            record?.let {
                try { it.stop() } catch (_: Exception) {}
                it.release()
            }
            record = null
            main.post {
                captureDone = true
                if (recognizer != null) {
                    main.postDelayed({ recognizer?.finishNow(null) }, FINAL_WAIT_MS)
                } else {
                    heard = "" to null
                }
                deliver()
            }
        }.start()
    }

    private fun deliver() {
        val callback = stopped ?: return
        if (!captureDone) return
        val result = heard ?: return
        stopped = null
        val millis = samples * 1000 / SAMPLE_RATE
        callback(VoiceOutcome(millis, result.first, writerError ?: result.second))
    }

    /** Ends without a result and deletes the file. */
    fun cancel() {
        running = false
        stopped = null
        drop()
        queue.put(END)
        recognizer?.finishNow("cancelled")
        Thread {
            captureThread?.join(1_000)
            pipeThread?.join(1_000)
            record?.release()
            record = null
            File(path).delete()
        }.start()
    }
}
