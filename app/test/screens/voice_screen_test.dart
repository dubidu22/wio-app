// The voice note screen (plan 060 tests T1 to T9; D-284..D-297).
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/camera/capture_files.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/pictures/picture_screen.dart';
import 'package:wio_app/rooms/room_screen.dart';
import 'package:wio_app/sync/upload_queue.dart';
import 'package:wio_app/voice/voice_recorder.dart';
import 'package:wio_app/voice/voice_screen.dart';

import '../support/fake_voice.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String _customer = '/customers/${TestIds.familieBeispiel}';
const String _kueche = '$_customer/rooms/${TestIds.kueche}';

Finder _speak() => find.widgetWithText(OutlinedButton, 'Sprechen');
Finder _stop() => find.widgetWithText(FilledButton, 'Stopp');

void main() {
  late WioDatabase db;
  late Directory folder;
  late FakeVoiceRecorder recorder;

  setUp(() async {
    db = memoryDatabase();
    await seedWithPictures(db);
    folder = Directory.systemTemp.createTempSync('voice_screen_test');
    recorder = FakeVoiceRecorder(writeFile: true);
  });
  tearDown(() async {
    await db.close();
    folder.deleteSync(recursive: true);
  });

  Future<void> pumpVoice(WidgetTester tester, {String location = _kueche}) =>
      pumpWioApp(
        tester,
        db: db,
        location: location,
        voiceRecorder: recorder,
        mediaStore: MediaStore(() async => '${folder.path}/support'),
        uploadStore: UploadStore(() async => '${folder.path}/support'),
        captureFiles: CaptureFiles(() async => '${folder.path}/temp'),
      );

  /// Gives file work real time and the screen its frames until [done].
  Future<void> until(WidgetTester tester, bool Function() done) async {
    for (var turn = 0; turn < 200 && !done(); turn++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      // Short frames, so page transitions finish but the recording's
      // seconds barely move.
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(done(), isTrue);
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> openFrom(WidgetTester tester) async {
    await tester.tap(_speak());
    await tester.pump();
    await until(tester, () => _stop().evaluate().isNotEmpty);
  }

  Future<void> leave(WidgetTester tester) =>
      until(tester, () => find.byType(VoiceScreen).evaluate().isEmpty);

  Future<List<Note>> notes(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.notes).get()))!;

  testWidgets('Sprechen records at once; Stopp keeps note, file and text', (
    tester,
  ) async {
    await pumpVoice(tester);
    expect(_speak(), findsOneWidget);
    await openFrom(tester);

    expect(recorder.started, 1, reason: 'no step before recording (D-288)');
    expect(find.text('Aufnahme läuft · 0:00'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Fertig'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(VoiceScreen),
        matching: find.text('Küche'),
      ),
      findsOneWidget,
    );

    recorder.transcript(TranscriptStatus.ready);
    await tester.pump();
    expect(find.text('Bitte sprechen. Der Text erscheint hier.'), findsOne);
    recorder.partial('Kiste mit');
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Kiste mit'), findsOneWidget, reason: 'D-62');
    expect(find.text('Aufnahme läuft · 0:03'), findsOneWidget);

    await tester.tap(_stop());
    await leave(tester);
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(
      find.text('Notiz gespeichert: „Kiste mit Wintersachen im Keller“'),
      findsOneWidget,
    );
    final note = (await notes(tester)).single;
    expect(note.subjectType, 'room');
    expect(note.subjectId, TestIds.kueche);
    expect(note.transcript, 'Kiste mit Wintersachen im Keller');
    expect(note.transcriptSource, 'device');
    expect(note.audioSeconds, 7);
    final uploads = (await tester.runAsync(() => db.select(db.uploads).get()))!;
    expect(uploads.single.sha256, note.audioSha256);
    expect(
      Directory('${folder.path}/temp/wio-capture').listSync(),
      isEmpty,
      reason: 'working file deleted',
    );
  });

  for (final status in <TranscriptStatus>[
    TranscriptStatus.noOnDevice,
    TranscriptStatus.androidTooOld,
  ]) {
    testWidgets('guard ${status.name}: records only, says so (D-61)', (
      tester,
    ) async {
      recorder.take = const VoiceTake(length: Duration(seconds: 5));
      await pumpVoice(tester);
      await openFrom(tester);
      recorder.transcript(status);
      await tester.pump();
      expect(
        find.text(
          'Auf diesem Telefon gibt es keinen Text zur Aufnahme. '
          'Die Aufnahme wird trotzdem gespeichert.',
        ),
        findsOneWidget,
      );
      expect(find.text('Deutsch laden'), findsNothing);

      await tester.tap(_stop());
      await leave(tester);
      expect(find.text('Sprachnotiz gespeichert (ohne Text).'), findsOne);
      final note = (await notes(tester)).single;
      expect(note.audioSha256, isNotNull);
      expect(note.transcript, isNull);
      expect(note.transcriptSource, isNull);
    });
  }

  testWidgets('German missing: Deutsch laden starts the download', (
    tester,
  ) async {
    await pumpVoice(tester);
    await openFrom(tester);
    recorder.transcript(TranscriptStatus.germanMissing);
    await tester.pump();
    expect(
      find.text(
        'Deutsch für die Spracherkennung ist auf diesem Telefon nicht geladen.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Deutsch laden'));
    await tester.pump();
    expect(recorder.downloads, 1);
    expect(find.text('Deutsch laden'), findsNothing);
    expect(
      find.text(
        'Deutsch wird geladen. Bei einer der nächsten Notizen gibt es dann '
        'Text.',
      ),
      findsOneWidget,
    );
    expect(recorder.recording, isTrue, reason: 'recording goes on');
  });

  testWidgets('a refused microphone is a plain hint with Noch einmal fragen', (
    tester,
  ) async {
    recorder
      ..permissionNow = VoicePermission.refused
      ..permissionAfterAsking = VoicePermission.refused;
    await pumpVoice(tester);
    await tester.tap(_speak());
    await until(
      tester,
      () => find.text('Noch einmal fragen').evaluate().isNotEmpty,
    );
    expect(find.text('Wio darf das Mikrofon nicht benutzen.'), findsOneWidget);
    expect(_stop(), findsNothing, reason: 'no dead button');
    expect(recorder.asked, 1);
    expect(recorder.started, 0);

    recorder.permissionAfterAsking = VoicePermission.granted;
    await tester.tap(find.widgetWithText(OutlinedButton, 'Noch einmal fragen'));
    await until(tester, () => _stop().evaluate().isNotEmpty);
    expect(recorder.asked, 2);
    expect(recorder.started, 1);
  });

  testWidgets('a busy microphone is a hint with Noch einmal versuchen', (
    tester,
  ) async {
    recorder.startError = const VoiceUnavailable('busy');
    await pumpVoice(tester);
    await tester.tap(_speak());
    await until(
      tester,
      () => find.text('Noch einmal versuchen').evaluate().isNotEmpty,
    );
    expect(
      find.text('Das Mikrofon lässt sich gerade nicht benutzen.'),
      findsOneWidget,
    );
    expect(_stop(), findsNothing);

    recorder.startError = null;
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Noch einmal versuchen'),
    );
    await until(tester, () => _stop().evaluate().isNotEmpty);
    expect(recorder.started, 1);
    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await leave(tester);
  });

  testWidgets('Fertig keeps the note (D-291)', (tester) async {
    await pumpVoice(tester);
    await openFrom(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await leave(tester);
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(await notes(tester), hasLength(1));
  });

  testWidgets('system back keeps the note (D-291)', (tester) async {
    await pumpVoice(tester);
    await openFrom(tester);
    await tester.binding.handlePopRoute();
    await leave(tester);
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(await notes(tester), hasLength(1));
  });

  testWidgets('leaving the app keeps the note (D-291)', (tester) async {
    await pumpVoice(tester);
    await openFrom(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await leave(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(recorder.stopped, 1);
    expect(await notes(tester), hasLength(1));
  });

  testWidgets('after 10 minutes the note stops and is kept (D-292)', (
    tester,
  ) async {
    await pumpVoice(tester);
    await openFrom(tester);
    await tester.pump(const Duration(minutes: 9, seconds: 59));
    expect(find.text('Aufnahme läuft · 9:59'), findsOneWidget);
    expect(recorder.stopped, 0);
    await tester.pump(const Duration(seconds: 1));
    await leave(tester);
    expect(recorder.stopped, 1);
    expect(await notes(tester), hasLength(1));
  });

  testWidgets('a recording under half a second is not kept (D-292)', (
    tester,
  ) async {
    recorder.take = const VoiceTake(length: Duration(milliseconds: 300));
    await pumpVoice(tester);
    await openFrom(tester);
    await tester.tap(_stop());
    await leave(tester);
    expect(find.text('Die Aufnahme war zu kurz.'), findsOneWidget);
    expect(await notes(tester), isEmpty);
  });

  testWidgets('Sprechen on a picture keeps a note about the picture', (
    tester,
  ) async {
    await pumpVoice(
      tester,
      location: '$_kueche/pictures/${TestIds.fotoVorher}',
    );
    expect(find.byType(PictureScreen), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Löschen'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Nachher aufnehmen'), findsOne);
    await openFrom(tester);
    expect(find.text('Notiz zum Foto'), findsOneWidget);
    await tester.tap(_stop());
    await leave(tester);
    expect(find.byType(PictureScreen), findsOneWidget);
    final note = (await notes(tester)).single;
    expect(note.subjectType, 'picture');
    expect(note.subjectId, TestIds.fotoVorher);
  });

  testWidgets('Sprechen on the customer keeps a note about the customer', (
    tester,
  ) async {
    await pumpVoice(tester, location: _customer);
    expect(find.widgetWithText(FilledButton, 'Fotos'), findsOneWidget);
    await openFrom(tester);
    await tester.tap(_stop());
    await leave(tester);
    expect(find.byType(CustomerScreen), findsOneWidget);
    final note = (await notes(tester)).single;
    expect(note.subjectType, 'customer');
    expect(note.subjectId, TestIds.familieBeispiel);
  });

  testWidgets('no Sprechen where the app does not record (web, iOS)', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      for (final location in <String>[
        _customer,
        _kueche,
        '$_kueche/pictures/${TestIds.fotoVorher}',
      ]) {
        await pumpVoice(tester, location: location);
        expect(_speak(), findsNothing, reason: location);
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
