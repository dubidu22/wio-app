// The entry screen (plan 103, P1..P8): what it shows, what its buttons open
// and write, delete with undo.
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/camera/camera_providers.dart';
import 'package:wio_app/camera/camera_screen.dart';
import 'package:wio_app/camera/capture_files.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/entries/entry_screen.dart';
import 'package:wio_app/entries/entry_title_screen.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/notes/note_screen.dart';
import 'package:wio_app/pictures/picture_screen.dart';
import 'package:wio_app/planning/place_screen.dart';
import 'package:wio_app/sync/upload_queue.dart';
import 'package:wio_app/voice/voice_screen.dart';

import '../support/fake_camera.dart';
import '../support/fake_voice.dart';
import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';
import '../support/ux_guidelines.dart';

const String _customer = '/customers/${TestIds.familieBeispiel}';
const String _kiste = '$_customer/entries/${TestIds.kiste}';
const String _ohneOrt = '$_customer/entries/${TestIds.kisteOhneOrt}';

Finder _button(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(OutlinedButton));

Future<Entry> _entry(WidgetTester tester, WioDatabase db, String id) async =>
    (await tester.runAsync(
      () => (db.select(db.entries)..where((e) => e.id.equals(id))).getSingle(),
    ))!;

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithEntryContent(db);
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, String location) => pumpWioApp(
    tester,
    db: db,
    location: location,
    mediaFolder: demoMediaFolder(),
  );

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows name, code, pictures, notes, place, target and history', (
    tester,
  ) async {
    await pump(tester, _kiste);

    expect(find.byType(EntryScreen), findsOneWidget);
    expect(find.text('Kiste Geschirr'), findsOneWidget);
    expect(find.text('Code: WIO-0042'), findsOneWidget);
    expect(find.text('Fotos'), findsWidgets);
    expect(find.text('Noch keine Fotos.'), findsNothing);
    // The entry's two pictures, before and after; no other picture.
    expect(find.text('Nachher'), findsOneWidget);

    await scrollTo(tester, find.text('Notiz schreiben'));
    expect(find.text('Notizen'), findsOneWidget);
    expect(find.textContaining('Gläser einzeln'), findsOneWidget);

    await scrollTo(tester, find.text('Verlauf'));
    expect(find.text('Küche, Boden'), findsWidgets);
    expect(find.text('Ziel: Wohnzimmer'), findsOneWidget);
    // The history is below the place line.
    expect(
      tester.getTopLeft(find.text('Verlauf')).dy,
      greaterThan(tester.getTopLeft(find.text('Ziel: Wohnzimmer')).dy),
    );
    await scrollTo(tester, _button('Löschen'));
    expect(_button('Löschen'), findsOneWidget);
  });

  testWidgets('the name is the title, else the code, else a plain word', (
    tester,
  ) async {
    await pump(tester, _ohneOrt);
    expect(find.text('Eintrag ohne Namen'), findsOneWidget);
    expect(find.textContaining('Code:'), findsNothing);
    expect(find.text('Noch keine Fotos.'), findsOneWidget);
    await scrollTo(tester, find.text('Noch kein Verlauf.'));
    expect(find.text('Noch nicht abgelegt'), findsOneWidget);
    expect(find.text('Kein Ziel'), findsOneWidget);
  });

  testWidgets('an entry that is not there shows a hint and Zurück', (
    tester,
  ) async {
    await pump(tester, '$_customer/entries/${TestIds.fremdeKiste}');
    expect(find.text('Diesen Eintrag gibt es nicht mehr.'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Zurück'), findsOneWidget);
    expect(_button('Löschen'), findsNothing);
  });

  testWidgets('Ort ändern and Ziel open the pickers and come back here', (
    tester,
  ) async {
    await pump(tester, _kiste);
    await scrollTo(tester, _button('Ort ändern'));
    await tester.tap(_button('Ort ändern'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceScreen), findsOneWidget);
    await tester.tap(_button('Wohnzimmer'));
    await tester.pumpAndSettle();
    await tester.tap(_button('Boden'));
    await tester.pumpAndSettle();

    expect(find.byType(EntryScreen), findsOneWidget);
    expect(
      (await _entry(tester, db, TestIds.kiste)).roomId,
      TestIds.wohnzimmer,
    );
    await scrollTo(tester, find.text('Verlauf'));
    // The place line and the newest history row.
    expect(find.text('Wohnzimmer, Boden'), findsWidgets);

    await scrollTo(tester, _button('Ziel'));
    await tester.tap(_button('Ziel'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceScreen), findsOneWidget);
    await tester.tap(_button('Kein Ziel'));
    await tester.pumpAndSettle();
    expect(find.byType(EntryScreen), findsOneWidget);
    expect((await _entry(tester, db, TestIds.kiste)).targetRoomId, isNull);
    await scrollTo(tester, find.text('Kein Ziel'));
  });

  testWidgets('Titel ändern saves on Fertig; empty clears the title', (
    tester,
  ) async {
    await pump(tester, _kiste);
    await tester.tap(_button('Titel ändern'));
    await tester.pumpAndSettle();
    expect(find.byType(EntryTitleScreen), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Fertig'), findsOneWidget);
    expect(find.textContaining('Pflicht'), findsNothing);

    await tester.enterText(find.byType(TextField), '  Gläser Küche ');
    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();
    expect(find.byType(EntryScreen), findsOneWidget);
    expect(find.text('Gläser Küche'), findsOneWidget);
    expect(
      (await _entry(tester, db, TestIds.kiste)).title,
      'Gläser Küche',
      reason: 'trimmed',
    );

    await tester.tap(_button('Titel ändern'));
    await tester.pumpAndSettle();
    expect(find.text('Gläser Küche'), findsOneWidget, reason: 'filled');
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();
    expect((await _entry(tester, db, TestIds.kiste)).title, isNull);
    // The code names it now.
    expect(find.text('WIO-0042'), findsOneWidget);
  });

  testWidgets('Fertig without a change queues nothing', (tester) async {
    await pump(tester, _kiste);
    await tester.tap(_button('Titel ändern'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(() => db.select(db.outbox).get()), isEmpty);
  });

  testWidgets('a picture opens under the entry and Löschen returns here', (
    tester,
  ) async {
    await pump(tester, _kiste);
    final tiles = find.widgetWithText(OutlinedButton, 'Öffnen');
    await tester.tap(tiles.first);
    await tester.pumpAndSettle();
    expect(find.byType(PictureScreen), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Löschen'));
    await tester.pumpAndSettle();
    expect(find.byType(EntryScreen), findsOneWidget);
    expect(find.text('Foto gelöscht.'), findsOneWidget);
  });

  testWidgets('a picture of another entry is not found under this one', (
    tester,
  ) async {
    await pump(tester, '$_ohneOrt/pictures/${TestIds.fotoKiste}');
    expect(find.text('Dieses Foto gibt es nicht mehr.'), findsOneWidget);
  });

  testWidgets('a text note under the entry has the subject entry', (
    tester,
  ) async {
    await pump(tester, _kiste);
    await scrollTo(tester, find.text('Notiz schreiben'));
    await tester.tap(find.text('Notiz schreiben'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Nicht stapeln');
    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();

    expect(find.byType(EntryScreen), findsOneWidget);
    final note = (await tester.runAsync(
      () => (db.select(
        db.notes,
      )..where((n) => n.noteText.equals('Nicht stapeln'))).getSingle(),
    ))!;
    expect(note.subjectType, 'entry');
    expect(note.subjectId, TestIds.kiste);
  });

  testWidgets('Löschen deletes at once, Rückgängig brings it back', (
    tester,
  ) async {
    await pump(tester, _kiste);
    await scrollTo(tester, _button('Löschen'));
    await tester.tap(_button('Löschen'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerScreen), findsOneWidget);
    expect(find.byType(Dialog), findsNothing, reason: 'UX rule 9');
    expect(find.text('Eintrag gelöscht.'), findsOneWidget);
    expect((await _entry(tester, db, TestIds.kiste)).deletedAt, isNotNull);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Rückgängig'));
    await tester.pumpAndSettle();
    expect((await _entry(tester, db, TestIds.kiste)).deletedAt, isNull);
  });

  testWidgets('Rückgängig says so when another entry took the code', (
    tester,
  ) async {
    await pump(tester, _kiste);
    await scrollTo(tester, _button('Löschen'));
    await tester.tap(_button('Löschen'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () =>
          (db.update(db.entries)
                ..where((e) => e.id.equals(TestIds.kisteOhneOrt)))
              .write(const EntriesCompanion(code: Value<String?>('WIO-0042'))),
    );

    await tester.tap(find.widgetWithText(SnackBarAction, 'Rückgängig'));
    await tester.pumpAndSettle();
    expect(
      find.text('Rückgängig nicht möglich: Der Code ist schon vergeben.'),
      findsOneWidget,
    );
    expect((await _entry(tester, db, TestIds.kiste)).deletedAt, isNotNull);
  });

  testWidgets('where nothing takes pictures (web) there is no bottom bar', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kiste,
      mediaFolder: demoMediaFolder(),
      overrides: <Override>[canTakePicturesProvider.overrideWithValue(false)],
    );
    expect(find.widgetWithText(FilledButton, 'Fotos'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Sprechen'), findsNothing);
    expect(find.byType(EntryScreen), findsOneWidget);
    await scrollTo(tester, find.text('Verlauf'));
    await scrollTo(tester, _button('Löschen'));
  });

  group('with a camera and a microphone', () {
    late Directory folder;
    late FakeVoiceRecorder recorder;
    late FakeCamera camera;

    setUp(() {
      folder = Directory.systemTemp.createTempSync('entry_screen_test');
      recorder = FakeVoiceRecorder(writeFile: true);
      camera = FakeCamera(folder: '${folder.path}/shots');
    });
    tearDown(() => folder.deleteSync(recursive: true));

    Future<void> pumpDevice(WidgetTester tester, String location) => pumpWioApp(
      tester,
      db: db,
      location: location,
      camera: () => camera,
      voiceRecorder: recorder,
      mediaStore: MediaStore(() async => '${folder.path}/support'),
      uploadStore: UploadStore(() async => '${folder.path}/support'),
      captureFiles: CaptureFiles(() async => '${folder.path}/temp'),
      mediaFolder: demoMediaFolder(),
    );

    testWidgets('Fotos is the main button and opens the entry camera', (
      tester,
    ) async {
      await pumpDevice(tester, _kiste);
      expect(find.byType(FilledButton), findsOneWidget, reason: 'one main');
      expect(find.widgetWithText(OutlinedButton, 'Sprechen'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Fotos'));
      await tester.pumpAndSettle();
      expect(find.byType(CameraScreen), findsOneWidget);
      expect(find.text('Kiste Geschirr'), findsOneWidget, reason: 'title');
    });

    testWidgets('Sprechen opens the voice note of the entry; Fertig returns', (
      tester,
    ) async {
      await pumpDevice(tester, _kiste);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Sprechen'));
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(find.byType(VoiceScreen), findsOneWidget);
      expect(recorder.started, 1);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Kiste Geschirr'),
        ),
        findsOneWidget,
        reason: 'the entry names the voice screen',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
      for (var i = 0; i < 100; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump(const Duration(milliseconds: 20));
        if (find.byType(VoiceScreen).evaluate().isEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(EntryScreen), findsOneWidget);
    });

    testWidgets('the after camera of an entry picture returns to the picture', (
      tester,
    ) async {
      await pumpDevice(tester, '$_kiste/pictures/${TestIds.fotoKiste}/nachher');
      expect(find.byType(CameraScreen), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
      await tester.pumpAndSettle();
      expect(find.byType(PictureScreen), findsOneWidget);
    });

    testWidgets('every control is at least 56 px and labelled', (tester) async {
      await pumpDevice(tester, _kiste);
      await expectMeetsUxRules(tester);
    });
  });
}
