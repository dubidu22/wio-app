// Keeping a voice note (plan 060 tests T1, T2, T7, T8; D-285, D-290,
// D-292; approval conditions: the stored M4A carries no metadata, and the
// transcript and the audio are written in one transaction).
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/camera/capture_files.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/data/media_writer.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/sync/upload_queue.dart';
import 'package:wio_app/voice/voice_notes.dart';

import '../support/m4a.dart';
import '../support/test_data.dart';

/// A writer whose record write fails after the upload row was written.
class _FailingWriter extends LocalWriter {
  _FailingWriter(super.db);

  @override
  Future<String> write({
    required String entity,
    required String id,
    required Map<String, Object?> fields,
  }) => throw StateError('disk full');
}

void main() {
  late Directory folder;
  late WioDatabase db;
  late CaptureFiles files;
  final now = DateTime.utc(2026, 11, 19, 9, 30);

  VoiceNotes notesWith(LocalWriter writer) => VoiceNotes(
    db,
    MediaWriter(
      db,
      writer,
      MediaStore(() async => '${folder.path}/support'),
      UploadStore(() async => '${folder.path}/support'),
      clock: () => now,
    ),
    files,
  );

  setUp(() async {
    folder = Directory.systemTemp.createTempSync('voice_notes_test');
    db = memoryDatabase();
    await seedWithPictures(db);
    files = CaptureFiles(() async => '${folder.path}/temp');
  });
  tearDown(() async {
    await db.close();
    folder.deleteSync(recursive: true);
  });

  Future<String> recording() async {
    final path = await files.newRecordingPath();
    File(path).writeAsBytesSync(sampleM4a());
    return path;
  }

  Map<String, Object?> fieldsOf(OutboxData row) =>
      jsonDecode(row.fields) as Map<String, Object?>;

  const VoiceTarget kueche = (
    customerId: TestIds.familieBeispiel,
    roomId: TestIds.kueche,
    pictureId: null,
  );

  test('one change holds the audio and the device transcript', () async {
    final path = await recording();
    final id = await notesWith(LocalWriter(db, clock: () => now)).keep(
      target: kueche,
      path: path,
      length: const Duration(milliseconds: 7400),
      transcript: 'Kiste mit Wintersachen',
    );

    final note = await (db.select(
      db.notes,
    )..where((n) => n.id.equals(id!))).getSingle();
    expect(note.subjectType, 'room');
    expect(note.subjectId, TestIds.kueche);
    expect(note.customerId, TestIds.familieBeispiel);
    expect(note.transcript, 'Kiste mit Wintersachen');
    expect(note.transcriptSource, 'device');
    expect(note.audioSeconds, 7);

    final changes = await (db.select(
      db.outbox,
    )..where((o) => o.entity.equals('notes'))).get();
    expect(changes, hasLength(1));
    final fields = fieldsOf(changes.single);
    expect(fields['audio_sha256'], note.audioSha256);
    expect(fields['transcript'], 'Kiste mit Wintersachen');
    expect(fields['transcript_source'], 'device');

    final upload = await (db.select(
      db.uploads,
    )..where((u) => u.sha256.equals(note.audioSha256!))).getSingle();
    expect(upload.size, note.audioBytes);
    expect(File(path).existsSync(), isFalse, reason: 'working file deleted');
  });

  test('the stored file has no metadata beyond the container', () async {
    final path = await recording();
    final id = await notesWith(LocalWriter(db, clock: () => now)).keep(
      target: kueche,
      path: path,
      length: const Duration(seconds: 3),
      transcript: '',
    );
    final note = await (db.select(
      db.notes,
    )..where((n) => n.id.equals(id!))).getSingle();
    final upload = await (db.select(
      db.uploads,
    )..where((u) => u.sha256.equals(note.audioSha256!))).getSingle();
    final stored = File(upload.path).readAsBytesSync();

    expect(sha256.convert(stored).toString(), note.audioSha256);
    expect(stored.length, sampleM4a().length);
    for (final word in <String>['udta', 'meta', 'com.android', '+52.52']) {
      expect(containsBytes(stored, ascii.encode(word)), isFalse, reason: word);
    }
    expect(containsBytes(stored, sampleAudio), isTrue);
  });

  test('no transcript leaves both transcript fields empty (D-61)', () async {
    final id = await notesWith(LocalWriter(db, clock: () => now)).keep(
      target: kueche,
      path: await recording(),
      length: const Duration(seconds: 4),
      transcript: '  ',
    );
    final note = await (db.select(
      db.notes,
    )..where((n) => n.id.equals(id!))).getSingle();
    expect(note.transcript, isNull);
    expect(note.transcriptSource, isNull);
    expect(note.audioSha256, isNotNull);
  });

  test('a failed write leaves no note and no upload', () async {
    final path = await recording();
    await expectLater(
      notesWith(_FailingWriter(db)).keep(
        target: kueche,
        path: path,
        length: const Duration(seconds: 4),
        transcript: 'Text',
      ),
      throwsStateError,
    );
    expect(await db.select(db.notes).get(), isEmpty);
    expect(await db.select(db.uploads).get(), isEmpty);
    expect(File(path).existsSync(), isFalse);
  });

  test('a recording under half a second is not kept (D-292)', () async {
    final path = await recording();
    final id = await notesWith(LocalWriter(db, clock: () => now)).keep(
      target: kueche,
      path: path,
      length: const Duration(milliseconds: 400),
      transcript: 'Hm',
    );
    expect(id, isNull);
    expect(await db.select(db.notes).get(), isEmpty);
    expect(File(path).existsSync(), isFalse);
  });

  test('subjects: picture, else room, else customer (D-295)', () async {
    final writer = notesWith(LocalWriter(db, clock: () => now));
    for (final (target, type, subject) in <(VoiceTarget, String, String)>[
      (
        (
          customerId: TestIds.familieBeispiel,
          roomId: TestIds.kueche,
          pictureId: TestIds.fotoVorher,
        ),
        'picture',
        TestIds.fotoVorher,
      ),
      (
        (customerId: TestIds.familieBeispiel, roomId: null, pictureId: null),
        'customer',
        TestIds.familieBeispiel,
      ),
    ]) {
      final id = await writer.keep(
        target: target,
        path: await recording(),
        length: const Duration(seconds: 2),
        transcript: 'Notiz',
      );
      final note = await (db.select(
        db.notes,
      )..where((n) => n.id.equals(id!))).getSingle();
      expect(note.subjectType, type);
      expect(note.subjectId, subject);
      expect(note.customerId, TestIds.familieBeispiel);
    }
  });
}
