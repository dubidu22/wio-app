import 'dart:async';
import 'dart:math' as math;

import 'package:record/record.dart';

import '../engine.dart';

/// AAC-LC in an M4A file, 16 kHz mono (stack.md: AAC/M4A on the device).
class PluginRecorder implements Recorder {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitude;
  double _peak = -160;

  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start(String path) async {
    _peak = -160;
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 64000,
        androidConfig: AndroidRecordConfig(audioSource: AndroidAudioSource.mic),
      ),
      path: path,
    );
    _amplitude = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((a) => _peak = math.max(_peak, a.current));
  }

  @override
  Future<double> stop() async {
    await _recorder.stop();
    await _amplitude?.cancel();
    _amplitude = null;
    return _peak;
  }
}
