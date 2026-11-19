import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:wio_app/data/database.dart';

import 'media.dart';

/// A fresh in-memory database for one test.
WioDatabase memoryDatabase() => WioDatabase(NativeDatabase.memory());

/// The fixed "now" of widget and golden tests: Thursday 19 Nov 2026, 10:00.
final DateTime testNow = DateTime(2026, 11, 19, 10);

/// Invented test data (no real people or addresses, INV-07).
abstract final class TestIds {
  static const String workspace = '01970000-0000-7000-8000-000000000001';
  static const String familieBeispiel = '01970000-0000-7000-8000-0000000000c1';
  static const String frauMuster = '01970000-0000-7000-8000-0000000000c2';
  static const String herrProbe = '01970000-0000-7000-8000-0000000000c3';
  static const String geloescht = '01970000-0000-7000-8000-0000000000c4';
  static const String alteWohnung = '01970000-0000-7000-8000-0000000000a1';
  static const String neueWohnung = '01970000-0000-7000-8000-0000000000a2';
  static const String fremderOrt = '01970000-0000-7000-8000-0000000000a3';
  static const String kueche = '01970000-0000-7000-8000-0000000000b1';
  static const String keller = '01970000-0000-7000-8000-0000000000b2';
  static const String alterRaum = '01970000-0000-7000-8000-0000000000b3';
  static const String fotoVorher = '01970000-0000-7000-8000-0000000000f1';
  static const String fotoRegal = '01970000-0000-7000-8000-0000000000f2';
  static const String fotoNachher = '01970000-0000-7000-8000-0000000000f3';
  static const String fotoFehlt = '01970000-0000-7000-8000-0000000000f4';
  static const String fotoFlur = '01970000-0000-7000-8000-0000000000f5';
  static const String fotoGeloescht = '01970000-0000-7000-8000-0000000000f6';
  static const String notizSprache = '01970000-0000-7000-8000-0000000000d1';
  static const String notizText = '01970000-0000-7000-8000-0000000000d2';
  static const String notizFehlt = '01970000-0000-7000-8000-0000000000d3';
  static const String notizGeloescht = '01970000-0000-7000-8000-0000000000d4';
  static const String notizKunde = '01970000-0000-7000-8000-0000000000d5';
  static const String notizFoto = '01970000-0000-7000-8000-0000000000d6';
}

PicturesCompanion _picture(
  String id,
  String sha256,
  String takenAt, {
  String? roomId,
  String? afterOf,
  String? deletedAt,
}) => PicturesCompanion.insert(
  id: id,
  workspaceId: TestIds.workspace,
  customerId: const Value<String?>(TestIds.familieBeispiel),
  fileSha256: sha256,
  fileBytes: 12000,
  fileMime: 'image/jpeg',
  widthPx: 640,
  heightPx: 480,
  takenAt: Value<String?>(takenAt),
  roomId: Value<String?>(roomId),
  afterOf: Value<String?>(afterOf),
  revision: const Value<int?>(1),
  deletedAt: Value<String?>(deletedAt),
);

CustomersCompanion _customer(String id, String name, {String? deletedAt}) =>
    CustomersCompanion.insert(
      id: id,
      workspaceId: TestIds.workspace,
      name: Value<String?>(name),
      revision: const Value<int?>(1),
      deletedAt: Value<String?>(deletedAt),
    );

JobsCompanion _job(
  String id,
  String customerId,
  String date, {
  String? deletedAt,
}) => JobsCompanion.insert(
  id: id,
  workspaceId: TestIds.workspace,
  customerId: customerId,
  date: date,
  revision: const Value<int?>(1),
  deletedAt: Value<String?>(deletedAt),
);

/// Seeds data as if it had been pulled from the server: three live
/// customers, one tombstoned; jobs today, later and in the past; two sites
/// of Familie Beispiel, one with rooms.
Future<void> seedTestData(WioDatabase db) async {
  await db.batch((b) {
    b.insertAll(db.customers, <CustomersCompanion>[
      _customer(TestIds.familieBeispiel, 'Familie Beispiel'),
      _customer(TestIds.frauMuster, 'Frau Muster'),
      _customer(TestIds.herrProbe, 'Herr Probe'),
      _customer(
        TestIds.geloescht,
        'Gelöschte Kundin',
        deletedAt: '2026-11-10T08:00:00.000Z',
      ),
    ]);
    b.insertAll(db.jobs, <JobsCompanion>[
      _job(
        '01970000-0000-7000-8000-0000000000d1',
        TestIds.familieBeispiel,
        '2026-11-19',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d2',
        TestIds.frauMuster,
        '2026-11-20',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d3',
        TestIds.herrProbe,
        '2026-11-23',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d4',
        TestIds.herrProbe,
        '2026-11-18',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d5',
        TestIds.frauMuster,
        '2026-11-19',
        deletedAt: '2026-11-12T08:00:00.000Z',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d6',
        TestIds.geloescht,
        '2026-11-19',
      ),
    ]);
    b.insertAll(db.sites, <SitesCompanion>[
      SitesCompanion.insert(
        id: TestIds.alteWohnung,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        name: const Value<String?>('Alte Wohnung'),
        revision: const Value<int?>(1),
      ),
      SitesCompanion.insert(
        id: TestIds.neueWohnung,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        name: const Value<String?>('Neue Wohnung'),
        revision: const Value<int?>(1),
      ),
      SitesCompanion.insert(
        id: TestIds.fremderOrt,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.frauMuster),
        name: const Value<String?>('Wohnung Muster'),
        revision: const Value<int?>(1),
      ),
    ]);
    b.insertAll(db.rooms, <RoomsCompanion>[
      RoomsCompanion.insert(
        id: TestIds.kueche,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        siteId: TestIds.alteWohnung,
        name: const Value<String?>('Küche'),
        revision: const Value<int?>(1),
      ),
      RoomsCompanion.insert(
        id: TestIds.keller,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        siteId: TestIds.alteWohnung,
        name: const Value<String?>('Keller'),
        revision: const Value<int?>(1),
      ),
      RoomsCompanion.insert(
        id: TestIds.alterRaum,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        siteId: TestIds.alteWohnung,
        name: const Value<String?>('Abstellraum'),
        revision: const Value<int?>(1),
        deletedAt: const Value<String?>('2026-11-11T08:00:00.000Z'),
      ),
    ]);
  });
}

/// [seedTestData] plus pictures (D-263): the Küche has three pictures with
/// files in the demo media folder (one an after picture), one whose file is
/// on no device and one tombstoned; the Keller has none; one picture of
/// Familie Beispiel belongs to no room.
Future<void> seedWithPictures(WioDatabase db) async {
  await seedTestData(db);
  await db.batch((b) {
    b.insertAll(db.pictures, <PicturesCompanion>[
      _picture(
        TestIds.fotoVorher,
        DemoFiles.kuecheVorher,
        '2026-11-19T08:05:00.000Z',
        roomId: TestIds.kueche,
      ),
      _picture(
        TestIds.fotoRegal,
        DemoFiles.kuecheRegal,
        '2026-11-19T08:07:00.000Z',
        roomId: TestIds.kueche,
      ),
      _picture(
        TestIds.fotoNachher,
        DemoFiles.kuecheNachher,
        '2026-11-19T09:40:00.000Z',
        roomId: TestIds.kueche,
        afterOf: TestIds.fotoVorher,
      ),
      _picture(
        TestIds.fotoFehlt,
        DemoFiles.missing,
        '2026-11-19T09:45:00.000Z',
        roomId: TestIds.kueche,
      ),
      _picture(
        TestIds.fotoGeloescht,
        DemoFiles.kuecheRegal,
        '2026-11-19T08:06:00.000Z',
        roomId: TestIds.kueche,
        deletedAt: '2026-11-19T08:30:00.000Z',
      ),
      _picture(
        TestIds.fotoFlur,
        DemoFiles.flurKartons,
        '2026-11-19T08:20:00.000Z',
      ),
    ]);
  });
}

NotesCompanion _note(
  String id,
  String subjectType,
  String subjectId, {
  String? text,
  String? audioSha256,
  int? audioSeconds,
  String? transcript,
  String? createdAt,
  String? deletedAt,
}) => NotesCompanion.insert(
  id: id,
  workspaceId: TestIds.workspace,
  customerId: const Value<String?>(TestIds.familieBeispiel),
  subjectType: subjectType,
  subjectId: subjectId,
  noteText: Value<String?>(text),
  audioSha256: Value<String?>(audioSha256),
  audioBytes: Value<int?>(audioSha256 == null ? null : 24000),
  audioSeconds: Value<int?>(audioSeconds),
  transcript: Value<String?>(transcript),
  transcriptSource: Value<String?>(transcript == null ? null : 'device'),
  createdAt: Value<String?>(createdAt),
  revision: Value<int?>(createdAt == null ? null : 1),
  deletedAt: Value<String?>(deletedAt),
);

/// [seedWithPictures] plus notes (plan 061): the Küche has a voice note
/// whose recording is in the demo media folder, a text note not yet sent,
/// a voice note whose recording is on no device and a tombstoned note;
/// Familie Beispiel has a text note, the shelf picture a voice note.
Future<void> seedWithNotes(WioDatabase db) async {
  await seedWithPictures(db);
  await db.batch((b) {
    b.insertAll(db.notes, <NotesCompanion>[
      _note(
        TestIds.notizSprache,
        'room',
        TestIds.kueche,
        audioSha256: DemoFiles.noteAudio,
        audioSeconds: 45,
        transcript:
            'Kiste mit Wintersachen im Keller, oberstes Regal links. '
            'Die Gläser im Hängeschrank bleiben, der Rest kommt in den '
            'Umzugskarton mit der Aufschrift Küche zwei.',
        createdAt: '2026-11-19T08:41:00.000Z',
      ),
      _note(
        TestIds.notizFehlt,
        'room',
        TestIds.kueche,
        audioSha256: DemoFiles.missing,
        audioSeconds: 12,
        transcript: 'Herd bleibt in der Wohnung.',
        createdAt: '2026-11-19T08:50:00.000Z',
      ),
      _note(
        TestIds.notizGeloescht,
        'room',
        TestIds.kueche,
        text: 'Gelöschte Notiz',
        createdAt: '2026-11-19T08:45:00.000Z',
        deletedAt: '2026-11-19T08:46:00.000Z',
      ),
      _note(
        TestIds.notizText,
        'room',
        TestIds.kueche,
        text: 'Schlüssel liegt beim Nachbarn im Erdgeschoss.',
      ),
      _note(
        TestIds.notizKunde,
        'customer',
        TestIds.familieBeispiel,
        text: 'Bitte vorher anrufen, Klingel geht nicht.',
        createdAt: '2026-11-19T07:30:00.000Z',
      ),
      _note(
        TestIds.notizFoto,
        'picture',
        TestIds.fotoRegal,
        audioSha256: DemoFiles.noteAudio,
        audioSeconds: 8,
        transcript: 'Regal wird abgebaut.',
        createdAt: '2026-11-19T08:08:00.000Z',
      ),
    ]);
  });
}

/// Test data ([base]) plus two changes the server refused (D-197): a renamed
/// customer (permission) and a new customer whose number existed already
/// (duplicate, re-pointed).
Future<void> seedWithRejected(
  WioDatabase db, {
  Future<void> Function(WioDatabase db) base = seedTestData,
}) async {
  await base(db);
  await db.batch((b) {
    b.insertAll(db.rejectedChanges, <RejectedChangesCompanion>[
      RejectedChangesCompanion.insert(
        changeId: '01970000-0000-7000-8000-0000000000e1',
        entity: 'customers',
        entityId: TestIds.frauMuster,
        op: 'upsert',
        fields: '{"name":"Frau Muster-Probe","contact":"{}"}',
        deviceTime: '2026-11-19T08:00:00.000Z',
        reason: 'permission',
        rejectedAt: '2026-11-19T08:05:00.000Z',
      ),
      RejectedChangesCompanion.insert(
        changeId: '01970000-0000-7000-8000-0000000000e2',
        entity: 'customers',
        entityId: '01970000-0000-7000-8000-0000000000c9',
        op: 'upsert',
        fields:
            '{"workspace_id":"${TestIds.workspace}","name":"Familie B.",'
            '"external_ref":"K-17"}',
        deviceTime: '2026-11-19T08:01:00.000Z',
        reason: 'duplicate',
        existingId: const Value<String?>(TestIds.familieBeispiel),
        rejectedAt: '2026-11-19T08:04:00.000Z',
      ),
    ]);
  });
}

/// [seedWithRejected] over [seedWithNotes] plus three uploads that failed
/// (D-214, D-386): the Küche shelf picture (permission; its file is in the
/// demo media folder, so it has a thumbnail), the voice note recording on
/// that picture (damaged) and a file no row points at (too large).
Future<void> seedWithRejectedAndUploads(WioDatabase db) async {
  await seedWithRejected(db, base: seedWithNotes);
  await seedUploads(db, <(String, int, String?)>[
    ('b' * 64, 12900000, 'too_large'),
    (DemoFiles.noteAudio, 1300000, 'damaged'),
    // Newest, so listed first and inside the phone golden.
    (DemoFiles.kuecheRegal, 2500000, 'permission'),
  ]);
}

/// Upload rows as (sha256, size, failed reason); the copies do not exist.
Future<void> seedUploads(
  WioDatabase db,
  List<(String, int, String?)> uploads,
) => db.batch((b) {
  b.insertAll(db.uploads, <UploadsCompanion>[
    for (final (i, (sha256, size, reason)) in uploads.indexed)
      UploadsCompanion.insert(
        sha256: sha256,
        path: '/nowhere/uploads/$sha256',
        size: size,
        createdAt: '2026-11-19T08:1$i:00.000Z',
        failedReason: Value<String?>(reason),
      ),
  ]);
});
