package de.wiederinordnung.app

import android.content.Context
import de.wiederinordnung.app.background.WioEngine
import de.wiederinordnung.app.notes.NotePlayerChannel
import de.wiederinordnung.app.voice.VoiceChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var voice: VoiceChannel? = null
    private var player: NotePlayerChannel? = null

    // The app's one engine, shared with background sync (D-373): a screen
    // opened during a background run joins it.
    override fun provideFlutterEngine(context: Context): FlutterEngine = WioEngine.obtain(context)

    // Leaving the app ends the engine as before, unless a background run
    // still uses it; that run lets it go when it ends.
    override fun shouldDestroyEngineWithHost(): Boolean = !WioEngine.busy

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        WioEngine.activity(attached = true)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VoiceChannel.NAME)
        val handler = VoiceChannel(this, channel)
        channel.setMethodCallHandler(handler)
        voice = handler
        val playerChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NotePlayerChannel.NAME)
        val playerHandler = NotePlayerChannel(this, playerChannel)
        playerChannel.setMethodCallHandler(playerHandler)
        player = playerHandler
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        voice?.dispose()
        voice = null
        player?.dispose()
        player = null
        WioEngine.activity(attached = false)
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (voice?.onPermissionResult(requestCode, grantResults) != true) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }
}
