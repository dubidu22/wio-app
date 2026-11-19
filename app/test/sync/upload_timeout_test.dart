// The chunk timeout (D-213) in fake time: a slow answer within 120 s
// completes, a slower one ends the run offline (PR 51 review S2). The
// copy lives in memory, because real file reads do not run in fake time.
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_api/wio_api.dart' show FilesApi;
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/sync/sync_engine.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/test_data.dart';

/// Copies in memory by path.
class MemoryUploadStore implements UploadStore {
  final Map<String, Uint8List> files = <String, Uint8List>{};

  @override
  Future<({String sha256, int size})> hash(String path) async =>
      (sha256: sha256Of(files[path]!), size: files[path]!.length);

  @override
  Future<int> size(String path) async => files[path]!.length;

  @override
  Future<({String sha256, int size, String path})> keep(String source) =>
      throw UnimplementedError();

  @override
  Future<Uint8List> read(String path, int start, int length) async =>
      Uint8List.sublistView(files[path]!, start, start + length);

  @override
  Future<bool> exists(String path) async => files.containsKey(path);

  @override
  Future<void> remove(String path) async => files.remove(path);

  @override
  Future<void> sweep(Set<String> keep, {required DateTime before}) async {}
}

void main() {
  for (final (delay, completes) in <(Duration, bool)>[
    (const Duration(seconds: 60), true),
    (const Duration(seconds: 119), true),
    (const Duration(seconds: 121), false),
  ]) {
    testWidgets('a chunk answered after ${delay.inSeconds} s '
        '${completes ? 'completes' : 'ends the run offline'} (D-213)', (
      tester,
    ) async {
      final server = FakeSyncServer()..chunkDelay = delay;
      final db = memoryDatabase();
      addTearDown(db.close);
      final bytes = Uint8List.fromList(List<int>.generate(1000, (i) => i));
      final sha = sha256Of(bytes);
      final store = MemoryUploadStore()..files['copy'] = bytes;
      await seedUploads(db, <(String, int, String?)>[(sha, 1000, null)]);
      await db
          .update(db.uploads)
          .write(const UploadsCompanion(path: Value<String>('copy')));
      final worker = UploadWorker(
        db: db,
        api: FilesApi(
          buildApiServer(
            fakeApiBase,
            server.clientFor('a'),
            exampleSession,
            ApiHooks(tooOld: () => null, reportTooOld: (_) {}),
          ),
        ),
        store: store,
        tooOld: () => false,
      );
      SyncResult? result;
      final run = worker.run().then((r) => result = r);
      for (var s = 0; s < 130 && result == null; s++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await run;
      // Let a late answer arrive, as it would after the timeout.
      await tester.pump(const Duration(seconds: 10));
      final rows = await db.select(db.uploads).get();
      if (completes) {
        expect(result!.stop, SyncStop.done);
        expect(rows, isEmpty);
        expect(server.files[sha], bytes);
      } else {
        expect(result!.stop, SyncStop.offline);
        expect(rows.single.failedReason, isNull);
        expect(store.files, contains('copy'));
      }
    });
  }

  test('the chunk timeout is 120 s and longer than the 30 s of sync', () {
    expect(uploadChunkTimeout, const Duration(seconds: 120));
    expect(uploadChunkTimeout, greaterThan(syncRequestTimeout));
  });
}
