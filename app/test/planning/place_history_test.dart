// Place history of an entry (plan 108): newest first, "wird gesendet" until
// the server answers, read only (D-54, D-425, D-440).
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/entry_queries.dart';
import 'package:wio_app/data/entry_writer.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/l10n/app_localizations_de.dart';
import 'package:wio_app/planning/place_history.dart';
import 'package:wio_app/shell/providers.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

/// The section in the app's theme, over [db], with the clock of the tests.
Future<void> _pumpSection(
  WidgetTester tester,
  WioDatabase db, {
  String entryId = TestIds.kiste,
  DateTime? now,
}) async {
  // Drift's stream timers must finish inside the test (as pumpWioApp).
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
  await pumpScreen(
    tester,
    ProviderScope(
      overrides: <Override>[
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now ?? testNow),
      ],
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            PlaceHistorySection(
              customerId: TestIds.familieBeispiel,
              entryId: entryId,
            ),
          ],
        ),
      ),
    ),
  );
}

PlaceStep _step({
  Place from = Place.none,
  Place to = Place.none,
  String movedAt = '2026-11-19T08:30:00.000Z',
  bool pending = false,
}) => PlaceStep(from: from, to: to, movedAt: movedAt, pending: pending);

void main() {
  setUpAll(() => initializeDateFormatting('de'));
  final l10n = AppLocalizationsDe();
  const kueche = Place.room(siteId: 's', roomId: 'k');
  const wohnzimmer = Place.room(siteId: 's', roomId: 'w');
  const names = <String, String?>{'k': 'Küche', 'w': 'Wohnzimmer'};
  bool live(String id) => names.containsKey(id);
  String? name(String id) => names[id];
  final now = DateTime.utc(2026, 11, 23, 12);
  String spoken(PlaceStep s) =>
      placeStepSpoken(l10n, s, now, isLiveRoom: live, roomName: name);

  group('in words', () {
    test('the first placement starts at "Noch nicht abgelegt" (D-425)', () {
      expect(
        spoken(_step(to: kueche, pending: true)),
        'Von Noch nicht abgelegt nach Küche, Boden, wird gesendet',
      );
    });

    test('a move, a clearing and a deleted room', () {
      expect(
        spoken(_step(from: kueche, to: wohnzimmer, pending: true)),
        'Von Küche, Boden nach Wohnzimmer, Boden, wird gesendet',
      );
      expect(
        spoken(_step(from: wohnzimmer, pending: true)),
        'Von Wohnzimmer, Boden nach Noch nicht abgelegt, wird gesendet',
      );
      expect(
        spoken(
          _step(
            from: const Place.room(siteId: 's', roomId: 'x'),
            to: kueche,
            pending: true,
          ),
        ),
        'Von Raum gelöscht nach Küche, Boden, wird gesendet',
      );
    });

    test('date and time in the device zone, the year when it is not this', () {
      final moved = DateTime.parse('2026-11-19T08:30:00.000Z').toLocal();
      expect(placeStepTime(l10n, _step(), now), l10n.placeHistoryTime(moved));
      final old = placeStepTime(
        l10n,
        _step(movedAt: '2025-03-04T09:05:00.000Z'),
        now,
      );
      expect(old, contains('2025'));
      expect(placeStepTime(l10n, _step(), now), isNot(contains('2026')));
    });

    test('an unconfirmed move says "wird gesendet", never the time', () {
      expect(
        placeStepTime(l10n, _step(pending: true), DateTime.utc(2026, 11, 23)),
        'wird gesendet',
      );
    });
  });

  group('the section', () {
    late WioDatabase db;
    setUp(() async {
      db = memoryDatabase();
      await seedWithHistory(db);
    });
    tearDown(() => db.close());

    // The spoken form of each row, "Von X nach Y, <time>", top to bottom.
    List<String> rows(WidgetTester tester) => tester
        .widgetList<Semantics>(find.byType(Semantics))
        .map((s) => s.properties.label ?? '')
        .where((l) => l.startsWith('Von '))
        .toList();

    testWidgets('three server rows, newest first', (tester) async {
      await _pumpSection(tester, db, now: DateTime.utc(2026, 11, 23));
      expect(find.text('Verlauf'), findsOneWidget);
      expect(rows(tester), <String>[
        'Von Wohnzimmer, Boden nach Küche, Boden, Sa. 21.11., 14:05',
        'Von Küche, Boden nach Wohnzimmer, Boden, Fr. 20.11., 10:15',
        'Von Noch nicht abgelegt nach Küche, Boden, Do. 19.11., 08:30',
      ]);
      expect(find.text('wird gesendet'), findsNothing);
    });

    testWidgets('an unsent move is on top and says wird gesendet', (
      tester,
    ) async {
      await EntryWriter(db, LocalWriter(db)).move(
        TestIds.kiste,
        const Place.room(
          siteId: TestIds.neueWohnung,
          roomId: TestIds.wohnzimmer,
        ),
      );
      await _pumpSection(tester, db);
      expect(
        rows(tester).first,
        'Von Küche, Boden nach Wohnzimmer, Boden, wird gesendet',
      );
      expect(find.text('wird gesendet'), findsOneWidget);
    });

    testWidgets('two unsent moves chain from each other', (tester) async {
      final writer = EntryWriter(db, LocalWriter(db));
      await writer.move(TestIds.kiste, Place.none);
      await writer.move(
        TestIds.kiste,
        const Place.room(siteId: TestIds.alteWohnung, roomId: TestIds.keller),
      );
      await _pumpSection(tester, db);
      expect(rows(tester).take(2), <String>[
        'Von Noch nicht abgelegt nach Keller, Boden, wird gesendet',
        'Von Küche, Boden nach Noch nicht abgelegt, wird gesendet',
      ]);
      expect(find.text('wird gesendet'), findsNWidgets(2));
    });

    testWidgets('a move to the place it has adds no row', (tester) async {
      await EntryWriter(db, LocalWriter(db)).move(
        TestIds.kiste,
        const Place.room(siteId: TestIds.alteWohnung, roomId: TestIds.kueche),
      );
      await _pumpSection(tester, db);
      expect(rows(tester), hasLength(3));
      expect(find.text('wird gesendet'), findsNothing);
    });

    testWidgets('a deleted room reads "Raum gelöscht"', (tester) async {
      await (db.update(
        db.rooms,
      )..where((r) => r.id.equals(TestIds.wohnzimmer))).write(
        const RoomsCompanion(
          deletedAt: Value<String?>('2026-11-22T08:00:00.000Z'),
        ),
      );
      await _pumpSection(tester, db);
      expect(
        rows(tester),
        contains(startsWith('Von Raum gelöscht nach Küche, Boden')),
      );
    });

    testWidgets('an entry that was never placed shows the plain hint', (
      tester,
    ) async {
      await _pumpSection(tester, db, entryId: TestIds.kisteOhneOrt);
      expect(find.text('Verlauf'), findsOneWidget);
      expect(find.text('Noch kein Verlauf.'), findsOneWidget);
      expect(rows(tester), isEmpty);
    });

    testWidgets('read only: nothing to tap (D-54)', (tester) async {
      await _pumpSection(tester, db);
      expect(find.byType(ButtonStyleButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });
  });
}
