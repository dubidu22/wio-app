// Place and target pickers (plan 107, D-450..D-456): every tap writes at
// most one change, with the full field set; the current place or target
// writes none.
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/planning/place_screen.dart';
import 'package:wio_app/planning/spot_screen.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

const String _base = '/customers/${TestIds.familieBeispiel}/entries';

Finder _button(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(OutlinedButton));

Future<List<OutboxData>> _outbox(WioDatabase db) => db.select(db.outbox).get();

Map<String, Object?> _fields(OutboxData row) =>
    jsonDecode(row.fields) as Map<String, Object?>;

Future<Entry> _entry(WioDatabase db, String id) =>
    (db.select(db.entries)..where((e) => e.id.equals(id))).getSingle();

const Map<String, Object?> _noPlace = <String, Object?>{
  'site_id': null,
  'room_id': null,
  'fixture_id': null,
  'level': null,
  'compartment': null,
  'floor_x_cm': null,
  'floor_y_cm': null,
};

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithEntries(db);
  });
  tearDown(() => db.close());

  testWidgets('room, then Boden: one move_entry with all seven fields', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_base/${TestIds.kisteOhneOrt}/ort',
    );
    expect(find.text('Jetzt: Noch nicht abgelegt'), findsOneWidget);
    // Nothing to clear yet.
    expect(find.text('Nicht abgelegt'), findsNothing);

    await tester.tap(_button('Keller'));
    await tester.pumpAndSettle();
    expect(find.byType(SpotScreen), findsOneWidget);
    expect(await _outbox(db), isEmpty);

    await tester.tap(_button('Boden'));
    await tester.pumpAndSettle();

    final outbox = await _outbox(db);
    expect(outbox, hasLength(1));
    expect(outbox.single.op, 'move_entry');
    expect(outbox.single.entityId, TestIds.kisteOhneOrt);
    expect(_fields(outbox.single), <String, Object?>{
      ..._noPlace,
      'site_id': TestIds.alteWohnung,
      'room_id': TestIds.keller,
    });
    final entry = await _entry(db, TestIds.kisteOhneOrt);
    expect(entry.roomId, TestIds.keller);
    // Back to the entry, which shows the customer until #103.
    expect(find.byType(CustomerScreen), findsOneWidget);
  });

  testWidgets('Boden where the entry already lies writes nothing', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_base/${TestIds.kiste}/ort/${TestIds.kueche}',
    );
    expect(find.text('jetzt hier'), findsOneWidget);

    await tester.tap(_button('Boden'));
    await tester.pumpAndSettle();

    expect(await _outbox(db), isEmpty);
    expect(find.byType(CustomerScreen), findsOneWidget);
  });

  testWidgets('Nicht abgelegt: one move_entry with all fields null', (
    tester,
  ) async {
    await pumpWioApp(tester, db: db, location: '$_base/${TestIds.kiste}/ort');
    expect(find.text('Jetzt: Küche, Boden'), findsOneWidget);

    await tester.tap(_button('Nicht abgelegt'));
    await tester.pumpAndSettle();

    final outbox = await _outbox(db);
    expect(outbox, hasLength(1));
    expect(outbox.single.op, 'move_entry');
    expect(_fields(outbox.single), _noPlace);
    expect((await _entry(db, TestIds.kiste)).roomId, isNull);
  });

  testWidgets('marks the current and the target room with words; the '
      "target's site comes first", (tester) async {
    await pumpWioApp(tester, db: db, location: '$_base/${TestIds.kiste}/ort');

    expect(
      find.descendant(of: _button('Küche'), matching: find.text('jetzt hier')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: _button('Wohnzimmer'), matching: find.text('Ziel')),
      findsOneWidget,
    );
    final neue = tester.getTopLeft(find.text('Neue Wohnung'));
    final alte = tester.getTopLeft(find.text('Alte Wohnung'));
    expect(neue.dy, lessThan(alte.dy));
    // The deleted room and other customers' sites are not offered.
    expect(find.text('Abstellraum'), findsNothing);
    expect(find.text('Wohnung Muster'), findsNothing);
  });

  testWidgets('without a target the sites keep their order', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_base/${TestIds.kisteOhneOrt}/ort',
    );
    final neue = tester.getTopLeft(find.text('Neue Wohnung'));
    final alte = tester.getTopLeft(find.text('Alte Wohnung'));
    expect(alte.dy, lessThan(neue.dy));
  });

  testWidgets('Zurück on the spot step goes back to the rooms', (tester) async {
    await pumpWioApp(tester, db: db, location: '$_base/${TestIds.kiste}/ort');
    await tester.tap(_button('Keller'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceScreen), findsOneWidget);
    expect(await _outbox(db), isEmpty);
  });

  testWidgets('Ziel, then a room: one upsert of the seven target fields', (
    tester,
  ) async {
    await pumpWioApp(tester, db: db, location: '$_base/${TestIds.kiste}/ziel');
    expect(find.text('Jetzt: Wohnzimmer'), findsOneWidget);
    expect(
      find.descendant(
        of: _button('Wohnzimmer'),
        matching: find.text('jetziges Ziel'),
      ),
      findsOneWidget,
    );

    await tester.tap(_button('Keller'));
    await tester.pumpAndSettle();

    final outbox = await _outbox(db);
    expect(outbox, hasLength(1));
    expect(outbox.single.op, 'upsert');
    expect(_fields(outbox.single), <String, Object?>{
      for (final MapEntry(:key, :value) in _noPlace.entries)
        'target_$key': value,
      'target_site_id': TestIds.alteWohnung,
      'target_room_id': TestIds.keller,
    });
    final entry = await _entry(db, TestIds.kiste);
    expect(entry.targetRoomId, TestIds.keller);
    // The place is untouched.
    expect(entry.roomId, TestIds.kueche);
  });

  testWidgets('the current target writes nothing', (tester) async {
    await pumpWioApp(tester, db: db, location: '$_base/${TestIds.kiste}/ziel');
    await tester.tap(_button('Wohnzimmer'));
    await tester.pumpAndSettle();
    expect(await _outbox(db), isEmpty);
  });

  testWidgets('Kein Ziel: one upsert with the target fields null', (
    tester,
  ) async {
    await pumpWioApp(tester, db: db, location: '$_base/${TestIds.kiste}/ziel');
    await tester.tap(_button('Kein Ziel'));
    await tester.pumpAndSettle();

    final outbox = await _outbox(db);
    expect(outbox, hasLength(1));
    expect(outbox.single.op, 'upsert');
    expect(_fields(outbox.single), <String, Object?>{
      for (final MapEntry(:key, :value) in _noPlace.entries)
        'target_$key': value,
    });
    expect((await _entry(db, TestIds.kiste)).targetRoomId, isNull);
  });

  testWidgets('an entry in a deleted room says so and can be moved', (
    tester,
  ) async {
    await (db.update(
      db.entries,
    )..where((e) => e.id.equals(TestIds.kiste))).write(
      const EntriesCompanion(roomId: Value<String?>(TestIds.alterRaum)),
    );
    await pumpWioApp(tester, db: db, location: '$_base/${TestIds.kiste}/ort');
    expect(find.text('Jetzt: Raum gelöscht'), findsOneWidget);

    await tester.tap(_button('Keller'));
    await tester.pumpAndSettle();
    await tester.tap(_button('Boden'));
    await tester.pumpAndSettle();
    expect(await _outbox(db), hasLength(1));
  });

  testWidgets("another customer's entry is not shown", (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_base/${TestIds.fremdeKiste}/ort',
    );
    expect(find.text('Diesen Eintrag gibt es nicht mehr.'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('a deleted room has no spot step', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_base/${TestIds.kiste}/ort/${TestIds.alterRaum}',
    );
    expect(find.text('Diesen Raum gibt es nicht mehr.'), findsOneWidget);
    expect(find.text('Boden'), findsNothing);
  });

  testWidgets("the entry's own address shows the customer until #103", (
    tester,
  ) async {
    await pumpWioApp(tester, db: db, location: '$_base/${TestIds.kiste}');
    expect(find.byType(CustomerScreen), findsOneWidget);
  });
}
