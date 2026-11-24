// Files of long-deleted pictures and notes leave the device only after the
// server confirms it holds them (plan 099, #99, D-511..D-516), against the
// fake sync server. No real network; real files in a temporary folder.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryExecutor, QueryInterceptor, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wio_api/wio_api.dart' show FilesApi, Server, SyncApi;
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/media/media_sweep.dart';
import 'package:wio_app/sync/download_queue.dart';
import 'package:wio_app/sync/sync_engine.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';

const String ws = FakeSyncServer.defaultWorkspace;
const String customer = '01970000-0000-7000-8000-0000000000c1';
const String room = '01970000-0000-7000-8000-0000000000b1';

/// When the test's records were deleted on the server.
const String deletedOn = '2026-11-02T08:00:00.000Z';

/// 31 and 29 days after [deletedOn].
final DateTime after31Days = DateTime.utc(2026, 12, 3, 8);
final DateTime after29Days = DateTime.utc(2026, 12, 1, 8);

Uint8List fileBytes(int size, int seed) =>
    Uint8List.fromList(List<int>.generate(size, (i) => (i * 31 + seed) & 0xff));

/// One phone with its media folder, download worker and engine.
class Phone {
  Phone(FakeSyncServer server, Directory folder)
    : this._(server, folder, Recorder());

  Phone._(this.server, this.folder, this.recorder)
    : db = WioDatabase(NativeDatabase.memory().interceptWith(recorder)) {
    api = buildApiServer(
      fakeApiBase,
      server.clientFor('b'),
      exampleSession,
      ApiHooks(tooOld: () => null, reportTooOld: (_) {}),
    );
    media = MediaStore(() async => folder.path);
    engine = SyncEngine(
      db: db,
      api: SyncApi(api),
      workspaceId: ws,
      tooOld: () => false,
      clock: () => now,
      stopped: () => stopped,
      downloads: DownloadWorker(
        db: db,
        api: FilesApi(api),
        store: media,
        memory: DownloadMemory(),
        present: () => present,
        markPresent: present.add,
        setLoading: (_) {},
        wanted: () => const <String>{},
        tooOld: () => false,
      ),
      releaseMedia: () async {
        releaseRuns++;
        await release();
      },
    );
    addTearDown(db.close);
  }

  final FakeSyncServer server;
  final Directory folder;
  final Recorder recorder;
  final WioDatabase db;
  late final Server api;
  late final MediaStore media;
  late final SyncEngine engine;
  final Set<String> present = <String>{};
  DateTime now = DateTime.utc(2026, 11, 3);
  bool stopped = false;
  int releaseRuns = 0;

  Future<int> release({FilesApi? files, Duration? timeout}) => releaseOldMedia(
    db,
    media,
    files ?? FilesApi(api),
    clock: () => now,
    stopped: () => stopped,
    released: present.remove,
    timeout: timeout ?? syncRequestTimeout,
  );

  File file(String sha) => File('${folder.path}/media/$sha');

  /// Puts [bytes] into the media folder, last changed long ago.
  String keep(Uint8List bytes) {
    final sha = sha256Of(bytes);
    Directory('${folder.path}/media').createSync(recursive: true);
    file(sha)
      ..writeAsBytesSync(bytes)
      ..setLastModifiedSync(DateTime(2020));
    present.add(sha);
    return sha;
  }

  bool has(String sha) => file(sha).existsSync();

  /// The selects run on [db] since the last `selects.clear()`.
  List<String> get selects => recorder.selects;
}

/// Records every select's statement text (#122, D-525).
class Recorder extends QueryInterceptor {
  final List<String> selects = <String>[];

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    selects.add(statement);
    return super.runSelect(executor, statement, args);
  }
}

/// Whether [statement] reads the fields of the outbox, refused changes or
/// server copies: the scan #122 keeps out of a run with nothing to release.
bool readsOtherTables(String statement) =>
    RegExp(r'\bfields\b').hasMatch(statement);

void main() {
  late FakeSyncServer server;
  late Directory folder;
  late Phone phone;
  var ids = 0;

  String nextId() =>
      '01970000-0000-7000-8000-${(0x100 + ids++).toRadixString(16).padLeft(12, '0')}';

  /// A picture on the server with its file, deleted at [deletedAt] (null:
  /// live). [rowBytes] is the size the record names.
  ({String id, String sha}) picture(
    Uint8List bytes, {
    String? deletedAt = deletedOn,
    int? rowBytes,
    bool onServer = true,
  }) {
    final sha = sha256Of(bytes);
    if (onServer) server.files[sha] = bytes;
    final id = nextId();
    server.put('pictures', id, <String, Object?>{
      'customer_id': customer,
      'file_sha256': sha,
      'file_bytes': rowBytes ?? bytes.length,
      'file_mime': 'image/jpeg',
      'width_px': 2560,
      'height_px': 1920,
      'taken_at': null,
      'room_id': room,
      'entry_id': null,
      'after_of': null,
    });
    server.records['pictures']![id]!['deleted_at'] = deletedAt;
    return (id: id, sha: sha);
  }

  /// A voice note on the server with its recording, deleted at [deletedOn].
  ({String id, String sha}) note(Uint8List audio) {
    final sha = sha256Of(audio);
    server.files[sha] = audio;
    final id = nextId();
    server.put('notes', id, <String, Object?>{
      'customer_id': customer,
      'subject_type': 'room',
      'subject_id': room,
      'text': null,
      'audio_sha256': sha,
      'audio_bytes': audio.length,
      'audio_seconds': 3,
      'transcript': null,
      'transcript_source': null,
    });
    server.records['notes']![id]!['deleted_at'] = deletedOn;
    return (id: id, sha: sha);
  }

  int stateRequests() => server.requests
      .where((r) => r.startsWith('GET /files/') && r.endsWith('/state'))
      .length;

  setUp(() async {
    server = FakeSyncServer()
      ..put('customers', customer, <String, Object?>{
        'name': 'Familie Beispiel',
      });
    folder = await Directory.systemTemp.createTemp('media_release_test');
    phone = Phone(server, folder);
    ids = 0;
  });
  tearDown(() => folder.delete(recursive: true));

  test('pictures and notes deleted 31 days ago go after a done run; 29 '
      'days ago stay (T1, D-511, D-513)', () async {
    final oldPicture = picture(fileBytes(3000, 1));
    final oldNote = note(fileBytes(2000, 2));
    final recent = picture(
      fileBytes(1000, 3),
      deletedAt: '2026-11-04T08:00:00Z',
    );
    for (final sha in <String>[oldPicture.sha, oldNote.sha, recent.sha]) {
      phone.keep(server.files[sha]!);
    }
    phone.now = after29Days;
    expect((await phone.engine.run()).stop, SyncStop.done);
    expect(phone.releaseRuns, 1);
    expect(phone.has(oldPicture.sha), isTrue, reason: '29 days only');
    expect(phone.has(oldNote.sha), isTrue);
    expect(stateRequests(), 0);

    phone.now = after31Days;
    expect((await phone.engine.run()).stop, SyncStop.done);
    expect(phone.has(oldPicture.sha), isFalse);
    expect(phone.has(oldNote.sha), isFalse);
    expect(phone.has(recent.sha), isTrue, reason: 'deleted 29 days ago');
    expect(phone.present, isNot(contains(oldPicture.sha)));
    expect(phone.present, contains(recent.sha));
    expect(stateRequests(), 2);
  });

  test('a live row or a newer tombstone with the same file keeps it '
      '(T2, D-511)', () async {
    final shared = fileBytes(3000, 4);
    final live = picture(shared, deletedAt: null);
    picture(shared);
    final twice = fileBytes(2000, 5);
    picture(twice);
    picture(twice, deletedAt: '2026-11-20T08:00:00Z');
    phone
      ..keep(shared)
      ..keep(twice);
    await phone.engine.run();
    phone.now = after31Days;
    expect(await phone.release(), 0);
    expect(phone.has(live.sha), isTrue);
    expect(phone.has(sha256Of(twice)), isTrue);
    expect(stateRequests(), 0);
  });

  test('an outbox, refused change, upload or other server copy naming the '
      'file keeps it (T3, D-511)', () async {
    final inOutbox = picture(fileBytes(1000, 6));
    final inRejected = picture(fileBytes(1001, 7));
    final inUploads = picture(fileBytes(1002, 8));
    final changed = picture(fileBytes(1003, 9));
    final free = picture(fileBytes(1004, 10));
    for (final p in <({String id, String sha})>[
      inOutbox,
      inRejected,
      inUploads,
      changed,
      free,
    ]) {
      phone.keep(server.files[p.sha]!);
    }
    await phone.engine.run();
    final db = phone.db;
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            changeId: 'c1',
            entity: 'pictures',
            entityId: nextId(),
            fields: jsonEncode(<String, Object?>{'file_sha256': inOutbox.sha}),
            deviceTime: '2026-12-03T08:00:00Z',
          ),
        );
    await db
        .into(db.rejectedChanges)
        .insert(
          RejectedChangesCompanion.insert(
            changeId: 'c2',
            entity: 'pictures',
            entityId: nextId(),
            op: 'upsert',
            fields: jsonEncode(<String, Object?>{
              'file_sha256': inRejected.sha,
            }),
            deviceTime: '2026-12-03T08:00:00Z',
            reason: 'validation',
            rejectedAt: '2026-12-03T08:00:01Z',
          ),
        );
    await db
        .into(db.uploads)
        .insert(
          UploadsCompanion.insert(
            sha256: inUploads.sha,
            path: '/uploads/${inUploads.sha}',
            size: 1002,
            createdAt: '2026-12-03T08:00:00Z',
          ),
        );
    // A restore queued on this phone for a deleted picture.
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            changeId: 'c3',
            entity: 'pictures',
            entityId: changed.id,
            op: const Value<String>('restore'),
            fields: '{}',
            deviceTime: '2026-12-03T08:00:00Z',
          ),
        );
    phone.now = after31Days;
    expect(await phone.release(), 1);
    expect(phone.has(free.sha), isFalse);
    for (final p in <({String id, String sha})>[
      inOutbox,
      inRejected,
      inUploads,
      changed,
    ]) {
      expect(phone.has(p.sha), isTrue);
    }
    expect(stateRequests(), 1);
  });

  test('two deleted rows naming the same file with different sizes keep it '
      'and ask nothing (D-511, PR 121 N2)', () async {
    final bytes = fileBytes(3000, 15);
    picture(bytes);
    picture(bytes, rowBytes: 2999);
    phone.keep(bytes);
    await phone.engine.run();
    phone.now = after31Days;
    expect(await releasableMediaHashes(phone.db, phone.now), isEmpty);
    expect(await phone.release(), 0);
    expect(stateRequests(), 0);
    expect(phone.has(sha256Of(bytes)), isTrue);
  });

  test('a restore queued while the server answers keeps the files: the '
      'candidates are read again before deleting (D-516, PR 121 M1)', () async {
    final first = picture(fileBytes(3000, 16));
    final second = picture(fileBytes(3001, 17));
    phone
      ..keep(server.files[first.sha]!)
      ..keep(server.files[second.sha]!);
    await phone.engine.run();
    phone.now = after31Days;
    expect(await releasableMediaHashes(phone.db, phone.now), hasLength(2));
    var queued = false;
    server.afterRequest = (key) {
      if (queued || !key.endsWith('/state')) return;
      queued = true;
      final db = phone.db;
      for (final (i, p) in <({String id, String sha})>[first, second].indexed) {
        unawaited(
          db
              .into(db.outbox)
              .insert(
                OutboxCompanion.insert(
                  changeId: 'restore-$i',
                  entity: 'pictures',
                  entityId: p.id,
                  op: const Value<String>('restore'),
                  fields: '{}',
                  deviceTime: '2026-12-03T08:00:00Z',
                ),
              ),
        );
      }
    };
    expect(await phone.release(), 0);
    expect(queued, isTrue);
    expect(stateRequests(), 2, reason: 'both confirmed by the server');
    expect(phone.has(first.sha), isTrue);
    expect(phone.has(second.sha), isTrue);
    expect(phone.present, containsAll(<String>[first.sha, second.sha]));
  });

  test('a run without files releases nothing (D-513, PR 121 S2)', () async {
    final old = picture(fileBytes(3000, 18));
    phone.keep(server.files[old.sha]!);
    phone.now = after31Days;
    var releases = 0;
    final metered = SyncEngine(
      db: phone.db,
      api: SyncApi(phone.api),
      workspaceId: ws,
      tooOld: () => false,
      clock: () => phone.now,
      files: false,
      releaseMedia: () async {
        releases++;
        await phone.release();
      },
    );
    expect((await metered.run()).stop, SyncStop.done);
    expect(releases, 0);
    expect(stateRequests(), 0);
    expect(phone.has(old.sha), isTrue);
  });

  group('any answer but "complete, same size" keeps the file (T4, D-512)', () {
    late ({String id, String sha}) old;

    setUp(() async {
      old = picture(fileBytes(3000, 11));
      phone.keep(server.files[old.sha]!);
      await phone.engine.run();
      phone.now = after31Days;
      // The file is a candidate: only the server's answer keeps it.
      expect(
        (await releasableMediaHashes(phone.db, phone.now)).map((c) => c.sha256),
        <String>[old.sha],
      );
    });

    test('incomplete', () async {
      final bytes = server.files.remove(old.sha)!;
      server.partFiles[old.sha] = (
        total: bytes.length,
        bytes: BytesBuilder()..add(bytes.sublist(0, 100)),
      );
      expect(await phone.release(), 0);
      expect(phone.has(old.sha), isTrue);
      expect(stateRequests(), 1);
    });

    test('wrong size', () async {
      final other = picture(fileBytes(3000, 12), rowBytes: 2999);
      phone.keep(server.files[other.sha]!);
      server.files.remove(old.sha);
      await phone.engine.run();
      expect(await phone.release(), 0);
      expect(phone.has(other.sha), isTrue);
    });

    for (final status in <int>[403, 500, 503]) {
      test('$status', () async {
        if (status == 403) {
          server.helpers.add('b');
        } else {
          server.fileStatus = status;
        }
        expect(await phone.release(), 0);
        expect(phone.has(old.sha), isTrue);
      });
    }

    test('timeout', () async {
      final silent = buildApiServer(
        fakeApiBase,
        MockClient((_) => Completer<http.Response>().future),
        exampleSession,
        ApiHooks(tooOld: () => null, reportTooOld: (_) {}),
      );
      expect(
        await phone.release(
          files: FilesApi(silent),
          timeout: const Duration(milliseconds: 20),
        ),
        0,
      );
      expect(phone.has(old.sha), isTrue);
    });

    test('lost request', () async {
      server.loseRequests = 1;
      expect(await phone.release(), 0);
      expect(phone.has(old.sha), isTrue);
    });
  });

  test('an offline or unfinished run asks nothing and keeps the file; a stop '
      'during the release deletes nothing (T5, D-513)', () async {
    final old = picture(fileBytes(3000, 13));
    phone.keep(server.files[old.sha]!);
    phone.now = after31Days;

    server.loseRequests = 1;
    expect((await phone.engine.run()).stop, SyncStop.offline);
    phone.stopped = true;
    expect((await phone.engine.run()).stop, SyncStop.interrupted);
    expect(phone.releaseRuns, 0);
    expect(stateRequests(), 0);
    expect(phone.has(old.sha), isTrue);

    phone.stopped = false;
    server.afterRequest = (key) {
      if (key.endsWith('/state')) phone.stopped = true;
    };
    phone.stopped = false;
    await phone.engine.pull();
    expect(await phone.release(), 0);
    expect(stateRequests(), 1);
    expect(phone.has(old.sha), isTrue);
  });

  test('an unfinished 410 resync asks nothing (T6, D-459, D-511)', () async {
    final old = picture(fileBytes(3000, 14));
    phone.keep(server.files[old.sha]!);
    await phone.engine.run();
    await phone.db
        .into(phone.db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            workspaceId: ws,
            lastRevision: storedRevision(3, unfinished: true),
          ),
        );
    phone.now = after31Days;
    expect(await releasableMediaHashes(phone.db, phone.now), isEmpty);
    expect(await phone.release(), 0);
    expect(stateRequests(), 0);
    expect(phone.has(old.sha), isTrue);
  });

  test(
    'at most 20 files per run, oldest tombstone first (T7, D-513)',
    () async {
      final shas = <String>[];
      for (var i = 0; i < 25; i++) {
        // Newest first, so the order is not the insert order.
        final day = (25 - i).toString().padLeft(2, '0');
        final p = picture(
          fileBytes(500 + i, 20 + i),
          deletedAt: '2026-10-${day}T08:00:00Z',
        );
        phone.keep(server.files[p.sha]!);
        shas.add(p.sha);
      }
      phone.now = DateTime.utc(2026, 10, 26);
      await phone.engine.run();
      expect(stateRequests(), 0, reason: 'none 30 days old yet');
      phone.now = after31Days;
      final oldestFirst = shas.reversed.toList();
      expect(
        (await releasableMediaHashes(phone.db, phone.now)).map((c) => c.sha256),
        oldestFirst,
      );
      expect(await phone.release(), 20);
      expect(stateRequests(), 20);
      for (final sha in oldestFirst.take(20)) {
        expect(phone.has(sha), isFalse);
      }
      for (final sha in oldestFirst.skip(20)) {
        expect(phone.has(sha), isTrue);
      }
      expect(await phone.release(), 5);
      expect(stateRequests(), 25, reason: 'files already gone are not asked');
    },
  );

  test('a restore fetches the file again; the start-up sweep still keeps '
      'files of deleted rows (T8, D-515, D-417)', () async {
    final bytes = fileBytes(5000, 50);
    final old = picture(bytes);
    final kept = picture(fileBytes(4000, 51));
    phone
      ..keep(bytes)
      ..keep(server.files[kept.sha]!);
    await phone.engine.run();

    // The start-up sweep never deletes a file a deleted row names.
    await sweepMedia(phone.db, phone.media, clock: () => after31Days);
    expect(phone.has(old.sha), isTrue);
    expect(phone.has(kept.sha), isTrue);

    phone.now = after31Days;
    await phone.engine.run();
    expect(phone.has(old.sha), isFalse);
    expect(server.downloads, isEmpty);

    // Restored on another device: the next run fetches it, hash checked.
    final record = server.records['pictures']![old.id]!;
    record
      ..['deleted_at'] = null
      ..['revision'] = ++server.counter;
    await phone.engine.run();
    expect(phone.file(old.sha).readAsBytesSync(), bytes);
    expect(sha256Of(phone.file(old.sha).readAsBytesSync()), old.sha);
    expect(phone.present, contains(old.sha));
    expect(server.downloads, isNotEmpty);
  });

  group('the release reads other tables only for files on the device '
      '(#122, D-525..D-528)', () {
    int otherTableReads() => phone.selects.where(readsOtherTables).length;

    test('once a file is gone, the next release reads no other table and '
        'asks nothing (T2, D-525)', () async {
      final old = picture(fileBytes(3000, 60));
      final live = picture(fileBytes(3100, 61), deletedAt: null);
      phone
        ..keep(server.files[old.sha]!)
        ..keep(server.files[live.sha]!);
      await phone.engine.run();
      phone.now = after31Days;
      expect(await phone.release(), 1);
      expect(phone.has(old.sha), isFalse);
      final asked = stateRequests();

      phone.selects.clear();
      expect(await phone.release(), 0);
      expect(stateRequests(), asked);
      expect(otherTableReads(), 0, reason: phone.selects.join('\n'));
      expect(phone.has(live.sha), isTrue);
    });

    test('an old deleted file that is not on the device reads no other '
        'table and asks nothing (T3, D-525)', () async {
      picture(fileBytes(3000, 62));
      final live = picture(fileBytes(3100, 63), deletedAt: null);
      phone.keep(server.files[live.sha]!);
      await phone.engine.run();
      phone.now = after31Days;
      phone.selects.clear();
      expect(await phone.release(), 0);
      expect(stateRequests(), 0);
      expect(otherTableReads(), 0, reason: phone.selects.join('\n'));
    });

    test('a hash anywhere in another server copy keeps the file, also '
        'inside a longer hex run (T4, D-526)', () async {
      final midText = picture(fileBytes(3000, 64));
      final inRun = picture(fileBytes(3001, 65));
      final free = picture(fileBytes(3002, 66));
      for (final p in <({String id, String sha})>[midText, inRun, free]) {
        phone.keep(server.files[p.sha]!);
      }
      server
        ..put('customers', nextId(), <String, Object?>{
          'name': 'Siehe Bild ${midText.sha} im Flur',
        })
        ..put('customers', nextId(), <String, Object?>{
          'name': 'ab${inRun.sha}cd',
        });
      await phone.engine.run();
      phone.now = after31Days;
      expect(
        (await releasableMediaHashes(phone.db, phone.now)).map((c) => c.sha256),
        <String>[free.sha],
      );
      expect(await phone.release(), 1);
      expect(stateRequests(), 1);
      expect(phone.has(midText.sha), isTrue);
      expect(phone.has(inRun.sha), isTrue);
      expect(phone.has(free.sha), isFalse);
    });

    test('with 25 files on the device, at most 20 are looked up in the other '
        'tables (T5, D-526)', () async {
      final shas = <String>{};
      for (var i = 0; i < 25; i++) {
        final p = picture(fileBytes(600 + i, 70 + i));
        phone.keep(server.files[p.sha]!);
        shas.add(p.sha);
      }
      await phone.engine.run();
      phone.now = after31Days;
      phone.selects.clear();
      final found = await releasableMediaHashes(
        phone.db,
        phone.now,
        among: shas,
        limit: mediaReleasePerRun,
      );
      expect(found, hasLength(20));
      expect(otherTableReads(), 20);
    });

    test('the read before deleting looks up only the confirmed files '
        '(T6, D-527)', () async {
      final confirmed = picture(fileBytes(3000, 80));
      final partial = picture(fileBytes(3001, 81));
      phone
        ..keep(server.files[confirmed.sha]!)
        ..keep(server.files[partial.sha]!);
      await phone.engine.run();
      final bytes = server.files.remove(partial.sha)!;
      server.partFiles[partial.sha] = (
        total: bytes.length,
        bytes: BytesBuilder()..add(bytes.sublist(0, 100)),
      );
      phone.now = after31Days;
      phone.selects.clear();
      expect(await phone.release(), 1);
      expect(stateRequests(), 2);
      expect(otherTableReads(), 3, reason: '2 candidates, then 1 confirmed');
      expect(phone.has(confirmed.sha), isFalse);
      expect(phone.has(partial.sha), isTrue);
    });
  });
}
