import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:speech_spike/src/app.dart';
import 'package:speech_spike/src/engine.dart';
import 'package:speech_spike/src/results.dart';
import 'package:speech_spike/src/sentences.dart';
import 'package:speech_spike/src/services.dart';

import 'fakes.dart';

class FakePlatform implements SpeechPlatform {
  GuardStatus status = GuardStatus.ready;
  bool mic = true;
  int downloads = 0;

  @override
  Future<GuardResult> checkOnDevice(SpikeMode mode) async => GuardResult(status);

  @override
  Future<DeviceInfo> deviceInfo() async => const DeviceInfo(
      platform: 'android', model: 'Testphone', manufacturer: 'Acme', sdkInt: 34);

  @override
  Future<bool> ensureMicPermission() async => mic;

  @override
  Future<void> requestGermanDownload() async => downloads++;
}

void main() {
  late FakePlatform platform;
  late FakeClock clock;
  late FakeRecognizer recognizer;
  late ResultsLog log;
  late List<String> clipboard;

  SpikeServices services() => SpikeServices(
        platform: platform,
        engines: SpikeEngines(
          recognizer: recognizer,
          recorder: FakeRecorder(clock),
          oneMic: FakeOneMic(clock),
          fileTranscriber: FakeFileTranscriber(clock),
        ),
        clock: clock,
        results: log,
        recordingPath: (m, i) => '/nonexistent/${m.name}-${i.id}.m4a',
        copyToClipboard: (t) async => clipboard.add(t),
      );

  setUp(() {
    platform = FakePlatform();
    clock = FakeClock();
    recognizer = FakeRecognizer(clock)..finalText = testItems.first.reference!;
    log = ResultsLog();
    clipboard = [];
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(SpikeApp(services: services()));
    await tester.pumpAndSettle();
  }

  void expectTouchTargets(WidgetTester tester) {
    final buttons = find.byWidgetPredicate((w) => w is ButtonStyleButton);
    expect(buttons, findsWidgets);
    for (final e in buttons.evaluate()) {
      final size = tester.getSize(find.byWidget(e.widget));
      expect(size.height, greaterThanOrEqualTo(56), reason: '${e.widget}');
      expect(size.width, greaterThanOrEqualTo(56), reason: '${e.widget}');
    }
  }

  testWidgets('start screen: German labels, worded buttons, 56 px targets',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('Was soll getestet werden?'), findsOneWidget);
    expect(find.text('Nur erkennen'), findsOneWidget);
    expect(find.text('Gleichzeitig'), findsOneWidget);
    expect(find.text('Erst aufnehmen, dann erkennen'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Quellcode'), 100);
    expect(find.text('Ergebnisse'), findsOneWidget);
    expectTouchTargets(tester);
  });

  testWidgets('Quellcode shows the repository link (D-29)', (tester) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('source-code')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.byKey(const ValueKey('source-code')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('source-code')));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate(
            (w) => w is SelectableText && w.data == sourceCodeUrl),
        findsOneWidget);
    expectTouchTargets(tester);
  });

  testWidgets('two taps: Sprechen, Stopp, then the measured result',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Nur erkennen'));
    await tester.pumpAndSettle();
    expect(find.text('Satz 1 von 6'), findsOneWidget);
    expect(find.text(testItems.first.reference!), findsOneWidget);
    expect(find.text('Zurück'), findsOneWidget);
    expectTouchTargets(tester);

    await tester.tap(find.text('Sprechen'));
    await tester.pumpAndSettle();
    expect(find.text('Hört zu …'), findsOneWidget);
    await tester.tap(find.text('Stopp'));
    await tester.pumpAndSettle();

    expect(find.text('Erkannter Text'), findsOneWidget);
    expect(find.text('Fehlerquote: 0.0 % (genau: 0.0 %)'), findsOneWidget);
    expect(find.text('In diesem Modus gibt es keine Aufnahme.'), findsOneWidget);
    expect(log.results, hasLength(1));
    expectTouchTargets(tester);

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Satz 2 von 6'), findsOneWidget);
  });

  testWidgets('the guard blocks a phone without on-device German',
      (tester) async {
    platform.status = GuardStatus.noOnDevice;
    await pumpApp(tester);
    await tester.tap(find.text('Gleichzeitig'));
    await tester.pumpAndSettle();
    expect(find.textContaining('nicht ohne Internet'), findsOneWidget);
    expect(find.text('Sprechen'), findsNothing);
    expect(recognizer.started, isFalse);
  });

  testWidgets('missing German offers the download', (tester) async {
    platform.status = GuardStatus.germanMissing;
    await pumpApp(tester);
    await tester.tap(find.text('Nur erkennen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch laden'));
    await tester.pumpAndSettle();
    expect(platform.downloads, 1);
    expect(find.text('Sprechen'), findsNothing);
    expectTouchTargets(tester);
  });

  testWidgets('no microphone, no test', (tester) async {
    platform.mic = false;
    await pumpApp(tester);
    await tester.tap(find.text('Nur erkennen'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mikrofon'), findsOneWidget);
    expect(find.text('Sprechen'), findsNothing);
  });

  testWidgets('results can be copied for the chat', (tester) async {
    await log.add(const RunResult(
      mode: SpikeMode.parallelPlugin,
      itemId: 's1',
      transcript: 'die kiste',
      werRaw: 0.8,
      werNormalized: 0.8,
      msToText: 900,
      recording: RecordingInfo(seconds: 3, peakDbfs: -160, bytes: 0),
      recognizerEndedEarly: false,
    ));
    await pumpApp(tester);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('results')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.byKey(const ValueKey('results')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('results')));
    await tester.pumpAndSettle();
    expect(find.text('Die Aufnahme ist stumm.'), findsOneWidget);
    expectTouchTargets(tester);
    await tester.tap(find.text('Ergebnis kopieren'));
    await tester.pumpAndSettle();
    expect(clipboard.single, contains('Acme Testphone'));
    expect(find.text('Kopiert. Jetzt im Chat einfügen.'), findsOneWidget);
  });

  test('UI code has no German text literals; all UI text is in the ARB files',
      () {
    final literal = RegExp(r"'(?:[^'\\]|\\.)*'");
    final german = RegExp(r'[äöüÄÖÜß]|\b[A-ZÄÖÜ][a-zäöüß]+ [a-zäöüß]+');
    final offenders = <String>[];
    for (final f in Directory('lib/src/ui').listSync().whereType<File>()) {
      for (final m in literal.allMatches(f.readAsStringSync())) {
        final s = m.group(0)!;
        if (s.startsWith("'package:") || s.startsWith("'../")) continue;
        if (german.hasMatch(s)) offenders.add('${f.path}: $s');
      }
    }
    expect(offenders, isEmpty);
  });
}
