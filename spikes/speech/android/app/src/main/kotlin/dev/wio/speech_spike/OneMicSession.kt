package dev.wio.speech_spike

import android.annotation.SuppressLint
import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.ParcelFileDescriptor
import android.annotation.TargetApi
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit
import kotlin.math.abs
import kotlin.math.log10
import kotlin.math.max

/**
 * Mode 2: one AudioRecord; every PCM block goes to the M4A encoder and,
 * through a queue and a pipe, to the on-device recognizer. Closing the pipe
 * on stop ends the recognizer's segmented session.
 */
@TargetApi(33)
class OneMicSession(
    private val context: Context,
    private val main: Handler,
    private val path: String,
    private val onPartial: (String) -> Unit,
) {
    companion object {
        const val SAMPLE_RATE = 16_000
        private val END = ByteArray(0)
    }

    @Volatile private var running = false
    private var record: AudioRecord? = null
    private var captureThread: Thread? = null
    private var pipeThread: Thread? = null
    private var recognizer: PipeRecognizer? = null
    private val queue = LinkedBlockingQueue<ByteArray>()
    @Volatile private var peak = 0
    private var done: ((String, Double, String?) -> Unit)? = null
    private var result: Pair<String, String?>? = null

    @SuppressLint("MissingPermission") // Dart asks for RECORD_AUDIO before any run.
    fun start() {
        val minBuffer = AudioRecord.getMinBufferSize(SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
        val r = AudioRecord(MediaRecorder.AudioSource.VOICE_RECOGNITION, SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, max(minBuffer, SAMPLE_RATE) * 2)
        record = r
        val (readEnd, writeEnd) = ParcelFileDescriptor.createPipe()
        recognizer = PipeRecognizer(context, main, readEnd, SAMPLE_RATE, onPartial) { text, error ->
            result = text to error
            deliver()
        }.also { it.start() }

        running = true
        pipeThread = Thread {
            ParcelFileDescriptor.AutoCloseOutputStream(writeEnd).use { out ->
                while (true) {
                    val block = queue.take()
                    if (block === END) break
                    try { out.write(block) } catch (_: Exception) { break }
                }
            }
        }.also { it.start() }

        val writer = AacM4aWriter(path, SAMPLE_RATE)
        r.startRecording()
        captureThread = Thread {
            val buffer = ByteArray(3200) // 100 ms
            try {
                while (running) {
                    val n = r.read(buffer, 0, buffer.size)
                    if (n <= 0) continue
                    var i = 0
                    while (i + 1 < n) {
                        val s = (buffer[i].toInt() and 0xff) or (buffer[i + 1].toInt() shl 8)
                        peak = max(peak, abs(s.toShort().toInt()))
                        i += 2
                    }
                    queue.put(buffer.copyOf(n))
                    writer.write(buffer, n)
                }
            } finally {
                writer.finish()
                queue.put(END)
            }
        }.also { it.start() }
    }

    fun stop(onStopped: (transcript: String, peakDbfs: Double, error: String?) -> Unit) {
        done = onStopped
        running = false
        captureThread?.join(3000)
        record?.stop()
        record?.release()
        record = null
        // The pipe closes after the last block; the recognizer then ends the
        // session. Give it 15 s before taking what it has.
        main.postDelayed({ recognizer?.finishNow("timeout after stop") }, 15_000)
        deliver()
    }

    private fun deliver() {
        val cb = done ?: return
        val r = result ?: return
        done = null
        val dbfs = if (peak == 0) -160.0 else 20 * log10(peak / 32768.0)
        main.post { cb(r.first, dbfs, r.second) }
    }

    fun cancel() {
        running = false
        queue.put(END)
        recognizer?.finishNow("cancelled")
        record?.release()
        record = null
        pipeThread?.join(1000)
        captureThread?.join(1000)
        queue.poll(0, TimeUnit.MILLISECONDS)
    }
}
