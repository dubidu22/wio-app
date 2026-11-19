import 'package:drift/drift.dart';

import '../media/media_store.dart';
import '../sync/upload_queue.dart';
import 'database.dart';
import 'ids.dart';
import 'local_writer.dart';

/// A picture file ready to be kept: already resized and stripped of all
/// EXIF by the camera (D-219).
class PreparedPicture {
  const PreparedPicture({
    required this.path,
    required this.mime,
    required this.widthPx,
    required this.heightPx,
    this.takenAt,
  });

  final String path;
  final String mime;
  final int widthPx;
  final int heightPx;

  /// Device time, information only.
  final DateTime? takenAt;
}

/// A finished recording (M4A, D-58).
class PreparedAudio {
  const PreparedAudio({required this.path, required this.seconds});

  final String path;
  final int seconds;
}

/// What a note may be about (contract enum, D-50). Screens in M2 offer
/// room, picture, customer and job.
const Set<String> noteSubjectTypes = <String>{
  'entry',
  'room',
  'picture',
  'job',
  'customer',
};

/// Creates, edits, deletes and restores pictures and notes (D-241).
///
/// Files go into the media folder first (D-240); the upload row, the
/// record and its outbox row are then written in one transaction (D-242).
/// `customer_id` is derived as the server derives it and pushed only when
/// known (D-243). Everything the server would refuse for a reason the
/// device can see is refused here with an [ArgumentError] (D-244). File
/// fields never change after create.
class MediaWriter {
  MediaWriter(
    this._db,
    this._writer,
    this._media,
    this._uploads, {
    this._clock = DateTime.now,
    this._ids = newUuidV7,
  });

  final WioDatabase _db;
  final LocalWriter _writer;
  final MediaStore _media;
  final UploadStore _uploads;
  final DateTime Function() _clock;
  final IdGenerator _ids;

  /// Adds a picture and queues its upload. Its customer comes from
  /// [roomId], else [entryId], else [customerId] (customer screen "Fotos").
  /// Returns the picture's id.
  Future<String> addPicture({
    required String workspaceId,
    required PreparedPicture file,
    String? roomId,
    String? entryId,
    String? customerId,
  }) async {
    _checkPicture(file);
    final parent = roomId != null
        ? await _alive('rooms', roomId)
        : entryId != null
        ? await _alive('entries', entryId)
        : null;
    if (entryId != null && roomId != null) {
      // The server takes the room's customer; an entry of another customer
      // then breaks fk_pictures_entry_customer (PR 64 review S1).
      final entry = await _alive('entries', entryId);
      if (entry.customerId != parent!.customerId) {
        throw ArgumentError.value(
          entryId,
          'entryId',
          'an entry of another customer than the room',
        );
      }
    }
    if (customerId != null) {
      if (parent != null && parent.customerId != customerId) {
        throw ArgumentError.value(
          customerId,
          'customerId',
          'not the customer of the room or entry',
        );
      }
      if (parent == null) await _alive('customers', customerId);
    }
    return _addPicture(
      workspaceId: workspaceId,
      file: file,
      roomId: roomId,
      entryId: entryId,
      afterOf: null,
      customerId: parent?.customerId ?? customerId,
    );
  }

  /// Adds an after picture of picture [of] (D-7): same room, entry and
  /// customer as the original. Returns the new picture's id.
  Future<String> addAfterPicture({
    required String of,
    required PreparedPicture file,
  }) async {
    _checkPicture(file);
    final original = await (_db.select(
      _db.pictures,
    )..where((p) => p.id.equals(of) & p.deletedAt.isNull())).getSingleOrNull();
    if (original == null) {
      throw ArgumentError.value(of, 'of', 'no such live picture');
    }
    return _addPicture(
      workspaceId: original.workspaceId,
      file: file,
      roomId: original.roomId,
      entryId: original.entryId,
      afterOf: original.id,
      customerId: original.customerId,
    );
  }

  Future<String> _addPicture({
    required String workspaceId,
    required PreparedPicture file,
    required String? roomId,
    required String? entryId,
    required String? afterOf,
    required String? customerId,
  }) async {
    final kept = await _keep(file.path);
    final id = _ids();
    if (id == afterOf) {
      throw ArgumentError.value(afterOf, 'afterOf', 'a picture of itself');
    }
    await _db.transaction(() async {
      await _queueUpload(kept);
      await _writer.write(
        entity: 'pictures',
        id: id,
        fields: <String, Object?>{
          'workspace_id': workspaceId,
          'customer_id': ?customerId,
          'file_sha256': kept.sha256,
          'file_bytes': kept.size,
          'file_mime': file.mime,
          'width_px': file.widthPx,
          'height_px': file.heightPx,
          'taken_at': ?file.takenAt?.toUtc().toIso8601String(),
          'room_id': ?roomId,
          'entry_id': ?entryId,
          'after_of': ?afterOf,
        },
      );
    });
    return id;
  }

  /// Adds a note about [subjectId] of [subjectType] with [text], [audio] or
  /// both; a [transcript] made on the device is stored as such. Returns
  /// the note's id.
  Future<String> addNote({
    required String workspaceId,
    required String subjectType,
    required String subjectId,
    String? text,
    PreparedAudio? audio,
    String? transcript,
  }) async {
    final table = _subjectTables[subjectType];
    if (table == null) {
      throw ArgumentError.value(subjectType, 'subjectType', 'not a subject');
    }
    final body = _orNull(text);
    final heard = _orNull(transcript);
    if (body == null && audio == null) {
      throw ArgumentError('A note needs text or a recording.');
    }
    if (audio != null && audio.seconds < 0) {
      throw ArgumentError.value(audio.seconds, 'seconds', 'below zero');
    }
    final subject = await _alive(table, subjectId);
    final kept = audio == null ? null : await _keep(audio.path);
    final id = _ids();
    await _db.transaction(() async {
      if (kept != null) await _queueUpload(kept);
      await _writer.write(
        entity: 'notes',
        id: id,
        fields: <String, Object?>{
          'workspace_id': workspaceId,
          'customer_id': ?subject.customerId,
          'subject_type': subjectType,
          'subject_id': subjectId,
          'text': ?body,
          'audio_sha256': ?kept?.sha256,
          'audio_bytes': ?kept?.size,
          'audio_seconds': ?audio?.seconds,
          if (heard != null) ...<String, Object?>{
            'transcript': heard,
            'transcript_source': 'device',
          },
        },
      );
    });
    return id;
  }

  /// Changes the text or the transcript of note [id]. A changed transcript
  /// counts as corrected by hand (`manual`); an empty one is removed. A
  /// note always keeps text or a recording. Returns the change id, or null
  /// when nothing changed.
  Future<String?> editNote(
    String id, {
    Value<String?> text = const Value<String?>.absent(),
    Value<String?> transcript = const Value<String?>.absent(),
  }) async {
    final note = await (_db.select(
      _db.notes,
    )..where((n) => n.id.equals(id) & n.deletedAt.isNull())).getSingleOrNull();
    if (note == null) throw ArgumentError.value(id, 'id', 'no such live note');
    final fields = <String, Object?>{};
    if (text.present) {
      final body = _orNull(text.value);
      if (body == null && note.audioSha256 == null) {
        throw ArgumentError('A note needs text or a recording.');
      }
      if (body != note.noteText) fields['text'] = body;
    }
    if (transcript.present) {
      final heard = _orNull(transcript.value);
      if (heard != note.transcript) {
        fields['transcript'] = heard;
        fields['transcript_source'] = heard == null ? null : 'manual';
      }
    }
    if (fields.isEmpty) return null;
    return _writer.write(entity: 'notes', id: id, fields: fields);
  }

  /// Deletes picture [id] as a tombstone; its file stays (UX rule 10).
  Future<String> deletePicture(String id) =>
      _writer.delete(entity: 'pictures', id: id);

  /// Undoes [deletePicture].
  Future<String> restorePicture(String id) =>
      _writer.restore(entity: 'pictures', id: id);

  /// Deletes note [id] as a tombstone; its file stays (UX rule 10).
  Future<String> deleteNote(String id) =>
      _writer.delete(entity: 'notes', id: id);

  /// Undoes [deleteNote].
  Future<String> restoreNote(String id) =>
      _writer.restore(entity: 'notes', id: id);

  static const Map<String, String> _subjectTables = <String, String>{
    'entry': 'entries',
    'room': 'rooms',
    'picture': 'pictures',
    'job': 'jobs',
    'customer': 'customers',
  };

  static void _checkPicture(PreparedPicture file) {
    if (file.mime.isEmpty ||
        file.mime.length > 100 ||
        file.mime.codeUnits.any((c) => c < 0x20 || c > 0x7e)) {
      // The server column is ASCII (PR 64 review N2).
      throw ArgumentError.value(
        file.mime,
        'mime',
        'must be 1 to 100 printable ASCII chars',
      );
    }
    if (file.widthPx < 0 || file.heightPx < 0) {
      throw ArgumentError('Width and height must not be below zero.');
    }
  }

  static String? _orNull(String? text) =>
      text == null || text.trim().isEmpty ? null : text;

  /// Copies [source] into the media folder; an empty file is refused.
  Future<({String sha256, int size, String path})> _keep(String source) async {
    if (!_media.supported) {
      throw UnsupportedError('This device does not keep files (D-246).');
    }
    if (await _media.size(source) == 0) {
      throw ArgumentError.value(source, 'source', 'an empty file');
    }
    final kept = await _media.keep(source);
    if (kept.size == 0) {
      throw ArgumentError.value(source, 'source', 'an empty file');
    }
    return kept;
  }

  Future<void> _queueUpload(
    ({String sha256, int size, String path}) kept,
  ) async {
    final queued = await enqueueUpload(_db, _uploads, kept.path, now: _clock());
    if (queued != kept.sha256) {
      throw StateError('The media file changed while it was queued.');
    }
  }

  /// The customer of record [id] in [table], which must exist on the device
  /// and be alive. Entries are read from their typed table, so an entry not
  /// yet sent can have pictures and notes (D-445).
  Future<({String? customerId})> _alive(String table, String id) async {
    final column = table == 'customers' ? 'id' : 'customer_id';
    final row = await _db
        .customSelect(
          'SELECT "$column" AS customer_id, deleted_at FROM "$table" '
          'WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
        )
        .getSingleOrNull();
    if (row == null || row.read<String?>('deleted_at') != null) {
      throw ArgumentError.value(id, 'id', 'no such live record in $table');
    }
    return (customerId: row.read<String?>('customer_id'));
  }
}
