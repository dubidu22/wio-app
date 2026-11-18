// Sync in the running app: triggers, back-off, the status line, the hint
// and "Nicht gesendet" (plan 044 tests T16 and T17, D-197, D-201, D-203).
// No real network; the fake sync server answers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/jobs/job_list_screen.dart';
import 'package:wio_app/sync/rejected_screen.dart';
import 'package:wio_app/sync/sync_runner.dart';
import 'package:wio_app/update/app_too_old.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/local_rows.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const SyncTiming quick = SyncTiming(
  afterWrite: Duration(seconds: 3),
  every: Duration(minutes: 5),
  backOff: <Duration>[Duration(seconds: 30), Duration(minutes: 1)],
);

/// The app's fake API with sync answered by [server].
FakeApi apiWith(FakeSyncServer server) {
  final sync = server.clientFor('phone');
  return FakeApi(<String, Object>{
    'POST /sync/push': sync,
    'GET /sync/pull': sync,
  });
}

Future<WioDatabase> seeded() async {
  final db = memoryDatabase();
  addTearDown(db.close);
  await seedTestData(db);
  return db;
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(JobListScreen)));

Future<void> rename(WioDatabase db, String name) => LocalWriter(db).write(
  entity: 'customers',
  id: TestIds.frauMuster,
  fields: <String, Object?>{'name': name},
);

void main() {
  testWidgets('after start-up the outbox is sent and the line says so', (
    tester,
  ) async {
    final db = await seeded();
    await rename(db, 'Frau Muster-Probe');
    final server = FakeSyncServer();
    final api = apiWith(server);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      syncTiming: quick,
    );
    await settle(tester);
    // getMe first, then push and pull (D-129, D-201).
    expect(api.requests.map((r) => r.url.path), <String>[
      '/auth/me',
      '/sync/push',
      '/sync/pull',
    ]);
    expect(api.requests[1].headers['Authorization'], startsWith('Bearer '));
    expect((await countRows(db))['outbox'], 0);
    expect(find.text('Alles gesendet.'), findsOneWidget);
    expect(
      server.live('customers')[TestIds.frauMuster]?['name'],
      'Frau Muster-Probe',
    );
  });

  testWidgets('a local write is pushed after a short wait', (tester) async {
    final db = await seeded();
    final server = FakeSyncServer();
    final api = apiWith(server);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      syncTiming: quick,
    );
    final before = api.requests.length;
    await tester.runAsync(() => rename(db, 'Neu'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    expect(find.text('1 Änderung wartet auf das Senden.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(api.requests.length, before, reason: 'still waiting');
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(api.to('/sync/push'), hasLength(1));
    expect(find.text('Alles gesendet.'), findsOneWidget);
  });

  testWidgets('no answer: the line says so and it tries again later', (
    tester,
  ) async {
    final db = await seeded();
    await rename(db, 'Später');
    final server = FakeSyncServer()..loseRequests = 1;
    final api = apiWith(server);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      syncTiming: quick,
    );
    expect(
      find.text('Keine Verbindung. Wird später gesendet.'),
      findsOneWidget,
    );
    expect((await countRows(db))['outbox'], 1);
    await tester.pump(const Duration(seconds: 31));
    await settle(tester);
    expect(find.text('Alles gesendet.'), findsOneWidget);
    expect((await countRows(db))['outbox'], 0);
  });

  testWidgets('signed out, nothing is sent and the change waits', (
    tester,
  ) async {
    final db = await seeded();
    await rename(db, 'Wartet');
    final server = FakeSyncServer();
    final api = apiWith(server);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      store: FakeTokenStore(),
      autoSync: true,
      syncTiming: quick,
    );
    await settle(tester);
    await tester.pump(const Duration(minutes: 6));
    await settle(tester);
    expect(server.requests, isEmpty);
    expect(find.text('1 Änderung wartet auf das Senden.'), findsOneWidget);
  });

  testWidgets('too old, nothing is sent (D-156)', (tester) async {
    final db = await seeded();
    await rename(db, 'Wartet');
    final server = FakeSyncServer()..tooOld = true;
    final api = apiWith(server);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      syncTiming: quick,
    );
    // The first push meets 426; afterwards nothing leaves the phone.
    expect(server.requests, <String>['POST /sync/push']);
    await tester.tap(find.text('Zurück'));
    await settle(tester);
    expect(containerOf(tester).read(appTooOldProvider), isNotNull);
    await tester.pump(const Duration(minutes: 6));
    await settle(tester);
    expect(server.requests, <String>['POST /sync/push']);
    expect((await countRows(db))['outbox'], 1);
  });

  group('refused changes (D-197)', () {
    Future<(WioDatabase, FakeApi)> refused(WidgetTester tester) async {
      final db = await seeded();
      await rename(db, 'Nicht erlaubt');
      final server = FakeSyncServer()..refuse = (c) => 'permission';
      final api = apiWith(server);
      await pumpWioApp(
        tester,
        db: db,
        api: api,
        autoSync: true,
        syncTiming: quick,
      );
      server.refuse = null;
      return (db, api);
    }

    testWidgets('the job list shows a hint; Ansehen lists the change', (
      tester,
    ) async {
      await refused(tester);
      expect(find.text('1 Änderung wurde nicht übernommen.'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Ansehen'));
      await settle(tester);
      expect(find.byType(RejectedScreen), findsOneWidget);
      expect(find.text('Kunde: Nicht erlaubt'), findsOneWidget);
      expect(find.text('Geändert: Name'), findsOneWidget);
      expect(find.text('Dafür fehlt die Berechtigung.'), findsOneWidget);
    });

    testWidgets('Noch einmal senden makes a new change', (tester) async {
      final (db, api) = await refused(tester);
      final first = (await db.select(db.rejectedChanges).getSingle()).changeId;
      await tester.tap(find.widgetWithText(OutlinedButton, 'Ansehen'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Noch einmal senden'));
      await settle(tester);
      expect(find.text('Wird noch einmal gesendet.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await settle(tester);
      final pushes = api.to('/sync/push');
      expect(pushes, hasLength(2));
      expect(pushes.last.body, isNot(contains(first)));
      expect(await db.select(db.rejectedChanges).get(), isEmpty);
      expect((await countRows(db))['outbox'], 0);
      expect(
        find.text('Alles übernommen. Hier ist nichts mehr offen.'),
        findsOneWidget,
      );
    });

    testWidgets('Verwerfen removes it; Rückgängig brings it back', (
      tester,
    ) async {
      final (db, _) = await refused(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Ansehen'));
      await settle(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Verwerfen'));
      await settle(tester);
      expect(await db.select(db.rejectedChanges).get(), isEmpty);
      expect(find.text('Verworfen.'), findsOneWidget);
      await tester.tap(find.text('Rückgängig'));
      await settle(tester);
      expect(await db.select(db.rejectedChanges).get(), hasLength(1));
      expect(find.text('Kunde: Nicht erlaubt'), findsOneWidget);
    });

    testWidgets('the Verworfen note goes away after 8 seconds (UX rule 9)', (
      tester,
    ) async {
      await refused(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Ansehen'));
      await settle(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Verwerfen'));
      await settle(tester);
      expect(find.text('Verworfen.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 7));
      expect(find.text('Verworfen.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await settle(tester);
      expect(find.text('Verworfen.'), findsNothing);
      expect(find.text('Rückgängig'), findsNothing);
    });
  });
}
