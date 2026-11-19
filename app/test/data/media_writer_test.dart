// The media writer (plan 054 tests T3 to T9 and T14, D-238 to D-246).
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/data/media_writer.dart';
import 'package:wio_app/data/queries.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/test_data.dart';

const String jobId = '01970000-0000-7000-8000-0000000000d1';
const String entryId = '01970000-0000-7000-8000-0000000000e9';

/// A media store that keeps nothing, as on the web (D-246).
class NoMediaStore extends MediaStore {
  NoMediaStore() : super(() async => '');

  @override
  bool get supported => false;
}

void main() {
  late Directory folder;
  late WioDatabase db;
  late MediaStore media;
  late MediaWriter writer;
  late List<String> ids;
  final now = DateTime.utc(2026, 11, 19, 9, 30);

  MediaWriter writerFor(MediaStore store) {
    var next = 0;
    return MediaWriter(
      db,
      LocalWriter(db, clock: () => now),
      store,
      UploadStore(() async => folder.path),
      clock: () => now,
      ids: () {
        final id =
            '01970000-0000-7000-8000-${(0x100 + next++).toRadixString(16).padLeft(12, '0')}';
        ids.add(id);
        return id;
      },
    );
  }

  /// A file with [content] outside the media folder, as the camera leaves it.
  Future<String> source(String name, String content) async {
    final file = File('${folder.path}/source-$name');
    await file.writeAsString(content);
    return file.path;
  }

  Future<PreparedPicture> picture(String content) async => PreparedPicture(
    path: await source(content, content),
    mime: 'image/jpeg',
    widthPx: 2560,
    heightPx: 1920,
    takenAt: DateTime.utc(2026, 11, 19, 9, 29),
  );

  String hashOf(String content) =>
      sha256.convert(utf8.encode(content)).toString();

  Future<List<OutboxData>> outbox() => db.select(db.outbox).get();

  Map<String, Object?> fieldsOf(OutboxData row) =>
      jsonDecode(row.fields) as Map<String, Object?>;

  Future<Picture> pictureRow(String id) =>
      (db.select(db.pictures)..where((p) => p.id.equals(id))).getSingle();

  Future<Note> noteRow(String id) =>
      (db.select(db.notes)..where((n) => n.id.equals(id))).getSingle();

  Future<void> nothingWritten() async {
    expect(await db.select(db.pictures).get(), isEmpty);
    expect(await db.select(db.notes).get(), isEmpty);
    expect(await outbox(), isEmpty);
    expect(await db.select(db.uploads).get(), isEmpty);
  }

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('media_writer_test');
    db = memoryDatabase();
    await seedTestData(db);
    media = MediaStore(() async => folder.path);
    ids = <String>[];
    writer = writerFor(media);
  });
  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  group('addPicture (T3, T4, T6)', () {
    test('keeps the file, queues the upload and the record', () async {
      final id = await writer.addPicture(
        workspaceId: TestIds.workspace,
        file: await picture('jpeg bytes'),
        roomId: TestIds.keller,
      );
      final sha = hashOf('jpeg bytes');

      final row = await pictureRow(id);
      expect(row.fileSha256, sha);
      expect(row.fileBytes, 10);
      expect(row.fileMime, 'image/jpeg');
      expect(row.widthPx, 2560);
      expect(row.heightPx, 1920);
      expect(row.takenAt, '2026-11-19T09:29:00.000Z');
      expect(row.roomId, TestIds.keller);
      expect(row.customerId, TestIds.familieBeispiel, reason: 'from the room');
      expect(row.revision, isNull);

      final change = (await outbox()).single;
      expect(change.entity, 'pictures');
      expect(change.op, 'upsert');
      expect(change.baseRevision, isNull);
      expect(fieldsOf(change), <String, Object?>{
        'workspace_id': TestIds.workspace,
        'customer_id': TestIds.familieBeispiel,
        'file_sha256': sha,
        'file_bytes': 10,
        'file_mime': 'image/jpeg',
        'width_px': 2560,
        'height_px': 1920,
        'taken_at': '2026-11-19T09:29:00.000Z',
        'room_id': TestIds.keller,
      });

      final upload = (await db.select(db.uploads).get()).single;
      expect(upload.sha256, sha);
      expect(upload.failedReason, isNull);
      expect(upload.size, 10);

      expect(await media.has(sha), isTrue);
      expect(await File(await media.pathOf(sha)).readAsString(), 'jpeg bytes');
    });

    test('a room-less picture takes the given customer', () async {
      final id = await writer.addPicture(
        workspaceId: TestIds.workspace,
        file: await picture('a'),
        customerId: TestIds.frauMuster,
      );
      expect((await pictureRow(id)).customerId, TestIds.frauMuster);
      expect(
        fieldsOf((await outbox()).single)['customer_id'],
        TestIds.frauMuster,
      );
    });

    test('a picture without anything pushes no customer', () async {
      final id = await writer.addPicture(
        workspaceId: TestIds.workspace,
        file: await picture('a'),
      );
      expect((await pictureRow(id)).customerId, isNull);
      expect(
        fieldsOf((await outbox()).single).containsKey('customer_id'),
        isFalse,
      );
    });

    test('a room whose customer is not known yet pushes none', () async {
      await db.customStatement(
        "UPDATE rooms SET customer_id = NULL WHERE id = '${TestIds.keller}'",
      );
      await writer.addPicture(
        workspaceId: TestIds.workspace,
        file: await picture('a'),
        roomId: TestIds.keller,
      );
      expect(
        fieldsOf((await outbox()).single).containsKey('customer_id'),
        isFalse,
      );
    });

    test(
      'a picture of an entry takes the customer of its server copy',
      () async {
        await db
            .into(db.serverRecords)
            .insert(
              ServerRecordsCompanion.insert(
                entity: 'entries',
                id: entryId,
                revision: 3,
                fields: jsonEncode(<String, Object?>{
                  'id': entryId,
                  'workspace_id': TestIds.workspace,
                  'customer_id': TestIds.herrProbe,
                }),
              ),
            );
        final id = await writer.addPicture(
          workspaceId: TestIds.workspace,
          file: await picture('a'),
          entryId: entryId,
        );
        expect((await pictureRow(id)).customerId, TestIds.herrProbe);
      },
    );

    test('the same file twice is two pictures and one upload', () async {
      await writer.addPicture(
        workspaceId: TestIds.workspace,
        file: await picture('same'),
        roomId: TestIds.keller,
      );
      await writer.addPicture(
        workspaceId: TestIds.workspace,
        file: await picture('same'),
        roomId: TestIds.kueche,
      );
      expect(await db.select(db.pictures).get(), hasLength(2));
      expect(await db.select(db.uploads).get(), hasLength(1));
    });

    final refusals =
        <String, Future<String> Function(MediaWriter, PreparedPicture)>{
          'an unknown room': (w, f) => w.addPicture(
            workspaceId: TestIds.workspace,
            file: f,
            roomId: '01970000-0000-7000-8000-0000000000ff',
          ),
          'a deleted room': (w, f) => w.addPicture(
            workspaceId: TestIds.workspace,
            file: f,
            roomId: TestIds.alterRaum,
          ),
          'an unknown entry': (w, f) => w.addPicture(
            workspaceId: TestIds.workspace,
            file: f,
            entryId: entryId,
          ),
          'another customer than the room': (w, f) => w.addPicture(
            workspaceId: TestIds.workspace,
            file: f,
            roomId: TestIds.keller,
            customerId: TestIds.frauMuster,
          ),
          'a deleted customer': (w, f) => w.addPicture(
            workspaceId: TestIds.workspace,
            file: f,
            customerId: TestIds.geloescht,
          ),
        };
    for (final MapEntry(:key, :value) in refusals.entries) {
      test('$key is refused and nothing is written', () async {
        await expectLater(
          value(writer, await picture('a')),
          throwsArgumentError,
        );
        await nothingWritten();
      });
    }

    test('an empty file and a wrong mime are refused', () async {
      await expectLater(
        writer.addPicture(
          workspaceId: TestIds.workspace,
          file: PreparedPicture(
            path: await source('empty', ''),
            mime: 'image/jpeg',
            widthPx: 1,
            heightPx: 1,
          ),
        ),
        throwsArgumentError,
      );
      for (final mime in <String>['', 'x' * 101]) {
        await expectLater(
          writer.addPicture(
            workspaceId: TestIds.workspace,
            file: PreparedPicture(
              path: await source('m', 'a'),
              mime: mime,
              widthPx: 1,
              heightPx: 1,
            ),
          ),
          throwsArgumentError,
        );
      }
      await expectLater(
        writer.addPicture(
          workspaceId: TestIds.workspace,
          file: PreparedPicture(
            path: await source('w', 'a'),
            mime: 'image/jpeg',
            widthPx: -1,
            heightPx: 1,
          ),
        ),
        throwsArgumentError,
      );
      await nothingWritten();
    });
  });

  group('addAfterPicture (T5)', () {
    test(
      'copies room, entry and customer and points at the original',
      () async {
        final before = await writer.addPicture(
          workspaceId: TestIds.workspace,
          file: await picture('before'),
          roomId: TestIds.keller,
        );
        final after = await writer.addAfterPicture(
          of: before,
          file: await picture('after'),
        );
        final row = await pictureRow(after);
        expect(row.afterOf, before);
        expect(row.roomId, TestIds.keller);
        expect(row.customerId, TestIds.familieBeispiel);
        expect(row.workspaceId, TestIds.workspace);
        expect(fieldsOf((await outbox()).last)['after_of'], before);
      },
    );

    test('an unknown or deleted original is refused', () async {
      await expectLater(
        writer.addAfterPicture(
          of: '01970000-0000-7000-8000-0000000000ff',
          file: await picture('a'),
        ),
        throwsArgumentError,
      );
      final before = await writer.addPicture(
        workspaceId: TestIds.workspace,
        file: await picture('before'),
      );
      await writer.deletePicture(before);
      await expectLater(
        writer.addAfterPicture(of: before, file: await picture('b')),
        throwsArgumentError,
      );
    });
  });

  group('addNote (T7)', () {
    test('a text note has no upload', () async {
      final id = await writer.addNote(
        workspaceId: TestIds.workspace,
        subjectType: 'room',
        subjectId: TestIds.keller,
        text: 'Feuchte Wand links',
      );
      final row = await noteRow(id);
      expect(row.noteText, 'Feuchte Wand links');
      expect(row.customerId, TestIds.familieBeispiel);
      expect(row.audioSha256, isNull);
      expect(row.transcript, isNull);
      expect(row.transcriptSource, isNull);
      expect(fieldsOf((await outbox()).single), <String, Object?>{
        'workspace_id': TestIds.workspace,
        'customer_id': TestIds.familieBeispiel,
        'subject_type': 'room',
        'subject_id': TestIds.keller,
        'text': 'Feuchte Wand links',
      });
      expect(await db.select(db.uploads).get(), isEmpty);
    });

    test(
      'a voice note keeps its recording and the device transcript',
      () async {
        final id = await writer.addNote(
          workspaceId: TestIds.workspace,
          subjectType: 'customer',
          subjectId: TestIds.frauMuster,
          audio: PreparedAudio(
            path: await source('m4a', 'm4a bytes'),
            seconds: 12,
          ),
          transcript: 'Schrank bleibt stehen',
        );
        final sha = hashOf('m4a bytes');
        final row = await noteRow(id);
        expect(
          row.customerId,
          TestIds.frauMuster,
          reason: 'a customer is itself',
        );
        expect(row.audioSha256, sha);
        expect(row.audioBytes, 9);
        expect(row.audioSeconds, 12);
        expect(row.transcript, 'Schrank bleibt stehen');
        expect(row.transcriptSource, 'device');
        expect(row.noteText, isNull);
        expect((await db.select(db.uploads).get()).single.sha256, sha);
        expect(await media.has(sha), isTrue);
      },
    );

    test('notes about a job and a picture take their customer', () async {
      final job = await writer.addNote(
        workspaceId: TestIds.workspace,
        subjectType: 'job',
        subjectId: jobId,
        text: 'Schlüssel beim Nachbarn',
      );
      expect((await noteRow(job)).customerId, TestIds.familieBeispiel);
      final pic = await writer.addPicture(
        workspaceId: TestIds.workspace,
        file: await picture('p'),
        customerId: TestIds.herrProbe,
      );
      final onPicture = await writer.addNote(
        workspaceId: TestIds.workspace,
        subjectType: 'picture',
        subjectId: pic,
        text: 'Kratzer',
      );
      expect((await noteRow(onPicture)).customerId, TestIds.herrProbe);
    });

    test('refusals write nothing', () async {
      final cases = <Future<String> Function()>[
        () => writer.addNote(
          workspaceId: TestIds.workspace,
          subjectType: 'room',
          subjectId: TestIds.keller,
          text: '   ',
        ),
        () => writer.addNote(
          workspaceId: TestIds.workspace,
          subjectType: 'site',
          subjectId: TestIds.alteWohnung,
          text: 'x',
        ),
        () => writer.addNote(
          workspaceId: TestIds.workspace,
          subjectType: 'room',
          subjectId: '01970000-0000-7000-8000-0000000000ff',
          text: 'x',
        ),
        () => writer.addNote(
          workspaceId: TestIds.workspace,
          subjectType: 'room',
          subjectId: TestIds.alterRaum,
          text: 'x',
        ),
        () async => writer.addNote(
          workspaceId: TestIds.workspace,
          subjectType: 'room',
          subjectId: TestIds.keller,
          audio: PreparedAudio(path: await source('neg', 'a'), seconds: -1),
        ),
        () async => writer.addNote(
          workspaceId: TestIds.workspace,
          subjectType: 'room',
          subjectId: TestIds.keller,
          audio: PreparedAudio(path: await source('empty', ''), seconds: 0),
        ),
      ];
      for (final attempt in cases) {
        await expectLater(attempt(), throwsArgumentError);
      }
      await nothingWritten();
    });
  });

  group('editNote (T8)', () {
    test('a corrected transcript becomes manual', () async {
      final id = await writer.addNote(
        workspaceId: TestIds.workspace,
        subjectType: 'room',
        subjectId: TestIds.keller,
        audio: PreparedAudio(path: await source('a', 'audio'), seconds: 3),
        transcript: 'Schrang',
      );
      final changeId = await writer.editNote(
        id,
        transcript: const Value<String?>('Schrank'),
      );
      expect(changeId, isNotNull);
      final row = await noteRow(id);
      expect(row.transcript, 'Schrank');
      expect(row.transcriptSource, 'manual');
      expect(fieldsOf((await outbox()).last), <String, Object?>{
        'transcript': 'Schrank',
        'transcript_source': 'manual',
      });

      await writer.editNote(id, transcript: const Value<String?>(''));
      final cleared = await noteRow(id);
      expect(cleared.transcript, isNull);
      expect(cleared.transcriptSource, isNull);

      await writer.editNote(id, text: const Value<String?>(null));
      expect((await noteRow(id)).noteText, isNull, reason: 'audio remains');
    });

    test('a text-only note keeps its text', () async {
      final id = await writer.addNote(
        workspaceId: TestIds.workspace,
        subjectType: 'room',
        subjectId: TestIds.keller,
        text: 'alt',
      );
      await expectLater(
        writer.editNote(id, text: const Value<String?>(' ')),
        throwsArgumentError,
      );
      expect(
        await writer.editNote(id, text: const Value<String?>('alt')),
        isNull,
      );
      await writer.editNote(id, text: const Value<String?>('neu'));
      expect((await noteRow(id)).noteText, 'neu');
      expect(await outbox(), hasLength(2));
    });
  });

  test('delete and restore are tombstones and keep the file (T9)', () async {
    final pic = await writer.addPicture(
      workspaceId: TestIds.workspace,
      file: await picture('keep'),
      roomId: TestIds.keller,
    );
    final note = await writer.addNote(
      workspaceId: TestIds.workspace,
      subjectType: 'picture',
      subjectId: pic,
      text: 'x',
    );
    await writer.deletePicture(pic);
    await writer.deleteNote(note);
    expect((await pictureRow(pic)).deletedAt, isNotNull);
    expect((await noteRow(note)).deletedAt, isNotNull);
    expect(await watchPicturesOfRoom(db, TestIds.keller).first, isEmpty);
    expect(await watchNotesOf(db, 'picture', pic).first, isEmpty);
    expect(await media.has(hashOf('keep')), isTrue);

    await writer.restorePicture(pic);
    await writer.restoreNote(note);
    expect((await pictureRow(pic)).deletedAt, isNull);
    expect((await noteRow(note)).deletedAt, isNull);
    expect((await outbox()).map((o) => o.op), <String>[
      'upsert',
      'upsert',
      'delete',
      'delete',
      'restore',
      'restore',
    ]);
  });

  test('queries list live rows in a stable order (D-245)', () async {
    final first = await writer.addPicture(
      workspaceId: TestIds.workspace,
      file: PreparedPicture(
        path: await source('1', '1'),
        mime: 'image/jpeg',
        widthPx: 1,
        heightPx: 1,
        takenAt: DateTime.utc(2026, 11, 19, 8),
      ),
      roomId: TestIds.keller,
    );
    final second = await writer.addPicture(
      workspaceId: TestIds.workspace,
      file: PreparedPicture(
        path: await source('2', '2'),
        mime: 'image/jpeg',
        widthPx: 1,
        heightPx: 1,
        takenAt: DateTime.utc(2026, 11, 19, 7),
      ),
      roomId: TestIds.keller,
    );
    final loose = await writer.addPicture(
      workspaceId: TestIds.workspace,
      file: await picture('loose'),
      customerId: TestIds.familieBeispiel,
    );
    expect(
      (await watchPicturesOfRoom(db, TestIds.keller).first).map((p) => p.id),
      <String>[second, first],
    );
    expect(
      (await watchPicturesOfCustomerWithoutRoom(
        db,
        TestIds.familieBeispiel,
      ).first).map((p) => p.id),
      <String>[loose],
    );
  });

  test('without a media folder only text notes work (T14, D-246)', () async {
    final web = writerFor(NoMediaStore());
    await expectLater(
      web.addPicture(workspaceId: TestIds.workspace, file: await picture('a')),
      throwsUnsupportedError,
    );
    await expectLater(
      web.addNote(
        workspaceId: TestIds.workspace,
        subjectType: 'room',
        subjectId: TestIds.keller,
        audio: PreparedAudio(path: await source('a', 'a'), seconds: 1),
      ),
      throwsUnsupportedError,
    );
    await nothingWritten();
    await web.addNote(
      workspaceId: TestIds.workspace,
      subjectType: 'room',
      subjectId: TestIds.keller,
      text: 'geht',
    );
    expect(await db.select(db.notes).get(), hasLength(1));
  });
}
