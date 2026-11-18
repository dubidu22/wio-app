// The upload queue against the fake sync server (plan 044b tests T15a to
// T15l, D-208 to D-218). Real files in a temporary folder; no network.
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
import 'package:wio_app/update/app_too_old.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/test_data.dart';

const int mib = 1024 * 1024;

/// One phone with its database, its upload folder and a fresh worker per
/// run, as the runner makes one per run.
class Phone {
  Phone(this.server, {this.name = 'a'}) : db = memoryDatabase() {
    folder = Directory.systemTemp.createTempSync('wio_uploads_');
    store = UploadStore(() async => folder.path);
    addTearDown(db.close);
    addTearDown(() => folder.deleteSync(recursive: true));
  }

  final FakeSyncServer server;
  final String name;
  final WioDatabase db;
  late final Directory folder;
  late final UploadStore store;
  AppTooOld? tooOldState;

  Server get _server => buildApiServer(
    fakeApiBase,
    server.clientFor(name),
    exampleSession,
    ApiHooks(tooOld: () => tooOldState, reportTooOld: (t) => tooOldState ??= t),
  );

  UploadWorker worker() => UploadWorker(
    db: db,
    api: FilesApi(_server),
    store: store,
    tooOld: () => tooOldState != null,
  );

  SyncEngine engine() => SyncEngine(
    db: db,
    api: SyncApi(_server),
    workspaceId: FakeSyncServer.defaultWorkspace,
    tooOld: () => tooOldState != null,
    uploads: worker(),
  );

  /// A source file outside the upload folder with [size] seeded bytes.
  File source(int size, {int seed = 1}) {
    final random = Random(seed);
    final bytes = Uint8List(size);
    for (var i = 0; i < size; i++) {
      bytes[i] = random.nextInt(256);
    }
    final file = File(
      '${Directory.systemTemp.createTempSync('wio_source_').path}/f',
    )..writeAsBytesSync(bytes);
    addTearDown(() => file.parent.deleteSync(recursive: true));
    return file;
  }

  Future<String> enqueue(File file) =>
      enqueueUpload(db, store, file.path, now: DateTime.utc(2026, 11, 19, 12));

  Future<List<Upload>> rows() => db.select(db.uploads).get();

  List<String> copies() => <String>[
    for (final entry in folder.listSync(recursive: true))
      if (entry is File) entry.uri.pathSegments.last,
  ];
}

void main() {
  late FakeSyncServer server;

  setUp(() => server = FakeSyncServer());

  test(
    'a 9 MB file goes in chunks of 4 MiB and leaves nothing (T15a)',
    () async {
      final phone = Phone(server);
      final file = phone.source(9000000);
      final sha = await phone.enqueue(file);
      expect(sha, sha256Of(file.readAsBytesSync()));
      expect(phone.copies(), <String>[sha]);
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.chunks, <String>[
        'bytes 0-4194303/9000000',
        'bytes 4194304-8388607/9000000',
        'bytes 8388608-8999999/9000000',
      ]);
      expect(server.files[sha], file.readAsBytesSync());
      expect(await phone.rows(), isEmpty);
      expect(phone.copies(), isEmpty);
    },
  );

  test('a restart resumes from what the server holds (T15b)', () async {
    final phone = Phone(server);
    final file = phone.source(9000000);
    final sha = await phone.enqueue(file);
    server.putPart(sha, file.readAsBytesSync().sublist(0, 4 * mib), 9000000);
    expect((await phone.worker().run()).stop, SyncStop.done);
    expect(server.chunks, <String>[
      'bytes 4194304-8388607/9000000',
      'bytes 8388608-8999999/9000000',
    ]);
    expect(server.files[sha], file.readAsBytesSync());
  });

  test('a lost chunk answer stops the run; the next one goes on', () async {
    final phone = Phone(server);
    final file = phone.source(9000000);
    final sha = await phone.enqueue(file);
    server.loseChunkAnswers = 1;
    expect((await phone.worker().run()).stop, SyncStop.offline);
    expect((await phone.rows()).single.failedReason, isNull);
    expect(phone.copies(), <String>[sha]);
    expect((await phone.worker().run()).stop, SyncStop.done);
    // The first chunk went once.
    expect(server.chunks, hasLength(3));
    expect(server.files[sha], file.readAsBytesSync());
  });

  test('409 continues from the received size (T15c)', () async {
    final phone = Phone(server);
    final file = phone.source(9000000);
    final sha = await phone.enqueue(file);
    server.afterRequest = (key) {
      if (key.endsWith('/state') && server.chunks.isEmpty) {
        server.putPart(
          sha,
          file.readAsBytesSync().sublist(0, 4 * mib),
          9000000,
        );
      }
    };
    expect((await phone.worker().run()).stop, SyncStop.done);
    expect(server.chunks, <String>[
      'bytes 0-4194303/9000000',
      'bytes 4194304-8388607/9000000',
      'bytes 8388608-8999999/9000000',
    ]);
    // The 409 answer itself says where to go on: no second state request.
    expect(server.requests, hasLength(4));
    expect(server.files[sha], file.readAsBytesSync());
  });

  group('422 hash_mismatch (T15d, T15e)', () {
    test('an intact copy starts again once and completes', () async {
      final phone = Phone(server);
      final sha = await phone.enqueue(phone.source(mib));
      server.breakHash[sha] = 1;
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.chunks, <String>[
        'bytes 0-1048575/1048576',
        'bytes 0-1048575/1048576',
      ]);
      expect(server.files, contains(sha));
      expect(await phone.rows(), isEmpty);
    });

    test('a second 422 in the run marks the file damaged', () async {
      final phone = Phone(server);
      final sha = await phone.enqueue(phone.source(mib));
      server.breakHash[sha] = 2;
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.chunks, hasLength(2));
      expect((await phone.rows()).single.failedReason, UploadFailure.damaged);
      // Kept until the owner discards it.
      expect(phone.copies(), <String>[sha]);
    });

    test('a changed copy is damaged at once', () async {
      final phone = Phone(server);
      final sha = await phone.enqueue(phone.source(mib));
      File('${phone.folder.path}/uploads/$sha')
          .writeAsBytesSync(Uint8List(mib));
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.chunks, hasLength(1));
      expect((await phone.rows()).single.failedReason, UploadFailure.damaged);
    });

    test('a missing copy is damaged without a request', () async {
      final phone = Phone(server);
      final sha = await phone.enqueue(phone.source(mib));
      File('${phone.folder.path}/uploads/$sha').deleteSync();
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.requests, isEmpty);
      expect((await phone.rows()).single.failedReason, UploadFailure.damaged);
    });
  });

  test(
    '403 forbidden marks files refused; a retry sends them (T15f)',
    () async {
      final phone = Phone(server);
      final first = await phone.enqueue(phone.source(1000));
      final second = await phone.enqueue(phone.source(2000, seed: 2));
      server.helpers.add('a');
      expect((await phone.worker().run()).stop, SyncStop.done);
      final rows = await phone.rows();
      expect(rows.map((r) => r.failedReason), <String>[
        UploadFailure.permission,
        UploadFailure.permission,
      ]);
      // Failed rows are not tried again by themselves.
      final before = server.requests.length;
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.requests, hasLength(before));
      server.helpers.clear();
      for (final row in rows) {
        await retryUpload(phone.db, row);
      }
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.files.keys, containsAll(<String>[first, second]));
      expect(await phone.rows(), isEmpty);
    },
  );

  group('too large (T15g)', () {
    test('a 413 chunk answer marks the file too large', () async {
      final phone = Phone(server);
      await phone.enqueue(phone.source(1000));
      server.afterRequest = (key) {
        if (key.endsWith('/state')) server.fileStatus = 413;
      };
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect((await phone.rows()).single.failedReason, UploadFailure.tooLarge);
    });

    test('a file over 100 MiB fails at once without a copy', () async {
      final phone = Phone(server);
      final big = File(
        '${Directory.systemTemp.createTempSync('wio_big_').path}/big',
      );
      addTearDown(() => big.parent.deleteSync(recursive: true));
      big.openSync(mode: FileMode.write)
        ..truncateSync(100 * mib + 1)
        ..closeSync();
      await phone.enqueue(big);
      final row = (await phone.rows()).single;
      expect(row.failedReason, UploadFailure.tooLarge);
      expect(row.path, isEmpty);
      expect(phone.copies(), isEmpty);
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.requests, isEmpty);
    });
  });

  test('400 marks the file invalid', () async {
    final phone = Phone(server);
    await phone.enqueue(phone.source(1000));
    server.fileStatus = 400;
    expect((await phone.worker().run()).stop, SyncStop.done);
    expect((await phone.rows()).single.failedReason, UploadFailure.invalid);
  });

  group('empty files (T15h, D-209)', () {
    test('are not queued', () async {
      final phone = Phone(server);
      final sha = await phone.enqueue(phone.source(0));
      expect(sha, emptyFileSha256);
      expect(await phone.rows(), isEmpty);
      expect(phone.copies(), isEmpty);
    });

    test('a size-0 row is removed without a request', () async {
      final phone = Phone(server);
      await phone.db
          .into(phone.db.uploads)
          .insert(
            UploadsCompanion.insert(
              sha256: emptyFileSha256,
              path: '${phone.folder.path}/uploads/$emptyFileSha256',
              size: 0,
              createdAt: '2026-11-19T12:00:00.000Z',
            ),
          );
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.requests, isEmpty);
      expect(await phone.rows(), isEmpty);
    });
  });

  group('stops (T15i)', () {
    test('426 in the middle of a file keeps row and copy', () async {
      final phone = Phone(server);
      final file = phone.source(9000000);
      final sha = await phone.enqueue(file);
      server.afterRequest = (key) {
        if (key.startsWith('PUT') && server.chunks.length == 1) {
          server.tooOld = true;
        }
      };
      expect((await phone.worker().run()).stop, SyncStop.tooOld);
      final requests = server.requests.length;
      expect((await phone.worker().run()).stop, SyncStop.tooOld);
      // Too old: no further request at all.
      expect(server.requests, hasLength(requests));
      expect((await phone.rows()).single.failedReason, isNull);
      expect(phone.copies(), <String>[sha]);
      server
        ..tooOld = false
        ..afterRequest = null;
      phone.tooOldState = null;
      expect((await phone.worker().run()).stop, SyncStop.done);
      expect(server.files[sha], file.readAsBytesSync());
    });

    test('401 token_invalid stops as signed out', () async {
      final phone = Phone(server);
      await phone.enqueue(phone.source(1000));
      server
        ..fileStatus = 401
        ..fileCode = 'token_invalid';
      expect((await phone.worker().run()).stop, SyncStop.signedOut);
      expect((await phone.rows()).single.failedReason, isNull);
    });

    test('503 stops as offline and keeps the file pending', () async {
      final phone = Phone(server);
      await phone.enqueue(phone.source(1000));
      server.fileStatus = 503;
      expect((await phone.worker().run()).stop, SyncStop.offline);
      expect((await phone.rows()).single.failedReason, isNull);
    });
  });

  test('the same file twice is one upload (T15j)', () async {
    final phone = Phone(server);
    final file = phone.source(5000);
    final copy = File('${file.parent.path}/g')
      ..writeAsBytesSync(file.readAsBytesSync());
    final a = await phone.enqueue(file);
    final b = await phone.enqueue(copy);
    expect(a, b);
    expect(await phone.rows(), hasLength(1));
    expect(phone.copies(), <String>[a]);
    expect((await phone.worker().run()).stop, SyncStop.done);
    expect(server.chunks, hasLength(1));
  });

  test('new changes end the upload phase between files (T15k)', () async {
    final phone = Phone(server);
    await phone.enqueue(phone.source(1000));
    await phone.enqueue(phone.source(2000, seed: 2));
    final writer = LocalWriter(
      phone.db,
      clock: () => DateTime.utc(2026, 11, 19),
    );
    server.afterRequest = (key) {
      if (key.startsWith('PUT') && server.files.length == 1) {
        server.afterRequest = null;
        writer.write(
          entity: 'customers',
          id: newUuidV7(),
          fields: <String, Object?>{
            'workspace_id': FakeSyncServer.defaultWorkspace,
            'name': 'Neu',
          },
        );
      }
    };
    final result = await phone.worker().run();
    expect(result.stop, SyncStop.done);
    expect(result.more, isTrue);
    expect(server.files, hasLength(1));
    expect(await phone.rows(), hasLength(1));
  });

  test('a run pushes, pulls, then uploads (D-208)', () async {
    final phone = Phone(server);
    await LocalWriter(phone.db, clock: () => DateTime.utc(2026, 11, 19)).write(
      entity: 'customers',
      id: newUuidV7(),
      fields: <String, Object?>{
        'workspace_id': FakeSyncServer.defaultWorkspace,
        'name': 'Neu',
      },
    );
    final sha = await phone.enqueue(phone.source(1000));
    expect((await phone.engine().run()).stop, SyncStop.done);
    expect(server.requests, <String>[
      'POST /sync/push',
      'GET /sync/pull',
      'GET /files/$sha/state',
      'PUT /files/$sha',
    ]);
  });

  test(
    'random loss: every file arrives, no chunk sent many times (T15l)',
    () async {
      server
        ..random = Random(44)
        ..lossRate = 0.3;
      final phone = Phone(server);
      final sizes = <int>[9000000, 5 * mib, 3000];
      final files = <String, File>{};
      for (final (i, size) in sizes.indexed) {
        final file = phone.source(size, seed: i + 10);
        files[await phone.enqueue(file)] = file;
      }
      for (var run = 0; run < 200 && (await phone.rows()).isNotEmpty; run++) {
        await phone.worker().run();
      }
      expect(await phone.rows(), isEmpty, reason: 'seed 44');
      for (final MapEntry(:key, :value) in files.entries) {
        expect(server.files[key], value.readAsBytesSync());
      }
      // Each chunk is resent only after a loss: bounded by the requests.
      final chunks = sizes.fold<int>(
        0,
        (n, s) => n + (s + 4 * mib - 1) ~/ (4 * mib),
      );
      expect(server.chunks.length, lessThan(chunks * 4));
    },
  );

  test('the start-up sweep removes copies without a row (W2, D-215)', () async {
    final phone = Phone(server);
    final kept = await phone.enqueue(phone.source(1000));
    final gone = await phone.enqueue(phone.source(2000, seed: 2));
    final row = (await phone.rows()).firstWhere((r) => r.sha256 == gone);
    await discardUpload(phone.db, row);
    // Rückgängig still finds the copy until the sweep.
    expect(phone.copies(), containsAll(<String>[kept, gone]));
    await sweepUploads(phone.db, phone.store);
    expect(phone.copies(), <String>[kept]);
  });
}
