// The start-up sweep of the media folder (plan 065, D-415..D-423).
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/media/media_sweep.dart';
import 'package:wio_app/sync/sync_engine.dart';

import '../support/test_data.dart';

String _hex(String digit) => digit * 64;

/// A media store over a temporary folder deleted when the test ends.
({MediaStore store, Directory media}) _store() {
  final base = Directory.systemTemp.createTempSync('wio-sweep-');
  addTearDown(() => base.deleteSync(recursive: true));
  final media = Directory('${base.path}/media')..createSync();
  return (store: MediaStore(() async => base.path), media: media);
}

final DateTime _old = DateTime(2020);

/// Writes [name] into [media], last changed at [time] (old by default).
File _file(Directory media, String name, {DateTime? time}) =>
    File('${media.path}/$name')
      ..writeAsStringSync(name)
      ..setLastModifiedSync(time ?? _old);

List<String> _names(Directory media) =>
    media
        .listSync()
        .map((e) => e.uri.pathSegments.lastWhere((s) => s != ''))
        .toList()
      ..sort();

Future<void> _picture(
  WioDatabase db,
  String id,
  String sha, {
  bool deleted = false,
}) => db
    .into(db.pictures)
    .insert(
      PicturesCompanion.insert(
        id: id,
        workspaceId: TestIds.workspace,
        fileSha256: sha,
        fileBytes: 10,
        fileMime: 'image/jpeg',
        widthPx: 1,
        heightPx: 1,
        deletedAt: Value<String?>(deleted ? '2026-11-19T10:00:00Z' : null),
      ),
    );

Future<void> _note(
  WioDatabase db,
  String id,
  String sha, {
  bool deleted = false,
}) => db
    .into(db.notes)
    .insert(
      NotesCompanion.insert(
        id: id,
        workspaceId: TestIds.workspace,
        subjectType: 'customer',
        subjectId: TestIds.frauMuster,
        audioSha256: Value<String?>(sha),
        deletedAt: Value<String?>(deleted ? '2026-11-19T10:00:00Z' : null),
      ),
    );

void main() {
  group('MediaStore.sweep (T1, D-418, D-419)', () {
    test('named files stay, unnamed old files go, recent files stay', () async {
      final (:store, :media) = _store();
      final now = DateTime.now();
      _file(media, _hex('a'));
      _file(media, _hex('b'));
      _file(media, _hex('c'), time: now);
      _file(media, '1-2.tmp');
      _file(media, '3-4.tmp', time: now);
      _file(media, '${_hex('d')}.part');
      _file(media, '${_hex('e')}.part');
      _file(media, 'notes.txt');
      _file(media, '${_hex('f')}.jpg');
      Directory('${media.path}/${_hex('9')}').createSync();

      await store.sweep(<String>{
        _hex('a'),
        _hex('d'),
      }, before: now.subtract(mediaSweepMargin));

      expect(
        _names(media),
        <String>[
          '3-4.tmp',
          _hex('9'),
          _hex('a'),
          _hex('c'),
          '${_hex('d')}.part',
          '${_hex('f')}.jpg',
          'notes.txt',
        ]..sort(),
      );
    });

    test('a file changed just inside the margin stays', () async {
      final (:store, :media) = _store();
      final start = DateTime.now();
      _file(
        media,
        _hex('a'),
        time: start.subtract(mediaSweepMargin).add(const Duration(minutes: 1)),
      );
      _file(
        media,
        _hex('b'),
        time: start.subtract(mediaSweepMargin + const Duration(minutes: 1)),
      );
      await store.sweep(<String>{}, before: start.subtract(mediaSweepMargin));
      expect(_names(media), <String>[_hex('a')]);
    });

    test('a link is never followed or deleted', () async {
      final (:store, :media) = _store();
      final outside = Directory.systemTemp.createTempSync('wio-outside-');
      addTearDown(() => outside.deleteSync(recursive: true));
      final target = _file(outside, _hex('a'));
      Link('${media.path}/${_hex('b')}').createSync(target.path);
      await store.sweep(<String>{}, before: DateTime.now());
      expect(target.existsSync(), isTrue);
      expect(Link('${media.path}/${_hex('b')}').existsSync(), isTrue);
    });
  });

  group('sweepMedia (T2, D-416, D-417, D-422)', () {
    test(
      'every kind of row keeps its file; an old unnamed file goes',
      () async {
        final db = memoryDatabase();
        addTearDown(db.close);
        final (:store, :media) = _store();
        await _picture(db, 'p1', _hex('1'));
        await _picture(db, 'p2', _hex('2'), deleted: true);
        await _note(db, 'n1', _hex('3'));
        await _note(db, 'n2', _hex('4'), deleted: true);
        await db
            .into(db.outbox)
            .insert(
              OutboxCompanion.insert(
                changeId: 'c1',
                entity: 'pictures',
                entityId: 'p9',
                fields: jsonEncode(<String, Object?>{'file_sha256': _hex('5')}),
                deviceTime: '2026-11-19T10:00:00Z',
              ),
            );
        await db
            .into(db.rejectedChanges)
            .insert(
              RejectedChangesCompanion.insert(
                changeId: 'c2',
                entity: 'notes',
                entityId: 'n9',
                op: 'upsert',
                fields: jsonEncode(<String, Object?>{
                  'audio_sha256': _hex('6'),
                }),
                deviceTime: '2026-11-19T10:00:00Z',
                reason: 'validation',
                rejectedAt: '2026-11-19T10:00:01Z',
              ),
            );
        await db
            .into(db.serverRecords)
            .insert(
              ServerRecordsCompanion.insert(
                entity: 'pictures',
                id: 'p8',
                revision: 3,
                fields: jsonEncode(<String, Object?>{'file_sha256': _hex('7')}),
              ),
            );
        await db
            .into(db.uploads)
            .insert(
              UploadsCompanion.insert(
                sha256: _hex('8'),
                path: '/uploads/${_hex('8')}',
                size: 10,
                createdAt: '2026-11-19T10:00:00Z',
              ),
            );
        for (final digit in <String>['1', '2', '3', '4', '5', '6', '7', '8']) {
          _file(media, _hex(digit));
        }
        _file(media, _hex('9'));
        _file(media, '17-18.tmp');

        await sweepMedia(db, store);

        expect(_names(media), <String>[
          for (final digit in <String>['1', '2', '3', '4', '5', '6', '7', '8'])
            _hex(digit),
        ]);
      },
    );

    test(
      'a download in progress named only by a server copy keeps its part',
      () async {
        final db = memoryDatabase();
        addTearDown(db.close);
        final (:store, :media) = _store();
        await db
            .into(db.serverRecords)
            .insert(
              ServerRecordsCompanion.insert(
                entity: 'pictures',
                id: 'p8',
                revision: 3,
                fields: jsonEncode(<String, Object?>{'file_sha256': _hex('7')}),
              ),
            );
        // Started long ago, resumes on the next sync (D-329).
        final part = _file(media, '${_hex('7')}.part');
        final other = _file(media, '${_hex('6')}.part');

        await sweepMedia(db, store);

        expect(part.existsSync(), isTrue);
        expect(other.existsSync(), isFalse);
      },
    );

    test('only files older than the sweep start minus the margin go', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final (:store, :media) = _store();
      await _picture(db, 'p1', _hex('1'));
      final start = DateTime(2026, 11, 19, 12);
      _file(
        media,
        _hex('a'),
        time: start.subtract(const Duration(minutes: 59)),
      );
      _file(
        media,
        _hex('b'),
        time: start.subtract(const Duration(minutes: 61)),
      );

      await sweepMedia(db, store, clock: () => start);

      expect(_names(media), <String>[_hex('a')]);
    });

    test('an empty database deletes nothing (D-422)', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final (:store, :media) = _store();
      _file(media, _hex('a'));
      _file(media, '1-2.tmp');

      await sweepMedia(db, store);

      expect(_names(media), <String>['1-2.tmp', _hex('a')]);
    });
  });

  group('MediaStore.keep stamps the time (T3, D-420)', () {
    test('a reused old file gets a fresh time, so a sweep spares it', () async {
      final (:store, :media) = _store();
      final source = File('${media.parent.path}/shot.jpg')
        ..writeAsBytesSync(<int>[1, 2, 3]);
      final first = await store.keep(source.path);
      File(first.path).setLastModifiedSync(_old);
      // A sweep that started now read the rows before this keep's row.
      final sweepStart = DateTime.now();
      final again = await store.keep(source.path);

      expect(again.sha256, first.sha256);
      expect(
        File(again.path)
            .lastModifiedSync()
            .isBefore(sweepStart.subtract(const Duration(seconds: 2))),
        isFalse,
      );
      await store.sweep(
        <String>{},
        before: sweepStart.subtract(mediaSweepMargin),
      );
      expect(_names(media), <String>[first.sha256]);
    });

    test('a new file is stamped now even when the source is old', () async {
      final (:store, :media) = _store();
      final source = File('${media.parent.path}/old.m4a')
        ..writeAsBytesSync(<int>[4, 5, 6])
        ..setLastModifiedSync(_old);
      final sweepStart = DateTime.now();
      final kept = await store.keep(source.path);

      await store.sweep(
        <String>{},
        before: sweepStart.subtract(mediaSweepMargin),
      );
      expect(_names(media), <String>[kept.sha256]);
    });
  });

  group('sweepMedia during a 410 resync (#100, D-459)', () {
    Future<void> revision(WioDatabase db, int value) => db
        .into(db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            workspaceId: TestIds.workspace,
            lastRevision: value,
          ),
        );

    test('an unfinished resync keeps every file (T5)', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final (:store, :media) = _store();
      // Page 1 brought back p1; the record of the second file is on a page
      // not pulled again yet.
      await _picture(db, 'p1', _hex('1'));
      await revision(db, storedRevision(500, unfinished: true));
      _file(media, _hex('1'));
      _file(media, _hex('2'));
      _file(media, '${_hex('3')}.part');
      _file(media, '1-2.tmp');

      await sweepMedia(db, store);

      expect(
        _names(media),
        <String>[_hex('1'), _hex('2'), '${_hex('3')}.part', '1-2.tmp']..sort(),
      );
    });

    test(
      'once the pull is complete the sweep deletes as before (T6)',
      () async {
        final db = memoryDatabase();
        addTearDown(db.close);
        final (:store, :media) = _store();
        await _picture(db, 'p1', _hex('1'));
        await revision(db, storedRevision(500, unfinished: true));
        _file(media, _hex('1'));
        _file(media, _hex('2'));
        await sweepMedia(db, store);
        expect(_names(media), <String>[_hex('1'), _hex('2')]);

        await revision(db, 1300);
        await sweepMedia(db, store);
        expect(_names(media), <String>[_hex('1')]);
      },
    );
  });
}
