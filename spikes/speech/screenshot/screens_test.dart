// Renders the spike's screens at 390x844 to PNG files for the PR body.
// Not part of `flutter test` (lives outside test/). Run:
//   SPIKE_FONT=/path/to/Sans.ttf SPIKE_OUT=/tmp/shots flutter test screenshot/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:speech_spike/src/app.dart';
import 'package:speech_spike/src/engine.dart';
import 'package:speech_spike/src/results.dart';
import 'package:speech_spike/src/sentences.dart';
import 'package:speech_spike/src/services.dart';

import '../test/fakes.dart';
import '../test/ui_test.dart' show FakePlatform;

void main() {
  final out = Directory(Platform.environment['SPIKE_OUT'] ?? 'build/screenshots')
    ..createSync(recursive: true);

  setUpAll(() async {
    final font = Platform.environment['SPIKE_FONT'];
    if (font == null) return;
    final bytes = File(font).readAsBytesSync();
    final loader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    final bold = Platform.environment['SPIKE_FONT_BOLD'];
    if (bold != null) {
      loader.addFont(Future.value(ByteData.view(File(bold).readAsBytesSync().buffer)));
    }
    await loader.load();
  });

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('shot')));
    late ui.Image image;
    await tester.runAsync(() async {
      image = await boundary.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('${out.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  testWidgets('screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
    final clock = FakeClock();
    final recognizer = FakeRecognizer(clock)
      ..finalText = 'Die Kiste mit den Wintersachen steht im Keller im 2. Regal oben links'
      ..finalDelay = const Duration(milliseconds: 640);
    final recorder = FakeRecorder(clock)..peakDbfs = -14.2;
    final log = ResultsLog();
    final platform = FakePlatform();
    final services = SpikeServices(
      platform: platform,
      engines: SpikeEngines(
        recognizer: recognizer,
        recorder: recorder,
        oneMic: FakeOneMic(clock),
        fileTranscriber: FakeFileTranscriber(clock),
      ),
      clock: clock,
      results: log,
      recordingPath: (m, i) => '/nonexistent/${m.name}-${i.id}.m4a',
      copyToClipboard: (_) async {},
    );
    await tester.pumpWidget(RepaintBoundary(
        key: const ValueKey('shot'), child: SpikeApp(services: services)));
    await shot(tester, '1-start');

    await tester.tap(find.text('Gleichzeitig'));
    await tester.pumpAndSettle();
    await shot(tester, '2-test-idle');
    await tester.tap(find.text('Sprechen'));
    await tester.pumpAndSettle();
    clock.advance(const Duration(milliseconds: 5300));
    await tester.tap(find.text('Stopp'));
    // Let the real file-size lookup of the run controller finish.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await shot(tester, '3-test-result');

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    platform.status = GuardStatus.germanMissing;
    await tester.tap(find.text('Nur erkennen'));
    await shot(tester, '4-guard-german-missing');

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    await log.add(RunResult(
      mode: SpikeMode.recordThenTranscribe,
      itemId: testItems[3].id,
      transcript: 'der Schrank im Flur ist 180 cm hoch und 60 cm breit',
      werRaw: 0.364,
      werNormalized: 0,
      msToText: 2310,
      recording: const RecordingInfo(seconds: 5.8, peakDbfs: -11.0, bytes: 46200),
      recognizerEndedEarly: false,
    ));
    await tester.scrollUntilVisible(find.byKey(const ValueKey('results')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.byKey(const ValueKey('results')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('results')));
    await shot(tester, '5-results');
  });
}
