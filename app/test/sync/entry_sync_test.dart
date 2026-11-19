// Entries, places, labels and properties through the sync loop against the
// fake sync server (plan 101 tests T11 to T15 and T18; D-434 to D-447).
// No real network.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_api/wio_api.dart' show SyncApi;
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/entry_queries.dart';
import 'package:wio_app/data/entry_writer.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/data/media_writer.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/shell/providers.dart';
import 'package:wio_app/sync/rejected_changes.dart';
import 'package:wio_app/sync/sync_engine.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/test_data.dart';

const String ws = FakeSyncServer.defaultWorkspace;
const String customer = '01970000-0000-7000-8000-0000000000c1';
const String site = '01970000-0000-7000-8000-0000000000a1';
const String kueche = '01970000-0000-7000-8000-0000000000b1';
const String keller = '01970000-0000-7000-8000-0000000000b2';
const Place inKueche = Place.room(siteId: site, roomId: kueche);
const Place inKeller = Place.room(siteId: site, roomId: keller);

/// One phone with its own database and media folder.
class Phone {
  Phone(this.server, this.name, this.folder) : db = memoryDatabase() {
    final local = LocalWriter(db);
    entries = EntryWriter(db, local);
    media = MediaWriter(
      db,
      local,
      MediaStore(() async => '${folder.path}/$name'),
      UploadStore(() async => '${folder.path}/$name'),
    );
    engine = SyncEngine(
      db: db,
      api: SyncApi(
        buildApiServer(
          fakeApiBase,
          server.clientFor(name),
          exampleSession,
          ApiHooks(tooOld: () => null, reportTooOld: (_) {}),
        ),
      ),
      workspaceId: ws,
      tooOld: () => false,
      clock: () => DateTime.utc(2026, 11, 19, 12),
    );
    addTearDown(db.close);
  }

  final FakeSyncServer server;
  final String name;
  final Directory folder;
  final WioDatabase db;
  late final EntryWriter entries;
  late final MediaWriter media;
  late final SyncEngine engine;

  Future<String> takePicture(String entryId) async {
    final file = File('${folder.path}/src-$name-$entryId');
    await file.writeAsString('jpeg $name');
    return media.addPicture(
      workspaceId: ws,
      file: PreparedPicture(
        path: file.path,
        mime: 'image/jpeg',
        widthPx: 2560,
        heightPx: 1920,
      ),
      entryId: entryId,
    );
  }

  Future<List<OutboxData>> outbox() => db.select(db.outbox).get();

  Future<Entry> entry(String id) =>
      (db.select(db.entries)..where((e) => e.id.equals(id))).getSingle();

  /// The "Nicht gesendet" list as the screen gets it.
  Future<List<RejectedEntry>> rejected() async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    container.listen(rejectedListProvider, (_, _) {});
    return container.read(rejectedListProvider.future);
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FakeSyncServer server;
  late Directory folder;

  setUp(() async {
    server = FakeSyncServer();
    folder = await Directory.systemTemp.createTemp('entry_sync_test');
    server
      ..put('customers', customer, <String, Object?>{
        'name': 'Familie Beispiel',
      })
      ..put('sites', site, <String, Object?>{'customer_id': customer})
      ..put('rooms', kueche, <String, Object?>{
        'customer_id': customer,
        'site_id': site,
        'name': 'Küche',
      })
      ..put('rooms', keller, <String, Object?>{
        'customer_id': customer,
        'site_id': site,
        'name': 'Keller',
      });
  });
  tearDown(() => folder.delete(recursive: true));

  test('create, label and property: push, confirm, pull (T11)', () async {
    final phone = Phone(server, 'a', folder);
    await phone.engine.pull();
    final id = await phone.entries.createEntry(
      workspaceId: ws,
      customerId: customer,
      code: 'WIO-0001',
      title: 'Bücherkiste',
    );
    final subject = (type: 'entry', id: id);
    final label = await phone.entries.labelNamed(
      workspaceId: ws,
      name: 'Bücher',
    );
    await phone.entries.addLabel(subject, label);
    final key = await phone.entries.keyNamed(
      workspaceId: ws,
      name: 'Gewicht',
      unit: 'kg',
    );
    await phone.entries.setProperty(subject, key, number: '12.5');
    await phone.entries.setTarget(id, inKeller);

    expect((await phone.engine.run()).stop, SyncStop.done);
    expect(await phone.outbox(), isEmpty);
    final stored = server.live('entries')[id]!;
    expect(stored['code'], 'WIO-0001');
    expect(stored['target_room_id'], keller);
    expect(server.live('entity_labels'), hasLength(1));
    expect(
      server.live('entity_properties').values.single['value_number'],
      '12.5',
    );

    final row = await phone.entry(id);
    expect(row.revision, stored['revision']);
    expect(Place.targetOf(row), inKeller);
    expect(
      (await watchLabelsOf(phone.db, subject).first).single.label.name,
      'Bücher',
    );
    final values = await watchPropertiesOf(phone.db, subject).first;
    expect(values.single.value.valueNumber, '12.5');
    expect(values.single.value.revision, isNotNull);
    expect(server.records['place_history'], isNull);

    // Another phone sees the same entry after its first pull.
    final other = Phone(server, 'b', folder);
    await other.engine.pull();
    expect((await other.entry(id)).title, 'Bücherkiste');
  });

  test('placed at create, then moved: two history rows pulled (T12)', () async {
    final phone = Phone(server, 'a', folder);
    await phone.engine.pull();
    final id = await phone.entries.createEntry(
      workspaceId: ws,
      customerId: customer,
      place: inKueche,
    );
    await phone.entries.move(id, inKeller);
    expect((await placeHistory(phone.db, id)).map((s) => s.pending), <bool>[
      true,
      true,
    ]);

    expect((await phone.engine.run()).stop, SyncStop.done);
    // The create and the moves that depend on it go in separate pages
    // (D-196).
    expect(server.pushPages, <int>[1, 2]);
    expect(server.live('place_history'), hasLength(2));

    final history = await placeHistory(phone.db, id);
    expect(history.map((s) => s.pending), <bool>[false, false]);
    expect(history.map((s) => (s.from, s.to)), <(Place, Place)>[
      (inKueche, inKeller),
      (Place.none, inKueche),
    ]);
    expect(await phone.db.select(phone.db.placeHistory).get(), hasLength(2));
    expect(Place.of(await phone.entry(id)), inKeller);
  });

  test('the same code from a second device joins the existing entry (T13, '
      'D-443)', () async {
    final a = Phone(server, 'a', folder);
    final b = Phone(server, 'b', folder);
    await a.engine.pull();
    await b.engine.pull();
    final existing = await a.entries.createEntry(
      workspaceId: ws,
      customerId: customer,
      code: 'WIO-0007',
      title: 'Winterkleidung',
      place: inKueche,
    );
    expect((await a.engine.run()).stop, SyncStop.done);

    // b has not pulled since: it scans the same label, places the box in
    // the cellar and takes a picture.
    final mine = await b.entries.createEntry(
      workspaceId: ws,
      customerId: customer,
      code: 'WIO-0007',
      place: inKeller,
    );
    final picture = await b.takePicture(mine);
    expect((await b.engine.run()).stop, SyncStop.done);

    expect(server.live('entries'), hasLength(1));
    expect(server.live('pictures')[picture]!['entry_id'], existing);
    expect(server.live('entries')[existing]!['room_id'], keller);
    expect(server.live('entries')[existing]!['title'], 'Winterkleidung');

    final rows = await b.db.select(b.db.rejectedChanges).get();
    expect(rows.single.reason, 'duplicate');
    expect(rows.single.existingId, existing);
    expect(rows.single.entityId, mine);
    final list = await b.rejected();
    expect(list.single.name, 'Winterkleidung');
    expect(list.single.canResend, isFalse);

    final history = await placeHistory(b.db, existing);
    expect(
      history.map((s) => (s.from, s.to, s.pending)),
      <(Place, Place, bool)>[
        (inKueche, inKeller, false),
        (Place.none, inKueche, false),
      ],
    );
    expect(await b.db.select(b.db.entries).get(), hasLength(1));
    expect(Place.of(await b.entry(existing)), inKeller);
  });

  test('a refused move: place back, pending step gone, listed (T14)', () async {
    final phone = Phone(server, 'a', folder);
    await phone.engine.pull();
    final id = await phone.entries.createEntry(
      workspaceId: ws,
      customerId: customer,
      place: inKueche,
    );
    expect((await phone.engine.run()).stop, SyncStop.done);

    server.refuse = (c) => c['op'] == 'move_entry' ? 'permission' : null;
    await phone.entries.move(id, inKeller);
    expect(Place.of(await phone.entry(id)), inKeller);
    expect((await phone.engine.run()).stop, SyncStop.done);

    expect(Place.of(await phone.entry(id)), inKueche);
    final history = await placeHistory(phone.db, id);
    expect(history.single.to, inKueche);
    expect(history.single.pending, isFalse);
    final rows = await phone.db.select(phone.db.rejectedChanges).get();
    expect(rows.single.op, 'move_entry');
  });

  test('a picture of an entry not yet sent goes after it (T15)', () async {
    final phone = Phone(server, 'a', folder);
    await phone.engine.pull();
    final id = await phone.entries.createEntry(
      workspaceId: ws,
      customerId: customer,
    );
    final picture = await phone.takePicture(id);
    expect(
      (await (phone.db.select(
        phone.db.pictures,
      )..where((p) => p.id.equals(picture))).getSingle()).customerId,
      customer,
    );
    expect((await phone.engine.run()).stop, SyncStop.done);
    expect(server.live('pictures')[picture]!['entry_id'], id);
  });

  test('an NFD twin of a label is joined by the server (T18, D-441)', () async {
    // The real server's key applies NFC; this fake one composes the one
    // character the test needs.
    server.nameKey = (name) => name
        .replaceAll('ü', 'ü')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
    const nfc = 'Küche';
    const nfd = 'Küche';
    expect(localNameKey(nfc), isNot(localNameKey(nfd)));

    final a = Phone(server, 'a', folder);
    final b = Phone(server, 'b', folder);
    await a.engine.pull();
    await b.engine.pull();
    final label = await a.entries.labelNamed(workspaceId: ws, name: nfc);
    expect((await a.engine.run()).stop, SyncStop.done);

    final entry = await b.entries.createEntry(
      workspaceId: ws,
      customerId: customer,
    );
    final twin = await b.entries.labelNamed(workspaceId: ws, name: nfd);
    expect(twin, isNot(label));
    await b.entries.addLabel((type: 'entry', id: entry), twin);
    expect((await b.engine.run()).stop, SyncStop.done);

    expect(server.live('labels').keys, <String>[label]);
    expect(server.live('entity_labels').values.single['label_id'], label);
    final labels = await watchLabelsOf(b.db, (type: 'entry', id: entry)).first;
    expect(labels.single.label.id, label);
    expect(labels.single.label.name, nfc);
    expect(await watchLabels(b.db).first, hasLength(1));
    final rejected = await b.db.select(b.db.rejectedChanges).getSingle();
    expect(rejected.entity, 'labels');
    expect(rejected.reason, 'duplicate');
  });

  test('a target from two phones: all seven fields, the later pair wins; '
      'Kein Ziel reaches the other phone (plan 107)', () async {
    final a = Phone(server, 'a', folder);
    final b = Phone(server, 'b', folder);
    await a.engine.pull();
    final id = await a.entries.createEntry(
      workspaceId: ws,
      customerId: customer,
    );
    expect((await a.engine.run()).stop, SyncStop.done);
    await b.engine.pull();

    await a.entries.setTarget(id, inKueche);
    await b.entries.setTarget(id, inKeller);
    final change = (await b.outbox()).single;
    expect(change.op, 'upsert');
    expect((jsonDecode(change.fields) as Map<String, Object?>).keys.toSet(), {
      'target_site_id',
      'target_room_id',
      'target_fixture_id',
      'target_level',
      'target_compartment',
      'target_floor_x_cm',
      'target_floor_y_cm',
    });

    expect((await a.engine.run()).stop, SyncStop.done);
    expect((await b.engine.run()).stop, SyncStop.done);
    await a.engine.pull();
    expect(server.live('entries')[id]!['target_room_id'], keller);
    expect(Place.targetOf(await a.entry(id)), inKeller);
    expect(Place.targetOf(await b.entry(id)), inKeller);

    await a.entries.setTarget(id, Place.none);
    expect((await a.engine.run()).stop, SyncStop.done);
    await b.engine.pull();
    expect(Place.targetOf(await b.entry(id)), Place.none);
  });
}
