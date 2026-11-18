package dev.wio.speech_spike

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var speech: SpeechChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SpeechChannel.NAME)
        speech = SpeechChannel(applicationContext, channel).also { channel.setMethodCallHandler(it) }
    }

    override fun onDestroy() {
        speech?.dispose()
        super.onDestroy()
    }
}
