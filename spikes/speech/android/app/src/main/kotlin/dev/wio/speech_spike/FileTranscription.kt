package dev.wio.speech_spike

import android.content.Context
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.os.Handler
import android.os.ParcelFileDescriptor
import android.annotation.TargetApi
import java.io.ByteArrayOutputStream

/**
 * Mode 3 (D-22): decode the saved M4A to 16-bit mono PCM and feed it to the
 * on-device recognizer through a pipe, as fast as the recognizer reads it.
 */
@TargetApi(33)
class FileTranscription(
    private val context: Context,
    private val main: Handler,
    private val path: String,
) {
    private var recognizer: PipeRecognizer? = null
    @Volatile private var cancelled = false

    fun run(onDone: (transcript: String, error: String?) -> Unit) {
        Thread {
            val decoded = try {
                decode(path)
            } catch (e: Exception) {
                main.post { onDone("", "decode failed: $e") }
                return@Thread
            }
            if (cancelled) return@Thread
            val (pcm, rate) = decoded
            val (readEnd, writeEnd) = ParcelFileDescriptor.createPipe()
            main.post {
                recognizer = PipeRecognizer(context, main, readEnd, rate, {}) { text, error ->
                    onDone(text, error)
                }.also { it.start() }
                Thread {
                    ParcelFileDescriptor.AutoCloseOutputStream(writeEnd).use { out ->
                        var offset = 0
                        while (offset < pcm.size && !cancelled) {
                            val n = minOf(3200, pcm.size - offset)
                            try { out.write(pcm, offset, n) } catch (_: Exception) { break }
                            offset += n
                        }
                    }
                }.start()
                val seconds = pcm.size / 2 / rate
                main.postDelayed({ recognizer?.finishNow("timeout") }, (60L + seconds * 2) * 1000)
            }
        }.start()
    }

    fun cancel() {
        cancelled = true
        recognizer?.finishNow("cancelled")
    }

    /** Returns mono 16-bit PCM and its sample rate. */
    private fun decode(path: String): Pair<ByteArray, Int> {
        val extractor = MediaExtractor()
        extractor.setDataSource(path)
        val track = (0 until extractor.trackCount).first {
            extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true
        }
        extractor.selectTrack(track)
        val format = extractor.getTrackFormat(track)
        val codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
        codec.configure(format, null, null, 0)
        codec.start()
        val out = ByteArrayOutputStream()
        val info = MediaCodec.BufferInfo()
        var rate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        var channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        var inputDone = false
        while (true) {
            if (!inputDone) {
                val index = codec.dequeueInputBuffer(10_000)
                if (index >= 0) {
                    val n = extractor.readSampleData(codec.getInputBuffer(index)!!, 0)
                    if (n < 0) {
                        codec.queueInputBuffer(index, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                        inputDone = true
                    } else {
                        codec.queueInputBuffer(index, 0, n, extractor.sampleTime, 0)
                        extractor.advance()
                    }
                }
            }
            val index = codec.dequeueOutputBuffer(info, 10_000)
            if (index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                rate = codec.outputFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                channels = codec.outputFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            } else if (index >= 0) {
                val buffer = codec.getOutputBuffer(index)!!
                val chunk = ByteArray(info.size)
                buffer.position(info.offset)
                buffer.get(chunk)
                out.write(chunk)
                codec.releaseOutputBuffer(index, false)
                if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
            }
        }
        codec.stop()
        codec.release()
        extractor.release()
        val pcm = out.toByteArray()
        return (if (channels <= 1) pcm else downmix(pcm, channels)) to rate
    }

    private fun downmix(pcm: ByteArray, channels: Int): ByteArray {
        val frames = pcm.size / 2 / channels
        val mono = ByteArray(frames * 2)
        for (f in 0 until frames) {
            var sum = 0
            for (c in 0 until channels) {
                val i = (f * channels + c) * 2
                sum += ((pcm[i].toInt() and 0xff) or (pcm[i + 1].toInt() shl 8)).toShort().toInt()
            }
            val s = sum / channels
            mono[f * 2] = (s and 0xff).toByte()
            mono[f * 2 + 1] = ((s shr 8) and 0xff).toByte()
        }
        return mono
    }
}
