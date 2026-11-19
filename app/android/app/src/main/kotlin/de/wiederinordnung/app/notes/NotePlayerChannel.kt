package de.wiederinordnung.app.notes

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Method channel "wio/player" (D-300): plays one note's recording at a
 * time from a local file in the media folder (D-301). Calls `play({path})`
 * and `stop`; events `onPosition(millis)` every 250 ms, `onEnded` and
 * `onError` back to Dart. No network, no permission.
 */
class NotePlayerChannel(
    context: Context,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {

    companion object {
        const val NAME = "wio/player"
        const val TICK_MS = 250L
    }

    private val main = Handler(Looper.getMainLooper())
    private val audio = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val attributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
        .build()
    private var player: MediaPlayer? = null
    private var focus: AudioFocusRequest? = null

    private val tick = object : Runnable {
        override fun run() {
            val current = player ?: return
            try {
                channel.invokeMethod("onPosition", current.currentPosition)
            } catch (_: IllegalStateException) {
                return
            }
            main.postDelayed(this, TICK_MS)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("failed", "no path", null)
                    return
                }
                try {
                    play(path)
                    result.success(null)
                } catch (e: Exception) {
                    release()
                    result.error("failed", e.toString(), null)
                }
            }
            "stop" -> {
                release()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun play(path: String) {
        release()
        val next = MediaPlayer()
        player = next
        next.setAudioAttributes(attributes)
        next.setDataSource(path)
        next.setOnCompletionListener {
            if (player === it) {
                release()
                channel.invokeMethod("onEnded", null)
            }
        }
        next.setOnErrorListener { mp, _, _ ->
            if (player === mp) {
                release()
                channel.invokeMethod("onError", null)
            }
            true
        }
        // Local files are small (at most 10 minutes, D-292): prepare at once.
        next.prepare()
        requestFocus()
        next.start()
        main.post(tick)
    }

    private fun requestFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(attributes)
                .setOnAudioFocusChangeListener { change ->
                    if (change == AudioManager.AUDIOFOCUS_LOSS ||
                        change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT
                    ) {
                        if (player != null) {
                            release()
                            channel.invokeMethod("onEnded", null)
                        }
                    }
                }
                .build()
            focus = request
            audio.requestAudioFocus(request)
        }
    }

    private fun release() {
        main.removeCallbacks(tick)
        val current = player
        player = null
        if (current != null) {
            try {
                current.stop()
            } catch (_: IllegalStateException) {
                // Not started yet or already ended.
            }
            current.release()
        }
        val request = focus
        focus = null
        if (request != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audio.abandonAudioFocusRequest(request)
        }
    }

    /** Called when the engine goes away. */
    fun dispose() {
        release()
    }
}
