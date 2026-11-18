import 'dart:async';

import 'package:speech_spike/src/engine.dart';

class FakeClock implements SpikeClock {
  Duration _now = Duration.zero;
  final List<_Timer> _timers = [];

  @override
  Duration now() => _now;

  void advance(Duration d) {
    _now += d;
    for (final t in List.of(_timers)) {
      if (t.at <= _now) {
        _timers.remove(t);
        t.callback();
      }
    }
  }

  /// Completes [c] with [value] once the clock has advanced by [after].
  void schedule(Duration after, void Function() callback) {
    if (after <= Duration.zero) {
      callback();
      return;
    }
    _timers.add(_Timer(_now + after, callback));
  }
}

class _Timer {
  _Timer(this.at, this.callback);
  final Duration at;
  final void Function() callback;
}

/// Stops take [finalDelay] of clock time; the fake advances the clock itself
/// so tests stay synchronous.
class FakeRecognizer implements LiveRecognizer {
  FakeRecognizer(this.clock);
  final FakeClock clock;
  bool started = false;
  String finalText = '';
  Duration finalDelay = Duration.zero;
  String? failOnStop;
  bool _ended = false;

  void endOnItsOwn() => _ended = true;

  @override
  bool get endedOnItsOwn => _ended;

  @override
  Future<void> start(void Function(String partial) onPartial) async {
    started = true;
    onPartial('…');
  }

  @override
  Future<String> stop() async {
    if (failOnStop != null) throw SpikeEngineException(failOnStop!);
    if (!_ended) clock.advance(finalDelay);
    return finalText;
  }
}

class FakeRecorder implements Recorder {
  FakeRecorder(this.clock);
  final FakeClock clock;
  bool started = false;
  double peakDbfs = -160;
  String? failOnStart;

  @override
  Future<void> start(String path) async {
    if (failOnStart != null) throw SpikeEngineException(failOnStart!);
    started = true;
  }

  @override
  Future<double> stop() async => peakDbfs;
}

class FakeOneMic implements OneMicSession {
  FakeOneMic(this.clock);
  final FakeClock clock;
  String finalText = '';
  double peakDbfs = -160;
  Duration finalDelay = Duration.zero;

  @override
  Future<void> start(String path, void Function(String partial) onPartial) async {}

  @override
  Future<OneMicResult> stop() async {
    clock.advance(finalDelay);
    return OneMicResult(transcript: finalText, peakDbfs: peakDbfs);
  }
}

class FakeFileTranscriber implements FileTranscriber {
  FakeFileTranscriber(this.clock);
  final FakeClock clock;
  String text = '';
  Duration delay = Duration.zero;
  String? path;

  @override
  Future<String> transcribe(String path) async {
    this.path = path;
    clock.advance(delay);
    return text;
  }
}
