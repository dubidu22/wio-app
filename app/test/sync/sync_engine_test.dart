// The sync engine against the fake sync server (plan 044 tests T2 to T14,
// D-192 to D-200). No real network.
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_api/wio_api.dart' show SyncApi;
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/ids.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/sync/sync_engine.dart';
import 'package:wio_app/update/app_too_old.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/test_data.dart';

const String ws = FakeSyncServer.defaultWorkspace;

/// One phone: its database, its writer and its engine.
class Device {
  Device(this.server, this.name, {DateTime Function()? clock})
    : db = memoryDatabase() {
    writer = LocalWriter(db, clock: clock ?? () => DateTime.utc(2026, 11, 19));
    engine = SyncEngine(
      db: db,
      api: SyncApi(
        buildApiServer(
          fakeApiBase,
          server.clientFor(name),
          exampleSession,
          ApiHooks(
            tooOld: () => tooOldState,
            reportTooOld: (t) => tooOldState ??= t,
          ),
        ),
      ),
      workspaceId: ws,
      tooOld: () => tooOldState != null,
      clock: () => DateTime.utc(2026, 11, 19, 12),
    );
    addTearDown(db.close);
  }

  final FakeSyncServer server;
  final String name;
  final WioDatabase db;
  late final LocalWriter writer;
  late final SyncEngine engine;
  AppTooOld? tooOldState;

  Future<String> newCustomer(String name, {String? externalRef}) async {
    final id = newUuidV7();
    await writer.write(
      entity: 'customers',
      id: id,
      fields: <String, Object?>{
        'workspace_id': ws,
        'name': name,
        'external_ref': ?externalRef,
      },
    );
    return id;
  }

  Future<void> rename(String id, String name) => writer.write(
    entity: 'customers',
    id: id,
    fields: <String, Object?>{'name': name},
  );

  Future<int> outbox() async => (await db.select(db.outbox).get()).length;

  Future<List<RejectedChange>> rejected() =>
      db.select(db.rejectedChanges).get();

  Future<Customer?> customer(String id) => (db.select(
    db.customers,
  )..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Live customers as id → name.
  Future<Map<String, String?>> names() async => <String, String?>{
    for (final c in await (db.select(
      db.customers,
    )..where((c) => c.deletedAt.isNull())).get())
      c.id: c.name,
  };

  Future<int> lastRevision() async =>
      (await (db.select(
            db.syncState,
          )..where((s) => s.workspaceId.equals(ws))).getSingleOrNull())
          ?.lastRevision ??
      0;
}

Map<String, String?> serverNames(FakeSyncServer server) => <String, String?>{
  for (final MapEntry(:key, :value) in server.live('customers').entries)
    key: value['name'] as String?,
};

void main() {
  late FakeSyncServer server;

  setUp(() => server = FakeSyncServer());

  group('push (T2, T3)', () {
    for (final count in <int>[1000, 5000]) {
      test('$count changes go in pages of at most 200, each once', () async {
        final phone = Device(server, 'a');
        final id = await phone.newCustomer('Kundin 0');
        for (var i = 1; i < count; i++) {
          await phone.rename(id, 'Kundin $i');
        }
        expect((await phone.engine.push()).stop, SyncStop.done);
        expect(await phone.outbox(), 0);
        expect(server.pushPages.fold<int>(0, (a, b) => a + b), count);
        expect(server.pushPages.every((n) => n <= maxPushChanges), isTrue);
        expect(server.counter, count, reason: 'every change applied once');
        expect(serverNames(server), <String, String?>{
          id: 'Kundin ${count - 1}',
        });
      });
    }

    test('pages stay under the byte limit', () async {
      final phone = Device(server, 'a');
      final id = await phone.newCustomer('Groß');
      for (var i = 0; i < 30; i++) {
        await phone.rename(id, '$i ${'x' * 100000}');
      }
      expect((await phone.engine.push()).stop, SyncStop.done);
      expect(server.pushPages.length, greaterThan(1));
      expect(server.pushPages.fold<int>(0, (a, b) => a + b), 31);
    });

    test(
      'a lost answer is resent with the same ids and applied once',
      () async {
        final phone = Device(server, 'a');
        final id = await phone.newCustomer('Frau Muster');
        await phone.rename(id, 'Frau Muster-Probe');
        server.loseAnswers = 1;
        expect((await phone.engine.push()).stop, SyncStop.offline);
        expect(await phone.outbox(), 2, reason: 'nothing without its answer');
        expect(server.counter, 2, reason: 'the server applied the page');

        server.loseRequests = 1;
        expect((await phone.engine.push()).stop, SyncStop.offline);
        expect(await phone.outbox(), 2);

        expect((await phone.engine.push()).stop, SyncStop.done);
        expect(await phone.outbox(), 0);
        expect(server.counter, 2, reason: 'the retry got the stored answers');
      },
    );

    test('push answers never change the local revision (D-195)', () async {
      final phone = Device(server, 'a');
      final id = await phone.newCustomer('Herr Probe');
      await phone.engine.push();
      expect((await phone.customer(id))!.revision, isNull);
      await phone.engine.pull();
      expect((await phone.customer(id))!.revision, 1);
    });
  });

  group('rejections (T4, T6)', () {
    test('a refused create disappears and is listed', () async {
      server.refuse = (c) => 'permission';
      final phone = Device(server, 'a');
      final id = await phone.newCustomer('Nicht erlaubt');
      expect((await phone.engine.push()).stop, SyncStop.done);
      expect(await phone.outbox(), 0);
      expect(await phone.customer(id), isNull);
      final rejected = (await phone.rejected()).single;
      expect(rejected.reason, 'permission');
      expect(rejected.entityId, id);
      expect(
        jsonDecode(rejected.fields),
        containsPair('name', 'Nicht erlaubt'),
      );
    });

    test('a refused edit shows the server value again', () async {
      final id = newUuidV7();
      server.put('customers', id, <String, Object?>{
        'name': 'Familie Beispiel',
      });
      final phone = Device(server, 'a');
      await phone.engine.pull();
      server.refuse = (c) => 'permission';
      await phone.rename(id, 'Falsch');
      expect((await phone.customer(id))!.name, 'Falsch');
      await phone.engine.push();
      expect((await phone.customer(id))!.name, 'Familie Beispiel');
      expect((await phone.rejected()).single.reason, 'permission');
    });

    test('a recorded refusal is replayed for the same change id', () async {
      server.refuse = (c) => 'permission';
      final phone = Device(server, 'a');
      final id = await phone.newCustomer('Später erlaubt');
      await phone.engine.push();
      final rejected = (await phone.rejected()).single;
      server.refuse = null;
      // Sending the same change again (as a broken app would) gets the same
      // answer (D-172); only a new change id can succeed.
      await phone.db
          .into(phone.db.outbox)
          .insert(
            OutboxCompanion.insert(
              changeId: rejected.changeId,
              entity: rejected.entity,
              entityId: rejected.entityId,
              fields: rejected.fields,
              deviceTime: rejected.deviceTime,
            ),
          );
      await phone.db.delete(phone.db.rejectedChanges).go();
      await phone.engine.push();
      expect((await phone.rejected()).single.reason, 'permission');
      expect(server.live('customers'), isNot(contains(id)));
    });

    test('a page refused as a whole goes one by one (D-199)', () async {
      final phone = Device(server, 'a');
      final good = await phone.newCustomer('Gut');
      final bad = await phone.newCustomer('Kaputt');
      final alsoGood = await phone.newCustomer('Auch gut');
      server.breaksPage = (c) => (c['fields']! as Map)['name'] == 'Kaputt';
      expect((await phone.engine.push()).stop, SyncStop.done);
      expect(await phone.outbox(), 0);
      expect((await phone.rejected()).single.entityId, bad);
      expect(
        serverNames(server).keys,
        unorderedEquals(<String>[good, alsoGood]),
      );
    });

    test('an unknown reason is still a rejection', () async {
      server.refuse = (c) => 'something_new';
      final phone = Device(server, 'a');
      await phone.newCustomer('Neu');
      await phone.engine.push();
      expect((await phone.rejected()).single.reason, 'something_new');
    });
  });

  group('duplicates (T5, D-198)', () {
    test(
      'a create that exists already is re-pointed with its dependants',
      () async {
        final existing = newUuidV7();
        server.put('customers', existing, <String, Object?>{
          'name': 'Familie Beispiel',
          'external_ref': 'K-17',
        });
        final phone = Device(server, 'a');
        final local = await phone.newCustomer(
          'Familie B.',
          externalRef: 'K-17',
        );
        final site = newUuidV7();
        await phone.writer.write(
          entity: 'sites',
          id: site,
          fields: <String, Object?>{
            'workspace_id': ws,
            'customer_id': local,
            'name': 'Neue Wohnung',
          },
        );
        expect((await phone.engine.push()).stop, SyncStop.done);
        // The page ended before the site, so the site went to the existing
        // customer.
        expect(server.pushPages, <int>[1, 1]);
        expect(server.records['sites']![site]!['customer_id'], existing);
        final rejected = (await phone.rejected()).single;
        expect(rejected.reason, 'duplicate');
        expect(rejected.existingId, existing);
        expect(await phone.customer(local), isNull);
        // The create's other fields were not sent to the existing record.
        expect(
          server.records['customers']![existing]!['name'],
          'Familie Beispiel',
        );
        await phone.engine.pull();
        final sites = await phone.db.select(phone.db.sites).get();
        expect(sites.single.customerId, existing);
        expect((await phone.customer(existing))!.name, 'Familie Beispiel');
      },
    );

    test(
      'a duplicate value on an existing record is a plain rejection',
      () async {
        final a = newUuidV7();
        final b = newUuidV7();
        server
          ..put('customers', a, <String, Object?>{
            'name': 'A',
            'external_ref': 'K-1',
          })
          ..put('customers', b, <String, Object?>{
            'name': 'B',
            'external_ref': 'K-2',
          });
        final phone = Device(server, 'a');
        await phone.engine.pull();
        await phone.writer.write(
          entity: 'customers',
          id: b,
          fields: <String, Object?>{'external_ref': 'K-1'},
        );
        await phone.engine.push();
        final rejected = (await phone.rejected()).single;
        expect(rejected.reason, 'duplicate');
        expect(rejected.existingId, isNull);
        expect((await phone.customer(b))!.externalRef, 'K-2');
      },
    );
  });

  group('pull (T7, T8, T13, T14)', () {
    test('pages of 500 with the revision stored per page', () async {
      for (var i = 0; i < 1200; i++) {
        server.put('customers', newUuidV7(), <String, Object?>{'name': 'K$i'});
      }
      final phone = Device(server, 'a');
      expect((await phone.engine.pull()).stop, SyncStop.done);
      expect(server.requests.where((r) => r == 'GET /sync/pull'), hasLength(3));
      expect((await phone.names()).length, 1200);
      expect(await phone.lastRevision(), 1200);
    });

    test('a lost page answer keeps the earlier page', () async {
      for (var i = 0; i < 1200; i++) {
        server.put('customers', newUuidV7(), <String, Object?>{'name': 'K$i'});
      }
      final phone = Device(server, 'a');
      server.random = _Scripted(<double>[1, 1, 1, 0]);
      server.lossRate = 0.5;
      expect((await phone.engine.pull()).stop, SyncStop.offline);
      expect(await phone.lastRevision(), 500);
      server.random = null;
      expect((await phone.engine.pull()).stop, SyncStop.done);
      expect(await phone.lastRevision(), 1200);
      expect((await phone.names()).length, 1200);
    });

    test('an unsent edit stays visible over a pulled record', () async {
      final id = newUuidV7();
      server.put('customers', id, <String, Object?>{
        'name': 'Familie Beispiel',
        'contact': <String, Object?>{'email': 'alt@example.org'},
      });
      final phone = Device(server, 'a');
      await phone.engine.pull();
      await phone.rename(id, 'Familie Beispiel-Muster');
      // Another device changes another field meanwhile.
      server.records['customers']![id]!
        ..['contact'] = <String, Object?>{'email': 'neu@example.org'}
        ..['revision'] = ++server.counter;
      await phone.engine.pull();
      final row = (await phone.customer(id))!;
      expect(row.name, 'Familie Beispiel-Muster');
      expect(jsonDecode(row.contact!), <String, Object?>{
        'email': 'neu@example.org',
      });
      expect(await phone.engine.run(), isA<SyncResult>());
      expect(
        server.records['customers']![id]!['name'],
        'Familie Beispiel-Muster',
      );
      expect((await phone.customer(id))!.revision, server.counter);
    });

    test('entities without a local table are kept as server copies', () async {
      final label = newUuidV7();
      server.put('labels', label, <String, Object?>{'name': 'Keller'});
      final phone = Device(server, 'a');
      await phone.engine.pull();
      final copy = await phone.db.select(phone.db.serverRecords).getSingle();
      expect(copy.entity, 'labels');
      expect(jsonDecode(copy.fields), containsPair('name', 'Keller'));
    });

    test(
      'a record of another workspace stops the pull and stores nothing',
      () async {
        server.put('customers', newUuidV7(), <String, Object?>{'name': 'Gut'});
        server.put('customers', newUuidV7(), <String, Object?>{
          'name': 'Fremd',
          'workspace_id': '01970000-0000-7000-8000-0000000000ff',
        });
        final phone = Device(server, 'a');
        expect((await phone.engine.pull()).stop, SyncStop.failed);
        expect(await phone.names(), isEmpty);
        expect(await phone.lastRevision(), 0);
      },
    );

    test('no progress with has_more stops the run', () async {
      final phone = Device(server, 'a');
      final stuck = FakeApi(<String, Object>{
        'GET /sync/pull': const FakeAnswer(200, <String, Object?>{
          'records': <Object?>[],
          'has_more': true,
          'last_revision': 0,
        }),
      });
      final engine = SyncEngine(
        db: phone.db,
        api: SyncApi(
          buildApiServer(
            fakeApiBase,
            stuck.client,
            exampleSession,
            ApiHooks.none,
          ),
        ),
        workspaceId: ws,
        tooOld: () => false,
      );
      expect((await engine.pull()).stop, SyncStop.failed);
      expect(stuck.requests, hasLength(1));
    });
  });

  group('410 resync_required (T9, D-200)', () {
    test('in the middle of paging: pulled data again, outbox kept', () async {
      for (var i = 0; i < 700; i++) {
        server.put('customers', newUuidV7(), <String, Object?>{'name': 'K$i'});
      }
      final phone = Device(server, 'a');
      await phone.engine.pull();
      server.refuse = (c) => 'permission';
      final rejectedId = await phone.newCustomer('Abgelehnt');
      await phone.engine.push();
      server.refuse = null;
      final unsent = await phone.newCustomer('Noch nicht gesendet');
      for (var i = 0; i < 600; i++) {
        server.put('customers', newUuidV7(), <String, Object?>{'name': 'N$i'});
      }
      // The second page of this pull answers 410.
      server.resyncOnPull = 2;
      expect((await phone.engine.pull()).stop, SyncStop.done);
      expect(await phone.outbox(), 1, reason: 'outbox kept');
      expect((await phone.rejected()).single.entityId, rejectedId);
      expect((await phone.customer(unsent))!.name, 'Noch nicht gesendet');
      expect((await phone.names()).length, 1301);
      expect(await phone.lastRevision(), server.counter);
      expect(
        await phone.db.select(phone.db.serverRecords).get(),
        hasLength(1300),
      );
    });
  });

  group('426 (T10, D-156)', () {
    test('a push stops at once and keeps everything', () async {
      final phone = Device(server, 'a');
      await phone.newCustomer('Bleibt');
      server.tooOld = true;
      expect((await phone.engine.run()).stop, SyncStop.tooOld);
      expect(await phone.outbox(), 1);
      expect(server.requests, hasLength(1));
      // Later runs send nothing.
      expect((await phone.engine.run()).stop, SyncStop.tooOld);
      expect(server.requests, hasLength(1));
    });

    test('a pull stops at once and keeps the stored data', () async {
      server.put('customers', newUuidV7(), <String, Object?>{'name': 'Da'});
      final phone = Device(server, 'a');
      await phone.engine.pull();
      server.tooOld = true;
      server.put('customers', newUuidV7(), <String, Object?>{'name': 'Neu'});
      expect((await phone.engine.pull()).stop, SyncStop.tooOld);
      expect((await phone.names()).values, <String?>['Da']);
      expect(await phone.lastRevision(), 1);
    });
  });

  group('delete and restore', () {
    test('tombstones go to the server and come back as tombstones', () async {
      final phone = Device(server, 'a');
      final id = await phone.newCustomer('Weg und wieder da');
      await phone.engine.run();
      await phone.writer.delete(entity: 'customers', id: id);
      expect(await phone.names(), isEmpty);
      await phone.engine.run();
      expect(server.records['customers']![id]!['deleted_at'], isNotNull);
      await phone.writer.restore(entity: 'customers', id: id);
      await phone.engine.run();
      expect(server.records['customers']![id]!['deleted_at'], isNull);
      expect((await phone.names()).keys, <String>[id]);
    });

    test(
      'an edit of a record deleted elsewhere is listed as deleted',
      () async {
        final id = newUuidV7();
        server.put('customers', id, <String, Object?>{'name': 'Gelöscht'});
        final phone = Device(server, 'a');
        await phone.engine.pull();
        server.records['customers']![id]!
          ..['deleted_at'] = '2026-11-19T08:00:00.000Z'
          ..['revision'] = ++server.counter;
        await phone.rename(id, 'Zu spät');
        await phone.engine.run();
        expect((await phone.rejected()).single.reason, 'deleted');
        expect((await phone.customer(id))!.deletedAt, isNotNull);
      },
    );
  });

  test('a wrong device clock changes nothing (T12)', () async {
    final early = Device(server, 'a', clock: () => DateTime.utc(2026, 11, 14));
    final late = Device(server, 'b', clock: () => DateTime.utc(2026, 11, 24));
    final id = newUuidV7();
    server.put('customers', id, <String, Object?>{'name': 'Start'});
    await early.engine.pull();
    await late.engine.pull();
    await late.rename(id, 'Spät, aber zuerst gesendet');
    await late.engine.push();
    await early.rename(id, 'Früh, aber zuletzt gesendet');
    await early.engine.push();
    // Server order wins, not the device clocks (sync.md).
    expect(
      server.records['customers']![id]!['name'],
      'Früh, aber zuletzt gesendet',
    );
    expect(server.live('conflicts'), hasLength(1));
  });

  test('two devices with random edits and loss converge (T11)', () async {
    final seed = DateTime.now().microsecondsSinceEpoch % 100000;
    final random = Random(seed);
    addTearDown(() => printOnFailure('seed: $seed'));
    final phones = <Device>[Device(server, 'a'), Device(server, 'b')];
    final ids = <String>[];
    for (var round = 0; round < 40; round++) {
      final phone = phones[random.nextInt(2)];
      final known = (await phone.names()).keys.toList();
      final action = random.nextInt(4);
      if (action == 0 || known.isEmpty) {
        ids.add(await phone.newCustomer('K$round'));
      } else if (action == 1) {
        await phone.rename(known[random.nextInt(known.length)], 'R$round');
      } else if (action == 2 && random.nextBool()) {
        await phone.writer.delete(
          entity: 'customers',
          id: known[random.nextInt(known.length)],
        );
      } else {
        server
          ..random = random
          ..lossRate = 0.3;
        await phone.engine.run();
        server.random = null;
      }
    }
    // Final: both phones send and receive until nothing is left.
    for (var i = 0; i < 3; i++) {
      for (final phone in phones) {
        expect((await phone.engine.run()).stop, SyncStop.done);
      }
    }
    for (final phone in phones) {
      expect(await phone.outbox(), 0);
      expect(await phone.names(), serverNames(server));
    }
    // The only refusal this game can earn: an edit of a record the other
    // phone deleted meanwhile.
    for (final phone in phones) {
      for (final rejected in await phone.rejected()) {
        expect(rejected.reason, 'deleted');
      }
    }
    expect(ids, isNotEmpty);
  });

  test('a v1 row without a server copy survives a rejection', () async {
    final phone = Device(server, 'a');
    await seedTestData(phone.db);
    server.refuse = (c) => 'permission';
    await phone.rename(TestIds.frauMuster, 'Abgelehnt');
    await phone.engine.push();
    final row = (await phone.customer(TestIds.frauMuster))!;
    expect(row.revision, 1);
    expect(await phone.outbox(), 0);
  });
}

/// Values a test chooses, then 1 (no loss) forever.
class _Scripted implements Random {
  _Scripted(this._values);

  final List<double> _values;
  var _next = 0;

  @override
  double nextDouble() => _next < _values.length ? _values[_next++] : 1;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}
