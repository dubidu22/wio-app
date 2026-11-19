import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/notes/note_screen.dart';
import 'package:wio_app/pictures/picture_screen.dart';
import 'package:wio_app/pictures/picture_tile.dart';
import 'package:wio_app/rooms/room_screen.dart';

import '../support/fake_player.dart';
import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';
import '../support/ux_guidelines.dart';

const String _customer = '/customers/${TestIds.familieBeispiel}';
const String _kueche = '$_customer/rooms/${TestIds.kueche}';

/// A note time as cards show it, in the device's time zone.
String _time(int hour, int minute) {
  final local = DateTime.utc(2026, 11, 19, hour, minute).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'Do. ${local.day}.${local.month}., '
      '${two(local.hour)}:${two(local.minute)}';
}

Finder _button(String word) => find.ancestor(
  of: find.text(word),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

/// The card that holds [text].
Finder _card(String text) => find.ancestor(
  of: find.textContaining(text),
  matching: find.byType(DecoratedBox),
);

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithNotes(db);
  });
  tearDown(() => db.close());

  Future<T> run<T>(WidgetTester tester, Future<T> Function() body) async =>
      (await tester.runAsync(body)) as T;

  Future<Note> note(WidgetTester tester, String id) => run(
    tester,
    () => (db.select(db.notes)..where((n) => n.id.equals(id))).getSingle(),
  );

  Future<int> outbox(WidgetTester tester) =>
      run(tester, () => db.select(db.outbox).get().then((r) => r.length));

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the room lists its live notes, oldest first (D-298)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
    );
    await scrollTo(tester, find.text('Notiz schreiben'));

    expect(find.text('Notizen'), findsOneWidget);
    expect(
      find.text('${_time(8, 41)} · 0:45'),
      findsOneWidget,
      reason: 'D-306',
    );
    expect(find.text('${_time(8, 50)} · 0:12'), findsOneWidget);
    expect(find.text('Noch nicht gesendet'), findsOneWidget, reason: 'D-306');
    expect(find.textContaining('Schlüssel liegt'), findsOneWidget);
    expect(find.text('Gelöschte Notiz'), findsNothing);
    expect(find.text('Regal wird abgebaut.'), findsNothing, reason: 'picture');
    expect(
      find.text('Bitte vorher anrufen, Klingel geht nicht.'),
      findsNothing,
      reason: 'customer',
    );

    final times = <double>[
      for (final t in <String>['08:41', '08:50', 'Noch nicht gesendet'])
        tester.getTopLeft(find.textContaining(t)).dy,
    ];
    expect(times, orderedEquals(List<double>.of(times)..sort()));

    final long = tester.widget<Text>(find.textContaining('Kiste mit Winter'));
    expect(long.maxLines, 4, reason: 'D-308');

    // Abspielen only where the recording is on the device (D-305).
    expect(_button('Abspielen'), findsOneWidget);
    expect(_button('Öffnen'), findsNWidgets(3));
    expect(
      find.text('Aufnahme ist noch nicht auf diesem Gerät.'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _card('Herd bleibt'),
        matching: find.text('Abspielen'),
      ),
      findsNothing,
      reason: 'never a dead Abspielen',
    );
    await expectMeetsUxRules(tester);
  });

  testWidgets('the customer and the picture list their own notes', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _customer,
      mediaFolder: demoMediaFolder(),
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    expect(
      find.text('Bitte vorher anrufen, Klingel geht nicht.'),
      findsOneWidget,
    );
    expect(find.textContaining('Kiste mit Winter'), findsNothing);
    await expectMeetsUxRules(tester);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/pictures/${TestIds.fotoRegal}',
      mediaFolder: demoMediaFolder(),
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    expect(find.text('Regal wird abgebaut.'), findsOneWidget);
    expect(find.text('${_time(8, 8)} · 0:08'), findsOneWidget);
    await expectMeetsUxRules(tester);
  });

  testWidgets('Abspielen plays, Stopp stops, one note at a time (D-301)', (
    tester,
  ) async {
    final player = FakeNotePlayer();
    final folder = demoMediaFolder();
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: folder,
      notePlayer: player,
    );
    await scrollTo(tester, find.text('Notiz schreiben'));

    await tester.tap(_button('Abspielen'));
    await tester.pumpAndSettle();
    expect(player.played, <String>['$folder/${DemoFiles.noteAudio}']);
    expect(_button('Stopp'), findsOneWidget);
    expect(find.text('Läuft · 0:00 / 0:45'), findsOneWidget);
    player.at(const Duration(seconds: 12));
    await tester.pump();
    expect(find.text('Läuft · 0:12 / 0:45'), findsOneWidget);
    await expectMeetsUxRules(tester);

    await tester.tap(_button('Stopp'));
    await tester.pumpAndSettle();
    expect(player.stops, 1);
    expect(_button('Abspielen'), findsOneWidget);
    expect(find.text('${_time(8, 41)} · 0:45'), findsOneWidget);

    // The end of the file brings Abspielen back.
    await tester.tap(_button('Abspielen'));
    await tester.pumpAndSettle();
    player.end();
    await tester.pump();
    expect(_button('Abspielen'), findsOneWidget);

    // The app going to the background stops it.
    await tester.tap(_button('Abspielen'));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(player.playback.value.noteId, isNull);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  });

  testWidgets('leaving the screen stops the note', (tester) async {
    final player = FakeNotePlayer();
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
      notePlayer: player,
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    await tester.tap(_button('Abspielen'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Zurück'));
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(player.playback.value.noteId, isNull);
    expect(player.stops, 1);
  });

  testWidgets('a failed start shows a plain hint (rule 7)', (tester) async {
    final player = FakeNotePlayer()..fail = true;
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
      notePlayer: player,
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    await tester.tap(_button('Abspielen'));
    await tester.pumpAndSettle();
    expect(find.text('Die Aufnahme lässt sich nicht abspielen.'), findsOne);
    expect(_button('Abspielen'), findsOneWidget, reason: 'can try again');
  });

  testWidgets('without the media folder every recording is a hint (web)', (
    tester,
  ) async {
    await pumpWioApp(tester, db: db, location: _kueche);
    await scrollTo(tester, find.text('Notiz schreiben'));
    expect(find.text('Abspielen'), findsNothing);
    expect(
      find.text('Aufnahme ist noch nicht auf diesem Gerät.'),
      findsNWidgets(2),
    );
  });

  testWidgets('a corrected transcript becomes manual, one change (D-302)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    await tester.tap(
      find.descendant(
        of: _card('Kiste mit Winter'),
        matching: _button('Öffnen'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NoteScreen), findsOneWidget);
    expect(find.text('Text zur Aufnahme'), findsOneWidget);
    expect(_button('Abspielen'), findsOneWidget);
    expect(_button('Löschen'), findsOneWidget);
    await expectMeetsUxRules(tester);

    // Fertig without a change writes nothing.
    final before = await outbox(tester);
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    expect(await outbox(tester), before);
    expect(find.byType(RoomScreen), findsOneWidget);

    await scrollTo(tester, find.text('Notiz schreiben'));
    await tester.tap(
      find.descendant(
        of: _card('Kiste mit Winter'),
        matching: _button('Öffnen'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Kiste mit Winterjacken');
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    final changed = await note(tester, TestIds.notizSprache);
    expect(changed.transcript, 'Kiste mit Winterjacken');
    expect(changed.transcriptSource, 'manual');
    expect(changed.audioSha256, DemoFiles.noteAudio, reason: 'hash stays');
    expect(changed.audioSeconds, 45);
    expect(await outbox(tester), before + 1, reason: 'one sync change');
    expect(find.text('Kiste mit Winterjacken'), findsOneWidget);
  });

  testWidgets('an emptied transcript is removed; back saves too', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/notizen/${TestIds.notizSprache}',
      mediaFolder: demoMediaFolder(),
    );
    await tester.enterText(find.byType(TextField), '   ');
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    unawaited(navigator.maybePop());
    await tester.pumpAndSettle();
    expect(find.byType(RoomScreen), findsOneWidget);
    final changed = await note(tester, TestIds.notizSprache);
    expect(changed.transcript, isNull);
    expect(changed.transcriptSource, isNull);
    expect(changed.audioSha256, DemoFiles.noteAudio);
  });

  testWidgets('the app going to the background saves the field', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/notizen/${TestIds.notizText}',
    );
    await tester.enterText(find.byType(TextField), 'Schlüssel im Briefkasten');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 50));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    final changed = await note(tester, TestIds.notizText);
    expect(changed.noteText, 'Schlüssel im Briefkasten');
    expect(changed.transcriptSource, isNull);
  });

  testWidgets('an emptied text note keeps its text (D-303)', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/notizen/${TestIds.notizText}',
    );
    expect(find.text('Notiz'), findsNWidgets(2), reason: 'title and label');
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(
      find.text('Leere Notiz wird nicht gespeichert. Zum Entfernen: Löschen.'),
      findsOneWidget,
    );
    final before = await outbox(tester);
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    expect(await outbox(tester), before);
    expect(
      (await note(tester, TestIds.notizText)).noteText,
      'Schlüssel liegt beim Nachbarn im Erdgeschoss.',
    );
  });

  testWidgets('Notiz schreiben adds a text note (D-304)', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    await tester.tap(find.text('Notiz schreiben'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteScreen), findsOneWidget);
    expect(_button('Löschen'), findsNothing, reason: 'nothing to delete');
    await expectMeetsUxRules(tester);

    await tester.enterText(find.byType(TextField), 'Katze nicht rauslassen');
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    final added = await run(
      tester,
      () => (db.select(
        db.notes,
      )..where((n) => n.noteText.equals('Katze nicht rauslassen'))).getSingle(),
    );
    expect(added.subjectType, 'room');
    expect(added.subjectId, TestIds.kueche);
    expect(added.customerId, TestIds.familieBeispiel);
    expect(added.audioSha256, isNull, reason: 'same row shape, no file');
    expect(added.transcript, isNull);
    expect(find.text('Katze nicht rauslassen'), findsOneWidget);
  });

  testWidgets('a new note left empty saves nothing (rule 4)', (tester) async {
    await pumpWioApp(tester, db: db, location: '$_customer/notizen/neu');
    final before = await run(tester, () => db.select(db.notes).get());
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    expect(
      await run(tester, () => db.select(db.notes).get()),
      hasLength(before.length),
    );
  });

  testWidgets('a new note saved in the background is added once', (
    tester,
  ) async {
    await pumpWioApp(tester, db: db, location: '$_customer/notizen/neu');
    await tester.enterText(find.byType(TextField), 'Erst');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 50));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Erst anrufen');
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    final added = await run(
      tester,
      () => db.select(db.notes).get(),
    ).then((all) => all.where((n) => n.noteText?.startsWith('Erst') ?? false));
    expect(added.map((n) => n.noteText), <String>['Erst anrufen']);
    expect(added.single.subjectType, 'customer');
  });

  testWidgets('Löschen goes back at once and Rückgängig brings it back', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    await tester.tap(
      find.descendant(
        of: _card('Schlüssel liegt'),
        matching: _button('Öffnen'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_button('Löschen'));
    await tester.tap(_button('Löschen'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(find.byType(Dialog), findsNothing, reason: 'UX rule 9');
    expect(find.text('Notiz gelöscht.'), findsOneWidget);
    expect((await note(tester, TestIds.notizText)).deletedAt, isNotNull);
    final deletes = await run(
      tester,
      () => (db.select(db.outbox)..where((o) => o.op.equals('delete'))).get(),
    );
    expect(deletes, hasLength(1), reason: 'one delete for a double tap');
    await scrollTo(tester, find.text('Notiz schreiben'));
    expect(find.textContaining('Schlüssel liegt'), findsNothing);

    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snack.duration, const Duration(seconds: 8));
    await tester.tap(find.widgetWithText(SnackBarAction, 'Rückgängig'));
    await tester.pumpAndSettle();
    expect((await note(tester, TestIds.notizText)).deletedAt, isNull);
    expect(find.textContaining('Schlüssel liegt'), findsOneWidget);
  });

  testWidgets('Löschen while the note plays stops it first', (tester) async {
    final player = FakeNotePlayer();
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/notizen/${TestIds.notizSprache}',
      mediaFolder: demoMediaFolder(),
      notePlayer: player,
    );
    await tester.tap(_button('Abspielen'));
    await tester.pumpAndSettle();
    expect(_button('Stopp'), findsOneWidget);
    await tester.tap(_button('Löschen'));
    await tester.pumpAndSettle();
    expect(player.playback.value.noteId, isNull);
  });

  testWidgets('an unknown note is a plain hint', (tester) async {
    await pumpWioApp(tester, db: db, location: '$_kueche/notizen/unbekannt');
    expect(find.text('Diese Notiz gibt es nicht mehr.'), findsOneWidget);
    expect(_button('Löschen'), findsNothing);
  });

  testWidgets('Sprechen stops a playing note (D-301)', (tester) async {
    final player = FakeNotePlayer();
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
      notePlayer: player,
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    await tester.tap(_button('Abspielen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sprechen'));
    await tester.pump(const Duration(seconds: 1));
    expect(player.playback.value.noteId, isNull);
  });

  group('opening another screen stops a playing card (PR 74 S1)', () {
    Future<FakeNotePlayer> playKueche(WidgetTester tester) async {
      final player = FakeNotePlayer();
      await pumpWioApp(
        tester,
        db: db,
        location: _kueche,
        mediaFolder: demoMediaFolder(),
        notePlayer: player,
      );
      await scrollTo(tester, find.text('Notiz schreiben'));
      await tester.tap(_button('Abspielen'));
      await tester.pumpAndSettle();
      expect(player.playback.value.noteId, TestIds.notizSprache);
      return player;
    }

    testWidgets('a picture tile', (tester) async {
      final player = await playKueche(tester);
      final tile = find
          .descendant(of: find.byType(PictureGrid), matching: _button('Öffnen'))
          .first;
      // Back to the top, where the pictures are.
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, 3000),
        3000,
      );
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.byType(PictureScreen), findsOneWidget);
      await tester.pumpAndSettle();
      expect(player.playback.value.noteId, isNull);
    });

    testWidgets('Fotos', (tester) async {
      final player = await playKueche(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Fotos'));
      await tester.pump(const Duration(seconds: 1));
      expect(player.playback.value.noteId, isNull);
    });

    testWidgets('Öffnen on another note', (tester) async {
      final player = await playKueche(tester);
      await tester.tap(
        find.descendant(
          of: _card('Schlüssel liegt'),
          matching: _button('Öffnen'),
        ),
      );
      await tester.pumpAndSettle();
      expect(player.playback.value.noteId, isNull);
    });

    testWidgets('Öffnen on the playing note keeps it playing', (tester) async {
      final player = await playKueche(tester);
      await tester.tap(
        find.descendant(
          of: _card('Kiste mit Winter'),
          matching: _button('Öffnen'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NoteScreen), findsOneWidget);
      expect(player.playback.value.noteId, TestIds.notizSprache);
      expect(_button('Stopp'), findsOneWidget);
    });
  });

  testWidgets('card buttons name their note for screen readers (rule 1)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
    );
    await scrollTo(tester, find.text('Notiz schreiben'));
    final line = '${_time(8, 41)} · 0:45';
    expect(find.bySemanticsLabel('Notiz von $line abspielen'), findsOneWidget);
    expect(find.bySemanticsLabel('Notiz von $line öffnen'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Notiz von Noch nicht gesendet öffnen'),
      findsOneWidget,
    );
    await tester.tap(_button('Abspielen'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Notiz von $line anhalten'), findsOneWidget);
    handle.dispose();
  });
}
