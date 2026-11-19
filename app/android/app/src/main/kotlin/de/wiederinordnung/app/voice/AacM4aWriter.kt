package de.wiederinordnung.app.voice

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer

/** Encodes 16-bit mono PCM to AAC-LC in an M4A file. Not thread-safe. */
class AacM4aWriter(path: String, private val sampleRate: Int) {
    private val codec: MediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC)
    private val muxer = MediaMuxer(path, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
    private val info = MediaCodec.BufferInfo()
    private var track = -1
    private var muxerStarted = false
    private var samplesQueued = 0L

    init {
        val format = MediaFormat.createAudioFormat(MediaFormat.MIMETYPE_AUDIO_AAC, sampleRate, 1).apply {
            setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            setInteger(MediaFormat.KEY_BIT_RATE, 64_000)
            setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 16_384)
        }
        codec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        codec.start()
    }

    fun write(pcm: ByteArray, length: Int) {
        var offset = 0
        while (offset < length) {
            val index = codec.dequeueInputBuffer(10_000)
            if (index < 0) {
                drain(false)
                continue
            }
            val buffer = codec.getInputBuffer(index)!!
            buffer.clear()
            val n = minOf(buffer.remaining(), length - offset)
            buffer.put(pcm, offset, n)
            codec.queueInputBuffer(index, 0, n, samplesQueued * 1_000_000L / sampleRate, 0)
            samplesQueued += n / 2
            offset += n
            drain(false)
        }
    }

    fun finish() {
        while (true) {
            val index = codec.dequeueInputBuffer(10_000)
            if (index >= 0) {
                codec.queueInputBuffer(index, 0, 0, samplesQueued * 1_000_000L / sampleRate,
                    MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                break
            }
            drain(false)
        }
        drain(true)
        codec.stop()
        codec.release()
        if (muxerStarted) muxer.stop()
        muxer.release()
    }

    private fun drain(untilEnd: Boolean) {
        while (true) {
            val index = codec.dequeueOutputBuffer(info, if (untilEnd) 10_000 else 0)
            when {
                index == MediaCodec.INFO_TRY_AGAIN_LATER -> if (!untilEnd) return
                index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    track = muxer.addTrack(codec.outputFormat)
                    muxer.start()
                    muxerStarted = true
                }
                index >= 0 -> {
                    val out = codec.getOutputBuffer(index)!!
                    val isConfig = info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0
                    if (!isConfig && info.size > 0 && muxerStarted) {
                        out.position(info.offset)
                        out.limit(info.offset + info.size)
                        muxer.writeSampleData(track, out, info)
                    }
                    codec.releaseOutputBuffer(index, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return
                }
            }
        }
    }
}
