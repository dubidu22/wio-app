import 'package:flutter_test/flutter_test.dart';
import 'package:speech_spike/src/engine.dart';
import 'package:speech_spike/src/results.dart';

void main() {
  final device = DeviceInfo(
      platform: 'android', model: 'Testphone 1', manufacturer: 'Acme', sdkInt: 34);

  RunResult result({String? error, RecordingInfo? recording}) => RunResult(
        mode: SpikeMode.parallelPlugin,
        itemId: 's4',
        transcript: 'der Schrank | im Flur',
        werRaw: 0.25,
        werNormalized: 0.1,
        msToText: 812,
        recording: recording,
        recognizerEndedEarly: false,
        error: error,
      );

  test('clipboard text is a markdown table with device line', () {
    final text = resultsAsMarkdown(device, [
      result(recording: const RecordingInfo(seconds: 4.04, peakDbfs: -12.3, bytes: 32100)),
      result(error: 'error_no_match'),
    ]);
    expect(text, startsWith('speech spike results; device: Acme Testphone 1, android sdk 34'));
    expect(text, contains('| mode | item | WER raw | WER norm | ms to text | rec s | peak dBFS | rec bytes | ended early | error | transcript |'));
    expect(text, contains('| parallelPlugin | s4 | 25.0 | 10.0 | 812 | 4.0 | -12.3 | 32100 | no |  | der Schrank / im Flur |'));
    expect(text, contains('| parallelPlugin | s4 | 25.0 | 10.0 | 812 | - | - | - | no | error_no_match | der Schrank / im Flur |'));
  });

  test('results round-trip through JSON', () {
    final r = result(recording: const RecordingInfo(seconds: 1, peakDbfs: -40, bytes: 10));
    expect(RunResult.fromJson(r.toJson()).toJson(), r.toJson());
  });
}
