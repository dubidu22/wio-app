package de.wiederinordnung.app

import de.wiederinordnung.app.voice.VoiceChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var voice: VoiceChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VoiceChannel.NAME)
        val handler = VoiceChannel(this, channel)
        channel.setMethodCallHandler(handler)
        voice = handler
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        voice?.dispose()
        voice = null
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
