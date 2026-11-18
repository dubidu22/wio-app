import 'dart:io';

import 'engine.dart';
import 'results.dart';
import 'sentences.dart';
import 'wer.dart';

class StartFailed implements Exception {
  StartFailed(this.message);
  final String message;
  @override
  String toString() => message;
}

typedef RecordingPath = String Function(SpikeMode mode, TestItem item);

Future<int> _fileSize(String path) async {
  try {
    return await File(path).length();
  } on FileSystemException {
    return 0;
  }
}

/// Runs one test item in one mode: start on "Sprechen", stop on "Stopp",
/// and measure. Time to text runs from the stop tap to the final transcript.
class RunController {
  RunController({
    required this.mode,
    required this.item,
    required this.engines,
    required this.clock,
    required this.recordingPath,
    this.fileSize = _fileSize,
    this.onPartial,
  });

  final SpikeMode mode;
  final TestItem item;
  final SpikeEngines engines;
  final SpikeClock clock;
  final RecordingPath recordingPath;
  final Future<int> Function(String path) fileSize;
  final void Function(String partial)? onPartial;

  Duration? _startedAt;
  late final String _path = recordingPath(mode, item);

  void _partial(String text) => onPartial?.call(text);

  Future<void> start() async {
    try {
      switch (mode) {
        case SpikeMode.recognizeOnly:
          await engines.recognizer.start(_partial);
        case SpikeMode.parallelPlugin:
          await engines.recorder.start(_path);
          await engines.recognizer.start(_partial);
        case SpikeMode.oneMicNative:
          await engines.oneMic.start(_path, _partial);
        case SpikeMode.recordThenTranscribe:
          await engines.recorder.start(_path);
      }
    } on Exception catch (e) {
      throw StartFailed('$e');
    }
    _startedAt = clock.now();
  }

  Future<RunResult> stop() async {
    final stopAt = clock.now();
    final seconds = (stopAt - (_startedAt ?? stopAt)).inMicroseconds / 1e6;
    var transcript = '';
    double? peak;
    String? error;
    var endedEarly = false;
    Duration? textAt;

    try {
      switch (mode) {
        case SpikeMode.recognizeOnly:
          transcript = await engines.recognizer.stop();
          textAt = clock.now();
          endedEarly = engines.recognizer.endedOnItsOwn;
        case SpikeMode.parallelPlugin:
          final textFuture = engines.recognizer.stop().then((t) {
            textAt = clock.now();
            return t;
          });
          peak = await engines.recorder.stop();
          transcript = await textFuture;
          endedEarly = engines.recognizer.endedOnItsOwn;
        case SpikeMode.oneMicNative:
          final r = await engines.oneMic.stop();
          textAt = clock.now();
          transcript = r.transcript;
          peak = r.peakDbfs;
        case SpikeMode.recordThenTranscribe:
          peak = await engines.recorder.stop();
          transcript = await engines.fileTranscriber.transcribe(_path);
          textAt = clock.now();
      }
    } on Exception catch (e) {
      error = '$e';
    }

    final reference = item.reference;
    return RunResult(
      mode: mode,
      itemId: item.id,
      transcript: transcript,
      werRaw: reference == null
          ? null
          : wordErrorRate(simpleNormalize(reference), simpleNormalize(transcript)).rate,
      werNormalized: reference == null
          ? null
          : wordErrorRate(normalizeGerman(reference), normalizeGerman(transcript)).rate,
      msToText: textAt == null ? -1 : (textAt! - stopAt).inMilliseconds,
      recording: mode.records && peak != null
          ? RecordingInfo(seconds: seconds, peakDbfs: peak, bytes: await fileSize(_path))
          : null,
      recognizerEndedEarly: endedEarly,
      error: error,
    );
  }
}
