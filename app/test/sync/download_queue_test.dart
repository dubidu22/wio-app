// Downloads of files made on other devices against the fake sync server
// (plan 062, D-326 to D-336). No real network; real files in a temporary
// media folder.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_api/wio_api.dart' show FilesApi, SyncApi;
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/sync/download_queue.dart';
import 'package:wio_app/sync/sync_engine.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/test_data.dart';

const String ws = FakeSyncServer.defaultWorkspace;
const String customer = '01970000-0000-7000-8000-0000000000c1';
const String room = '01970000-0000-7000-8000-0000000000b1';

/// Bytes of a file of [size] bytes, different per [seed].
Uint8List fileBytes(int size, int seed) =>
    Uint8List.fromList(List<int>.generate(size, (i) => (i * 31 + seed) & 0xff));

/// A media store whose writes fail, as on a full disk (D-336).
class FullStore extends MediaStore {
  FullStore(String base) : super(() async => base);

  @override
  Future<void> writePart(
    String sha256,
    List<int> bytes, {
    bool restart = false,
  }) async => throw const FileSystemException('No space left on device');
}

/// The second phone: pulls rows, then fetches their files.
class Phone {
  Phone(this.server, this.folder, {MediaStore? store}) : db = memoryDatabase() {
    final api = buildApiServer(
      fakeApiBase,
      server.clientFor('b'),
      exampleSession,
      ApiHooks(tooOld: () => null, reportTooOld: (_) {}),
    );
    media = store ?? MediaStore(() async => folder.path);
    worker = DownloadWorker(
      db: db,
      api: FilesApi(api),
      store: media,
      memory: memory,
      present: () => present,
      markPresent: present.add,
      setLoading: loading.add,
      wanted: () => wanted,
      tooOld: () => tooOld,
    );
    engine = SyncEngine(
      db: db,
      api: SyncApi(api),
      workspaceId: ws,
      tooOld: () => tooOld,
      clock: () => DateTime.utc(2026, 11, 19, 12),
      uploads: UploadWorker(
        db: db,
        api: FilesApi(api),
        store: UploadStore(() async => folder.path),
        tooOld: () => tooOld,
      ),
      downloads: worker,
    );
    addTearDown(db.close);
  }

  final FakeSyncServer server;
  final Directory folder;
  final WioDatabase db;
  final DownloadMemory memory = DownloadMemory();
  final Set<String> present = <String>{};
  final List<Set<String>> loading = <Set<String>>[];
  Set<String> wanted = <String>{};
  bool tooOld = false;
  late final MediaStore media;
  late final DownloadWorker worker;
  late final SyncEngine engine;

  File file(String sha) => File('${folder.path}/media/$sha');
  File part(String sha) => File('${folder.path}/media/$sha.part');
}

void main() {
  late FakeSyncServer server;
  late Directory folder;
  late Phone phone;
  var ids = 0;

  /// A picture another device made, with its file on the server.
  String picture(Uint8List bytes, {String? createdAt, bool onServer = true}) {
    final sha = sha256Of(bytes);
    if (onServer) server.files[sha] = bytes;
    final record = server.put(
      'pictures',
      '01970000-0000-7000-8000-0000000001${(ids++).toString().padLeft(2, '0')}',
      <String, Object?>{
        'customer_id': customer,
        'file_sha256': sha,
        'file_bytes': bytes.length,
        'file_mime': 'image/jpeg',
        'width_px': 2560,
        'height_px': 1920,
        'taken_at': null,
        'room_id': room,
        'entry_id': null,
        'after_of': null,
      },
    );
    if (createdAt != null) record['created_at'] = createdAt;
    return sha;
  }

  setUp(() async {
    server = FakeSyncServer()
      ..put('customers', customer, <String, Object?>{
        'name': 'Familie Beispiel',
      });
    folder = await Directory.systemTemp.createTemp('download_queue_test');
    phone = Phone(server, folder);
  });
  tearDown(() => folder.delete(recursive: true));

  test('a picture from another device is fetched in 4 MiB ranges, hash '
      'checked, and named (T1)', () async {
    final bytes = fileBytes(9 * 1024 * 1024 + 5, 1);
    final sha = picture(bytes);
    expect((await phone.engine.run()).stop, SyncStop.done);

    expect(phone.file(sha).readAsBytesSync(), bytes);
    expect(phone.part(sha).existsSync(), isFalse);
    expect(phone.present, contains(sha));
    expect(server.downloads.map((d) => d.range), <String>[
      'bytes=0-4194303',
      'bytes=4194304-8388607',
      'bytes=8388608-12582911',
    ]);
    expect(server.downloads.first.ifRange, isNull);
    expect(server.downloads.last.ifRange, '"$sha"');
    // "wird geladen" while it came in, nothing after the step (D-333).
    expect(phone.loading.first, <String>{sha});
    expect(phone.loading.last, isEmpty);
  });

  test(
    'a recording of a note is fetched too, a tombstoned row is not',
    () async {
      final audio = fileBytes(3000, 2);
      final sha = sha256Of(audio);
      server
        ..files[sha] = audio
        ..put(
          'notes',
          '01970000-0000-7000-8000-0000000002e1',
          <String, Object?>{
            'customer_id': customer,
            'subject_type': 'room',
            'subject_id': room,
            'text': null,
            'audio_sha256': sha,
            'audio_bytes': audio.length,
            'audio_seconds': 3,
            'transcript': null,
            'transcript_source': null,
          },
        );
      final gone = picture(fileBytes(100, 3));
      final record = server.records['pictures']!.values.last;
      record['deleted_at'] = '2026-11-02T08:00:00.000Z';
      await phone.engine.run();
      expect(phone.file(sha).readAsBytesSync(), audio);
      expect(phone.file(gone).existsSync(), isFalse);
    },
  );

  test('wrong bytes are never kept: one retry, then left until restart '
      '(T2, D-330)', () async {
    final once = picture(fileBytes(2000, 4));
    final twice = picture(fileBytes(2000, 5));
    server.serveWrongBytes[once] = 1;
    server.serveWrongBytes[twice] = 2;
    await phone.engine.run();
    expect(phone.file(once).existsSync(), isTrue, reason: 'second try fits');
    expect(phone.file(twice).existsSync(), isFalse);
    expect(phone.part(twice).existsSync(), isFalse);
    expect(phone.memory.skipped, contains(twice));
    final before = server.downloads.length;
    await phone.engine.run();
    expect(server.downloads.length, before, reason: 'not asked again');
  });

  test(
    'a lost answer resumes from the part on the next run (T3, D-329)',
    () async {
      final bytes = fileBytes(6 * 1024 * 1024, 6);
      final sha = picture(bytes);
      await phone.engine.pull();
      var gets = 0;
      server.afterRequest = (key) {
        if (key.startsWith('GET /files/') && ++gets == 2) {
          server.loseAnswers = 1;
        }
      };
      expect((await phone.worker.run()).stop, SyncStop.offline);
      expect(phone.part(sha).lengthSync(), 4 * 1024 * 1024);
      expect(phone.file(sha).existsSync(), isFalse);
      expect(phone.loading.last, isEmpty, reason: 'no "wird geladen" offline');

      expect((await phone.worker.run()).stop, SyncStop.done);
      expect(phone.file(sha).readAsBytesSync(), bytes);
      expect(server.downloads.last.range, 'bytes=4194304-8388607');
      expect(server.downloads.last.ifRange, '"$sha"');
    },
  );

  test(
    '404 means not there yet: tried again on the next run (D-331)',
    () async {
      final bytes = fileBytes(1000, 7);
      final sha = picture(bytes, onServer: false);
      expect((await phone.engine.run()).stop, SyncStop.done);
      expect(phone.file(sha).existsSync(), isFalse);
      expect(phone.memory.skipped, isEmpty);
      server.files[sha] = bytes;
      await phone.engine.run();
      expect(phone.file(sha).existsSync(), isTrue);
    },
  );

  test('416 starts from 0 once; a second 416 leaves the file until restart '
      '(D-331)', () async {
    final once = picture(fileBytes(1000, 8));
    final twice = picture(fileBytes(1000, 9));
    server.refuseRange[once] = 1;
    server.refuseRange[twice] = 2;
    await phone.engine.run();
    expect(phone.file(once).existsSync(), isTrue);
    expect(phone.file(twice).existsSync(), isFalse);
    expect(phone.memory.skipped, contains(twice));
    final before = server.downloads.length;
    await phone.engine.run();
    await phone.engine.run();
    expect(server.downloads.length, before);
  });

  group('a part that already holds the whole file (#82)', () {
    test('416 with the total: the part is checked and named, no new '
        'download', () async {
      final bytes = fileBytes(1000, 21);
      final sha = picture(bytes);
      phone.part(sha)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);
      await phone.engine.run();
      expect(phone.file(sha).readAsBytesSync(), bytes);
      expect(phone.part(sha).existsSync(), isFalse);
      expect(server.downloads, hasLength(1));
      expect(server.downloads.single.range, 'bytes=1000-4194303');
    });

    test('a wrong hash deletes the part and starts from 0', () async {
      final bytes = fileBytes(1000, 22);
      final sha = picture(bytes);
      phone.part(sha)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes(1000, 23));
      await phone.engine.run();
      expect(phone.file(sha).readAsBytesSync(), bytes);
      expect(server.downloads.map((d) => d.range), <String?>[
        'bytes=1000-4194303',
        'bytes=0-4194303',
      ]);
    });

    test('a part bigger than the file starts from 0', () async {
      final bytes = fileBytes(1000, 24);
      final sha = picture(bytes);
      phone.part(sha)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes(1500, 24));
      await phone.engine.run();
      expect(phone.file(sha).readAsBytesSync(), bytes);
      expect(server.downloads.last.range, 'bytes=0-4194303');
    });

    test('a missing size starts from 0 as before (D-331)', () async {
      final bytes = fileBytes(1000, 25);
      final sha = picture(bytes);
      server.hideRangeSize.add(sha);
      phone.part(sha)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);
      await phone.engine.run();
      expect(phone.file(sha).readAsBytesSync(), bytes);
      expect(server.downloads.last.range, 'bytes=0-4194303');
    });
  });

  test('403 and 400 leave the file until restart', () async {
    picture(fileBytes(10, 10));
    server.fileStatus = 403;
    await phone.engine.pull();
    expect((await phone.worker.run()).stop, SyncStop.done);
    expect(phone.memory.skipped, hasLength(1));
  });

  test('401, 426 and 503 stop the run as uploads do', () async {
    picture(fileBytes(10, 11));
    await phone.engine.pull();
    server
      ..fileStatus = 401
      ..fileCode = 'token_invalid';
    expect((await phone.worker.run()).stop, SyncStop.signedOut);
    server
      ..fileStatus = 426
      ..fileCode = 'upgrade_required';
    expect((await phone.worker.run()).stop, SyncStop.tooOld);
    server
      ..fileStatus = 503
      ..fileCode = 'maintenance';
    expect((await phone.worker.run()).stop, SyncStop.offline);
    expect(phone.memory.skipped, isEmpty);
  });

  test(
    'order: files a screen shows first, then the newest rows (D-328)',
    () async {
      final old = picture(fileBytes(10, 12), createdAt: '2026-11-01T08:00:00Z');
      final mid = picture(fileBytes(10, 13), createdAt: '2026-11-10T08:00:00Z');
      final now = picture(fileBytes(10, 14), createdAt: '2026-11-19T08:00:00Z');
      phone.wanted = <String>{old};
      await phone.engine.run();
      final order = <String>[
        for (final d in server.requests)
          if (d.startsWith('GET /files/')) d.split('/')[2],
      ];
      expect(order, <String>[old, now, mid]);
    },
  );

  test('new changes and uploads go first: the step yields (D-326)', () async {
    final sha = picture(fileBytes(6 * 1024 * 1024, 15));
    await phone.engine.pull();
    var gets = 0;
    server.afterRequest = (key) {
      if (key.startsWith('GET /files/') && ++gets == 1) {
        // A local change while the first range comes in.
        LocalWriter(phone.db).write(
          entity: 'customers',
          id: customer,
          fields: <String, Object?>{'name': 'Neu'},
        );
      }
    };
    final result = await phone.worker.run();
    expect(result.more, isTrue);
    expect(phone.part(sha).existsSync(), isTrue, reason: 'part kept');
    // The engine pushes first, then finishes the file.
    server.afterRequest = null;
    expect((await phone.engine.run()).stop, SyncStop.done);
    expect(phone.file(sha).existsSync(), isTrue);
  });

  test('nothing is fetched while presence is not known', () async {
    picture(fileBytes(10, 16));
    await phone.engine.pull();
    final worker = DownloadWorker(
      db: phone.db,
      api: FilesApi(
        buildApiServer(
          fakeApiBase,
          server.clientFor('b'),
          exampleSession,
          ApiHooks(tooOld: () => null, reportTooOld: (_) {}),
        ),
      ),
      store: phone.media,
      memory: DownloadMemory(),
      present: () => null,
      markPresent: (_) {},
      setLoading: (_) {},
      wanted: () => const <String>{},
      tooOld: () => false,
    );
    expect((await worker.run()).stop, SyncStop.done);
    expect(server.downloads, isEmpty);
  });

  test('files already here are not fetched', () async {
    final sha = picture(fileBytes(10, 17));
    phone.present.add(sha);
    await phone.engine.run();
    expect(server.downloads, isEmpty);
  });

  test('a 200 answer to a range request replaces the part (D-331)', () async {
    final bytes = fileBytes(3000, 18);
    final sha = picture(bytes);
    await phone.engine.pull();
    Directory('${folder.path}/media').createSync(recursive: true);
    phone.part(sha).writeAsBytesSync(fileBytes(1000, 99));
    server.ignoreRange.add(sha);
    expect((await phone.worker.run()).stop, SyncStop.done);
    expect(server.downloads.single.range, 'bytes=1000-4195303');
    expect(phone.file(sha).readAsBytesSync(), bytes);
    expect(phone.part(sha).existsSync(), isFalse);
  });

  test('a row deleted while its file comes in: stop, the part stays '
      '(D-336)', () async {
    final sha = picture(fileBytes(6 * 1024 * 1024, 19));
    await phone.engine.pull();
    server.afterRequest = (key) {
      if (key.startsWith('GET /files/')) {
        // Deleted on this phone without an outbox row, as a pulled tombstone.
        phone.db.customStatement(
          "UPDATE pictures SET deleted_at = '2026-11-19T12:00:00.000Z'",
        );
      }
    };
    expect((await phone.worker.run()).stop, SyncStop.done);
    expect(server.downloads, hasLength(1));
    expect(phone.part(sha).lengthSync(), 4 * 1024 * 1024);
    expect(phone.file(sha).existsSync(), isFalse);
  });

  test(
    'a failed write backs off and leaves the part as it was (D-336)',
    () async {
      final full = Phone(server, folder, store: FullStore(folder.path));
      final bytes = fileBytes(3000, 20);
      final sha = picture(bytes);
      await full.engine.pull();
      Directory('${folder.path}/media').createSync(recursive: true);
      full.part(sha).writeAsBytesSync(bytes.sublist(0, 1000));
      expect((await full.worker.run()).stop, SyncStop.failed);
      expect(full.part(sha).readAsBytesSync(), bytes.sublist(0, 1000));
      expect(full.file(sha).existsSync(), isFalse);
      expect(full.memory.skipped, isEmpty);
    },
  );
}
