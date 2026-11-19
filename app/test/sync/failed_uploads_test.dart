// What a failed file belongs to, for "Nicht gesendet" (plan 053 T1,
// D-384, D-385).
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/media.dart';
import '../support/test_data.dart';

const String _workspace = TestIds.workspace;
const String _job = '01970000-0000-7000-8000-0000000000d1';

Upload _upload(String sha256) => Upload(
  sha256: sha256,
  path: '/nowhere/uploads/$sha256',
  size: 2500000,
  createdAt: '2026-11-19T08:10:00.000Z',
  failedReason: 'permission',
);

Future<void> _picture(
  WioDatabase db,
  String id,
  String sha256, {
  String? customerId = TestIds.familieBeispiel,
  String? roomId,
  String? afterOf,
  String? deletedAt,
}) => db
    .into(db.pictures)
    .insert(
      PicturesCompanion.insert(
        id: id,
        workspaceId: _workspace,
        customerId: Value<String?>(customerId),
        fileSha256: sha256,
        fileBytes: 2500000,
        fileMime: 'image/jpeg',
        widthPx: 640,
        heightPx: 480,
        roomId: Value<String?>(roomId),
        afterOf: Value<String?>(afterOf),
        deletedAt: Value<String?>(deletedAt),
      ),
    );

Future<void> _voice(
  WioDatabase db,
  String id,
  String sha256,
  String subjectType,
  String subjectId, {
  String? customerId = TestIds.familieBeispiel,
}) => db
    .into(db.notes)
    .insert(
      NotesCompanion.insert(
        id: id,
        workspaceId: _workspace,
        customerId: Value<String?>(customerId),
        subjectType: subjectType,
        subjectId: subjectId,
        audioSha256: Value<String?>(sha256),
        audioBytes: const Value<int?>(24000),
        audioSeconds: const Value<int?>(5),
      ),
    );

String _id(int n) =>
    '01980000-0000-7000-8000-${n.toRadixString(16).padLeft(12, '0')}';

String _sha(int n) => n.toRadixString(16).padLeft(64, 'e');

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithNotes(db);
  });
  tearDown(() => db.close());

  Future<FailedUpload> describe(String sha256) =>
      describeUpload(db, _upload(sha256));

  test('a room picture names its customer and room', () async {
    final failed = await describe(DemoFiles.kuecheVorher);
    expect(failed.kind, UploadKind.picture);
    expect(failed.place, 'Familie Beispiel, Küche');
  });

  test('an after picture names its room like its before picture', () async {
    final failed = await describe(DemoFiles.kuecheNachher);
    expect(failed.kind, UploadKind.picture);
    expect(failed.place, 'Familie Beispiel, Küche');
  });

  test('a customer picture without a room names only the customer', () async {
    final failed = await describe(DemoFiles.flurKartons);
    expect(failed.kind, UploadKind.picture);
    expect(failed.place, 'Familie Beispiel');
  });

  test('a voice note about a room names that room', () async {
    await _voice(db, _id(1), _sha(1), 'room', TestIds.keller);
    final failed = await describe(_sha(1));
    expect(failed.kind, UploadKind.voice);
    expect(failed.place, 'Familie Beispiel, Keller');
  });

  test('a voice note about a picture names the room of the picture', () async {
    await _voice(db, _id(2), _sha(2), 'picture', TestIds.fotoRegal);
    final failed = await describe(_sha(2));
    expect(failed.kind, UploadKind.voice);
    expect(failed.place, 'Familie Beispiel, Küche');
  });

  test('a voice note about a customer or a job names the customer', () async {
    await _voice(db, _id(3), _sha(3), 'customer', TestIds.familieBeispiel);
    await _voice(db, _id(4), _sha(4), 'job', _job);
    for (final sha in <String>[_sha(3), _sha(4)]) {
      final failed = await describe(sha);
      expect(failed.kind, UploadKind.voice);
      expect(failed.place, 'Familie Beispiel');
    }
  });

  test('without a customer only the room is named', () async {
    await _picture(
      db,
      _id(5),
      _sha(5),
      customerId: null,
      roomId: TestIds.keller,
    );
    expect((await describe(_sha(5))).place, 'Keller');
  });

  test('neither customer nor room named gives no place', () async {
    await _picture(db, _id(6), _sha(6), customerId: null);
    final failed = await describe(_sha(6));
    expect(failed.kind, UploadKind.picture);
    expect(failed.place, isNull);
  });

  test('a deleted picture still names its file', () async {
    await _picture(
      db,
      _id(7),
      _sha(7),
      roomId: TestIds.keller,
      deletedAt: '2026-11-19T09:00:00.000Z',
    );
    expect((await describe(_sha(7))).place, 'Familie Beispiel, Keller');
  });

  test('a live row wins over a newer deleted one', () async {
    await _picture(db, _id(8), _sha(8), roomId: TestIds.kueche);
    await _picture(
      db,
      _id(9),
      _sha(8),
      roomId: TestIds.keller,
      deletedAt: '2026-11-19T09:00:00.000Z',
    );
    expect((await describe(_sha(8))).place, 'Familie Beispiel, Küche');
  });

  test('a file no row points at is unknown', () async {
    final failed = await describe('f' * 64);
    expect(failed.kind, UploadKind.unknown);
    expect(failed.place, isNull);
  });

  test('the list follows a renamed room', () async {
    await seedUploads(db, <(String, int, String?)>[
      (DemoFiles.kuecheVorher, 2500000, 'permission'),
    ]);
    final places = watchFailedUploads(db)
        .map((list) => list.single.place)
        .take(2)
        .toList();
    await pumpEventQueue();
    await (db.update(db.rooms)..where((r) => r.id.equals(TestIds.kueche)))
        .write(const RoomsCompanion(name: Value<String?>('Wohnküche')));
    expect(await places, <String?>[
      'Familie Beispiel, Küche',
      'Familie Beispiel, Wohnküche',
    ]);
  });
}
