import 'package:flutter_test/flutter_test.dart';
import 'package:speech_spike/src/engine.dart';
import 'package:speech_spike/src/run_controller.dart';
import 'package:speech_spike/src/sentences.dart';

import 'fakes.dart';

void main() {
  late FakeClock clock;
  late FakeRecognizer recognizer;
  late FakeRecorder recorder;
  late FakeOneMic oneMic;
  late FakeFileTranscriber fileTranscriber;

  RunController controller(SpikeMode mode, TestItem item) => RunController(
        mode: mode,
        item: item,
        engines: SpikeEngines(
          recognizer: recognizer,
          recorder: recorder,
          oneMic: oneMic,
          fileTranscriber: fileTranscriber,
        ),
        clock: clock,
        recordingPath: (m, i) => '/tmp/${m.name}-${i.id}.m4a',
      );

  setUp(() {
    clock = FakeClock();
    recognizer = FakeRecognizer(clock);
    recorder = FakeRecorder(clock);
    oneMic = FakeOneMic(clock);
    fileTranscriber = FakeFileTranscriber(clock);
  });

  final sentence = testItems.first;

  test('recognize only: no recording, WER and time to text', () async {
    recognizer.finalText = sentence.reference!;
    recognizer.finalDelay = const Duration(milliseconds: 700);
    final c = controller(SpikeMode.recognizeOnly, sentence);
    await c.start();
    clock.advance(const Duration(seconds: 5));
    final r = await c.stop();
    expect(r.error, isNull);
    expect(r.recording, isNull);
    expect(recorder.started, isFalse);
    expect(r.werNormalized, 0);
    expect(r.msToText, 700);
    expect(r.transcript, sentence.reference);
  });

  test('parallel plugin: records and recognizes at once', () async {
    recognizer.finalText = 'die kiste';
    recorder.peakDbfs = -12;
    final c = controller(SpikeMode.parallelPlugin, sentence);
    await c.start();
    expect(recorder.started, isTrue);
    expect(recognizer.started, isTrue);
    clock.advance(const Duration(seconds: 4));
    final r = await c.stop();
    expect(r.recording!.seconds, closeTo(4, 0.01));
    expect(r.recording!.silent, isFalse);
    expect(r.werNormalized, greaterThan(0.5));
  });

  test('a silenced recording is flagged', () async {
    recognizer.finalText = sentence.reference!;
    recorder.peakDbfs = -160;
    final c = controller(SpikeMode.parallelPlugin, sentence);
    await c.start();
    clock.advance(const Duration(seconds: 3));
    final r = await c.stop();
    expect(r.recording!.silent, isTrue);
  });

  test('recognizer that ended before Stopp is reported', () async {
    recognizer.finalText = 'teil';
    final c = controller(SpikeMode.recognizeOnly, testItems.last);
    await c.start();
    clock.advance(const Duration(seconds: 6));
    recognizer.endOnItsOwn();
    clock.advance(const Duration(seconds: 30));
    final r = await c.stop();
    expect(r.recognizerEndedEarly, isTrue);
    expect(r.werNormalized, isNull, reason: 'free note has no reference');
    expect(r.msToText, 0);
  });

  test('one microphone mode uses the native session only', () async {
    oneMic.finalText = sentence.reference!;
    oneMic.peakDbfs = -20;
    oneMic.finalDelay = const Duration(milliseconds: 300);
    final c = controller(SpikeMode.oneMicNative, sentence);
    await c.start();
    clock.advance(const Duration(seconds: 5));
    final r = await c.stop();
    expect(recognizer.started, isFalse);
    expect(recorder.started, isFalse);
    expect(r.msToText, 300);
    expect(r.recording!.seconds, closeTo(5, 0.01));
    expect(r.werNormalized, 0);
  });

  test('record then transcribe counts transcription time', () async {
    recorder.peakDbfs = -15;
    fileTranscriber.text = sentence.reference!;
    fileTranscriber.delay = const Duration(milliseconds: 2500);
    final c = controller(SpikeMode.recordThenTranscribe, sentence);
    await c.start();
    expect(recognizer.started, isFalse);
    clock.advance(const Duration(seconds: 5));
    final r = await c.stop();
    expect(fileTranscriber.path, '/tmp/recordThenTranscribe-${sentence.id}.m4a');
    expect(r.msToText, 2500);
    expect(r.werNormalized, 0);
  });

  test('an engine error becomes a result, not a crash', () async {
    recognizer.failOnStop = 'error_no_match';
    final c = controller(SpikeMode.recognizeOnly, sentence);
    await c.start();
    final r = await c.stop();
    expect(r.error, contains('error_no_match'));
    expect(r.transcript, '');
  });

  test('an error on start is reported and stop is still safe', () async {
    recorder.failOnStart = 'busy';
    final c = controller(SpikeMode.recordThenTranscribe, sentence);
    await expectLater(c.start(), throwsA(isA<StartFailed>()));
  });
}
