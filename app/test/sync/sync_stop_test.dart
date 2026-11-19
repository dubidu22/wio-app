// Safe stop points and runs without files (plan 052 tests T2 to T4,
// D-375, D-378). Against the fake sync server; real files in a temporary
// folder; no network.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_api/wio_api.dart' show FilesApi, Server, SyncApi;
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/ids.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/sync/sync_engine.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/test_data.dart';

const String ws = FakeSyncServer.defaultWorkspace;

/// One phone with an upload folder; [stop] is what the run's stop hook
/// answers.
class Phone {
  Phone(this.server) : db = memoryDatabase() {
    folder = Directory.systemTemp.createTempSync('wio_stop_');
    store = UploadStore(() async => folder.path);
    addTearDown(db.close);
    addTearDown(() => folder.deleteSync(recursive: true));
  }

  final FakeSyncServer server;
  final WioDatabase db;
  late final Directory folder;
  late final UploadStore store;
  bool stop = false;

  Server get _server => buildApiServer(
    fakeApiBase,
    server.clientFor('a'),
    exampleSession,
    ApiHooks(tooOld: () => null, reportTooOld: (_) {}),
  );

  SyncEngine engine({bool files = true}) => SyncEngine(
    db: db,
    api: SyncApi(_server),
    workspaceId: ws,
    tooOld: () => false,
    files: files,
    stopped: () => stop,
    clock: () => DateTime.utc(2026, 11, 19, 12),
    uploads: UploadWorker(
      db: db,
      api: FilesApi(_server),
      store: store,
      tooOld: () => false,
      stopped: () => stop,
    ),
  );

  Future<String> enqueue(int size) async {
    final random = Random(size);
    final bytes = Uint8List(size);
    for (var i = 0; i < size; i++) {
      bytes[i] = random.nextInt(256);
    }
    final source = File('${folder.path}/source')..writeAsBytesSync(bytes);
    final sha = await enqueueUpload(
      db,
      store,
      source.path,
      now: DateTime.utc(2026, 11, 19, 12),
    );
    source.deleteSync();
    return sha;
  }

  Future<int> lastRevision() async =>
      (await (db.select(
            db.syncState,
          )..where((s) => s.workspaceId.equals(ws))).getSingleOrNull())
          ?.lastRevision ??
      0;

  Future<int> outbox() async => (await db.select(db.outbox).get()).length;
}

void main() {
  late FakeSyncServer server;

  setUp(() => server = FakeSyncServer());

  test('a stop during an upload ends after the current chunk; the next run '
      'resumes from the server (T3)', () async {
    final phone = Phone(server);
    final sha = await phone.enqueue(9000000);
    server.afterRequest = (key) {
      if (server.chunks.length == 1) phone.stop = true;
    };
    expect((await phone.engine().run()).stop, SyncStop.interrupted);
    expect(server.chunks, <String>['bytes 0-4194303/9000000']);
    expect(await phone.db.select(phone.db.uploads).get(), hasLength(1));

    server.afterRequest = null;
    phone.stop = false;
    expect((await phone.engine().run()).stop, SyncStop.done);
    expect(server.chunks, <String>[
      'bytes 0-4194303/9000000',
      'bytes 4194304-8388607/9000000',
      'bytes 8388608-8999999/9000000',
    ]);
    expect(server.files.keys, <String>[sha]);
    expect(await phone.db.select(phone.db.uploads).get(), isEmpty);
  });

  test('a stop between pull pages keeps the applied page (T4)', () async {
    for (var i = 0; i < 1200; i++) {
      server.put('customers', newUuidV7(), <String, Object?>{'name': 'K$i'});
    }
    final phone = Phone(server);
    server.afterRequest = (key) {
      if (key == 'GET /sync/pull') phone.stop = true;
    };
    expect((await phone.engine().run()).stop, SyncStop.interrupted);
    expect(server.requests.where((r) => r == 'GET /sync/pull'), hasLength(1));
    expect(await phone.lastRevision(), 500);
    expect(await phone.db.select(phone.db.customers).get(), hasLength(500));

    server.afterRequest = null;
    phone.stop = false;
    expect((await phone.engine().run()).stop, SyncStop.done);
    expect(await phone.lastRevision(), 1200);
  });

  test('a stop before the run sends nothing', () async {
    final phone = Phone(server);
    await LocalWriter(phone.db).write(
      entity: 'customers',
      id: newUuidV7(),
      fields: <String, Object?>{'workspace_id': ws, 'name': 'Neu'},
    );
    phone.stop = true;
    expect((await phone.engine().run()).stop, SyncStop.interrupted);
    expect(server.requests, isEmpty);
    expect(await phone.outbox(), 1);
  });

  test('a run without files pushes and pulls but sends no file (T2)', () async {
    final phone = Phone(server);
    await phone.enqueue(1000);
    await LocalWriter(phone.db).write(
      entity: 'customers',
      id: newUuidV7(),
      fields: <String, Object?>{'workspace_id': ws, 'name': 'Neu'},
    );
    expect((await phone.engine(files: false).run()).stop, SyncStop.done);
    expect(server.requests, <String>['POST /sync/push', 'GET /sync/pull']);
    expect(await phone.outbox(), 0);
    expect(await phone.db.select(phone.db.uploads).get(), hasLength(1));

    expect((await phone.engine().run()).stop, SyncStop.done);
    expect(server.chunks, hasLength(1));
    expect(await phone.db.select(phone.db.uploads).get(), isEmpty);
  });
}
