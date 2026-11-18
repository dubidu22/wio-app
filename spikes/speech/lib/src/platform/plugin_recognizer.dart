import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../engine.dart';

/// `speech_to_text` with on-device recognition requested. The plugin alone
/// does not guarantee on-device on Android (it falls back silently), so
/// every run is preceded by [SpeechPlatform.checkOnDevice] (D-46).
class PluginRecognizer implements LiveRecognizer {
  final SpeechToText _stt = SpeechToText();
  Completer<String>? _final;
  String _last = '';
  String? _error;
  bool _stopRequested = false;
  bool _endedOnItsOwn = false;

  @override
  bool get endedOnItsOwn => _endedOnItsOwn;

  void _onError(SpeechRecognitionError e) {
    _error = e.errorMsg;
    final c = _final;
    if (c != null && !c.isCompleted) {
      if (!_stopRequested) _endedOnItsOwn = true;
      c.complete(_last);
    }
  }

  void _onStatus(String status) {
    if (status == SpeechToText.doneStatus && !_stopRequested) {
      _endedOnItsOwn = true;
    }
  }

  @override
  Future<void> start(void Function(String partial) onPartial) async {
    final ok = await _stt.initialize(onError: _onError, onStatus: _onStatus);
    if (!ok) throw SpikeEngineException('speech_to_text initialize failed');
    _final = Completer<String>();
    _last = '';
    _error = null;
    _stopRequested = false;
    _endedOnItsOwn = false;
    await _stt.listen(
      onResult: (SpeechRecognitionResult r) {
        _last = r.recognizedWords;
        onPartial(_last);
        final c = _final;
        if (r.finalResult && c != null && !c.isCompleted) {
          if (!_stopRequested) _endedOnItsOwn = true;
          c.complete(_last);
        }
      },
      listenOptions: SpeechListenOptions(
        onDevice: true,
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        localeId: 'de_DE',
        pauseFor: const Duration(seconds: 30),
        listenFor: const Duration(minutes: 3),
      ),
    );
  }

  @override
  Future<String> stop() async {
    _stopRequested = true;
    await _stt.stop();
    final text = await _final!.future
        .timeout(const Duration(seconds: 10), onTimeout: () => _last);
    final error = _error;
    if (text.isEmpty && error != null) throw SpikeEngineException(error);
    return text;
  }
}
