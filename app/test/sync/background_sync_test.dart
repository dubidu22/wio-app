// Sync while the app is closed, Dart half (plan 052 tests T1, T5, T6;
// D-374 to D-378, D-381). The phone's side of the channel `wio/background`
// is played here; no real network, the fake sync server answers.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/jobs/job_list_screen.dart';
import 'package:wio_app/sync/background_sync.dart';
import 'package:wio_app/sync/sync_runner.dart';

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

const MethodCodec codec = StandardMethodCodec();

FakeApi apiWith(FakeSyncServer server) {
  final sync = server.clientFor('phone');
  return FakeApi(<String, Object>{
    'POST /sync/push': sync,
    'GET /sync/pull': sync,
  });
}

/// A server for the session's own workspace, so pulled records belong to
/// it (D-131).
FakeSyncServer phoneServer() =>
    FakeSyncServer(workspaceId: exampleSession().workspace.id);

Future<WioDatabase> seeded() async {
  final db = memoryDatabase();
  addTearDown(db.close);
  await seedTestData(db);
  return db;
}

Future<void> rename(WioDatabase db, String name) => LocalWriter(db).write(
  entity: 'customers',
  id: TestIds.frauMuster,
  fields: <String, Object?>{'name': name},
);

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(JobListScreen)));

/// The phone's side: records every `schedule` the app sends.
List<Map<Object?, Object?>> recordSchedules(WidgetTester tester) {
  final plans = <Map<Object?, Object?>>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    backgroundChannel,
    (call) async {
      if (call.method == 'schedule') {
        plans.add(call.arguments as Map<Object?, Object?>);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      backgroundChannel,
      null,
    ),
  );
  return plans;
}

/// The phone asks the app for [method]; returns the answer once sync's
/// database and HTTP work has run.
Future<Object?> ask(
  WidgetTester tester,
  String method, [
  Map<String, Object?>? arguments,
]) async {
  final answer = Completer<Object?>();
  unawaited(
    tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      backgroundChannel.name,
      codec.encodeMethodCall(MethodCall(method, arguments)),
      (data) =>
          answer.complete(data == null ? null : codec.decodeEnvelope(data)),
    ),
  );
  for (var i = 0; i < 20 && !answer.isCompleted; i++) {
    await settle(tester);
  }
  return answer.future;
}

Map<String, Object?> runArgs({
  required bool files,
  DateTime? deadline,
  String id = 'work-1',
}) => <String, Object?>{
  'id': id,
  'deadlineMs': (deadline ?? testNow.add(const Duration(minutes: 9)))
      .millisecondsSinceEpoch,
  'files': files,
};

Future<void> leave(WidgetTester tester) async {
  for (final state in <AppLifecycleState>[
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await settle(tester);
}

final supported = backgroundSyncSupportedProvider.overrideWithValue(true);

void main() {
  testWidgets('leaving the app hands the outbox to the phone and stops '
      'runs by themselves (T6)', (tester) async {
    final db = await seeded();
    final server = phoneServer();
    final api = apiWith(server);
    final plans = recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      syncTiming: quick,
      overrides: [supported],
    );
    await settle(tester);
    final before = api.requests.length;
    await tester.runAsync(() => rename(db, 'Später'));
    await leave(tester);
    expect(plans.last, <String, Object?>{
      'active': true,
      'pending': true,
      'files': false,
    });
    // Neither the write's short wait nor the 5-minute timer starts a run
    // in the background (D-376).
    await tester.pump(const Duration(minutes: 6));
    await settle(tester);
    expect(api.requests.length, before);
    expect((await countRows(db))['outbox'], 1);

    // Back in front: a run starts at once.
    for (final state in <AppLifecycleState>[
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settle(tester);
    expect(api.to('/sync/push'), hasLength(1));
    expect((await countRows(db))['outbox'], 0);
  });

  testWidgets('started in the background: nothing runs by itself; the '
      "phone's run pushes and pulls and answers done (T1, D-381)", (
    tester,
  ) async {
    final db = await seeded();
    await rename(db, 'Im Hintergrund');
    final server = phoneServer();
    final api = apiWith(server);
    final plans = recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      syncTiming: quick,
      overrides: [
        supported,
        startedInBackgroundProvider.overrideWithValue(true),
      ],
    );
    await settle(tester);
    expect(api.requests.map((r) => r.url.path), <String>['/auth/me']);

    expect(await ask(tester, 'run', runArgs(files: true)), 'done');
    expect(api.requests.map((r) => r.url.path), <String>[
      '/auth/me',
      '/sync/push',
      '/sync/pull',
    ]);
    expect((await countRows(db))['outbox'], 0);
    expect(
      server.live('customers')[TestIds.frauMuster]?['name'],
      'Im Hintergrund',
    );
    expect(plans.last, <String, Object?>{
      'active': true,
      'pending': false,
      'files': false,
    });
  });

  testWidgets('a run without files leaves files for an unmetered run '
      '(T2, D-378)', (tester) async {
    final db = await seeded();
    final server = phoneServer();
    final plans = recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      api: apiWith(server),
      autoSync: true,
      syncTiming: quick,
      overrides: [
        supported,
        startedInBackgroundProvider.overrideWithValue(true),
      ],
    );
    expect(await ask(tester, 'run', runArgs(files: false)), 'done');
    expect(plans.last['files'], isTrue);
    expect(await ask(tester, 'run', runArgs(files: true)), 'done');
    expect(plans.last['files'], isFalse);
  });

  testWidgets('out of time: retry, and nothing is sent (D-375)', (
    tester,
  ) async {
    final db = await seeded();
    await rename(db, 'Zu spät');
    final server = phoneServer();
    final api = apiWith(server);
    recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      syncTiming: quick,
      overrides: [
        supported,
        startedInBackgroundProvider.overrideWithValue(true),
      ],
    );
    final before = api.requests.length;
    expect(
      await ask(tester, 'run', runArgs(files: true, deadline: testNow)),
      'retry',
    );
    expect(api.requests.length, before);
    expect((await countRows(db))['outbox'], 1);
  });

  testWidgets('no answer from the server: retry (T1)', (tester) async {
    final db = await seeded();
    await rename(db, 'Offline');
    final server = phoneServer()..loseRequests = 1;
    recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      api: apiWith(server),
      autoSync: true,
      syncTiming: quick,
      overrides: [
        supported,
        startedInBackgroundProvider.overrideWithValue(true),
      ],
    );
    expect(await ask(tester, 'run', runArgs(files: true)), 'retry');
    expect((await countRows(db))['outbox'], 1);
  });

  testWidgets('signed out: skip, and the phone cancels everything (T5)', (
    tester,
  ) async {
    final db = await seeded();
    await rename(db, 'Wartet');
    final server = phoneServer();
    final plans = recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      api: apiWith(server),
      store: FakeTokenStore(),
      autoSync: true,
      syncTiming: quick,
      overrides: [
        supported,
        startedInBackgroundProvider.overrideWithValue(true),
      ],
    );
    expect(await ask(tester, 'run', runArgs(files: true)), 'skip');
    expect(server.requests, isEmpty);
    expect(plans.last, <String, Object?>{
      'active': false,
      'pending': false,
      'files': false,
    });
  });

  testWidgets('too old (426): skip, and the phone cancels everything (T5)', (
    tester,
  ) async {
    final db = await seeded();
    await rename(db, 'Wartet');
    final server = phoneServer()..tooOld = true;
    final plans = recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      api: apiWith(server),
      autoSync: true,
      syncTiming: quick,
      overrides: [
        supported,
        startedInBackgroundProvider.overrideWithValue(true),
      ],
    );
    expect(await ask(tester, 'run', runArgs(files: true)), 'skip');
    expect(server.requests, <String>['POST /sync/push']);
    expect(plans.last['active'], isFalse);
    expect(await ask(tester, 'run', runArgs(files: true)), 'skip');
    expect(server.requests, <String>['POST /sync/push']);
    expect((await countRows(db))['outbox'], 1);
  });

  testWidgets('a run asked for while one is going waits for it, then runs '
      'once more (T1)', (tester) async {
    final db = await seeded();
    await rename(db, 'Erste');
    final server = phoneServer();
    final api = apiWith(server);
    recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      syncTiming: quick,
      overrides: [supported],
    );
    await settle(tester);
    final pushes = api.to('/sync/push').length;
    await tester.runAsync(() => rename(db, 'Zweite'));
    final sync = containerOf(tester).read(syncProvider.notifier);
    // A foreground run is going when the phone asks.
    final first = sync.run();
    expect(await ask(tester, 'run', runArgs(files: true)), 'done');
    await first;
    // One push from the foreground run; the background run found nothing
    // left to push.
    expect(api.to('/sync/push').length, pushes + 1);
    expect((await countRows(db))['outbox'], 0);
  });

  testWidgets('the web and unsupported phones never use the channel', (
    tester,
  ) async {
    final db = await seeded();
    final plans = recordSchedules(tester);
    await pumpWioApp(
      tester,
      db: db,
      overrides: [backgroundSyncSupportedProvider.overrideWithValue(false)],
    );
    await leave(tester);
    expect(plans, isEmpty);
  });

  group('PR 87 review round 1', () {
    Future<(WioDatabase, FakeApi, ProviderContainer)> started(
      WidgetTester tester, {
      bool background = true,
    }) async {
      final db = await seeded();
      final server = phoneServer();
      final api = apiWith(server);
      recordSchedules(tester);
      await pumpWioApp(
        tester,
        db: db,
        api: api,
        autoSync: true,
        syncTiming: quick,
        overrides: [
          supported,
          startedInBackgroundProvider.overrideWithValue(background),
        ],
      );
      await settle(tester);
      return (db, api, containerOf(tester));
    }

    testWidgets('M1: opening the app during a background run runs once '
        'more after it', (tester) async {
      final (db, api, container) = await started(tester);
      await tester.runAsync(() => rename(db, 'Erst'));
      final sync = container.read(syncProvider.notifier);
      final background = sync.runInBackground(
        id: 'a',
        deadline: testNow.add(const Duration(minutes: 9)),
        files: true,
      );
      // The run is going when the app comes to the front.
      sync.resumed();
      await settle(tester);
      expect(await background, BackgroundOutcome.done);
      await settle(tester);
      expect(api.to('/sync/push'), hasLength(1));
      expect(api.to('/sync/pull'), hasLength(2));
    });

    testWidgets('M2: a stop after the background run ended does not stop '
        'later foreground runs', (tester) async {
      final (db, api, container) = await started(tester);
      expect(await ask(tester, 'run', runArgs(files: true, id: 'a')), 'done');
      await ask(tester, 'stop', <String, Object?>{'id': 'a'});
      container.read(syncProvider.notifier).resumed();
      await settle(tester);
      await tester.runAsync(() => rename(db, 'Danach'));
      await tester.pump(const Duration(seconds: 4));
      await settle(tester);
      expect(api.to('/sync/push'), hasLength(1));
      expect((await countRows(db))['outbox'], 0);
    });

    testWidgets('M3: overlapping background runs go one after another, each '
        'with its own deadline and stop', (tester) async {
      final (db, api, container) = await started(tester);
      await tester.runAsync(() => rename(db, 'Zwei Läufe'));
      final sync = container.read(syncProvider.notifier);
      final first = sync.runInBackground(
        id: 'records',
        deadline: testNow.add(const Duration(minutes: 9)),
        files: false,
      );
      final second = sync.runInBackground(
        id: 'files',
        deadline: testNow.add(const Duration(minutes: 9)),
        files: true,
      );
      final third = sync.runInBackground(
        id: 'late',
        deadline: testNow,
        files: true,
      );
      // A stop for the waiting second run leaves the first alone.
      sync.stopRun('files');
      await settle(tester);
      expect(await first, BackgroundOutcome.done);
      expect(await second, BackgroundOutcome.retry);
      expect(await third, BackgroundOutcome.retry);
      // Only the first run sent anything; nobody answered skip.
      expect(api.to('/sync/push'), hasLength(1));
      expect(api.to('/sync/pull'), hasLength(1));
      expect((await countRows(db))['outbox'], 0);
    });

    testWidgets('S1: Dart tells the phone when it listens', (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        backgroundChannel,
        (call) async {
          calls.add(call.method);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          backgroundChannel,
          null,
        ),
      );
      await pumpWioApp(tester, db: await seeded(), overrides: [supported]);
      expect(calls.first, 'ready');
    });
  });
}
