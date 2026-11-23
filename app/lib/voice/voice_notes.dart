import 'package:flutter/foundation.dart';

import '../camera/capture_files.dart';
import '../data/database.dart';
import '../data/media_writer.dart';
import 'm4a_clean.dart';

/// What a voice note is about (D-295): a picture, else an entry (plan 103),
/// else a room, else the customer (the customer screen is the job's
/// screen). A [roomId] never comes with an [entryId].
typedef VoiceTarget = ({
  String customerId,
  String? roomId,
  String? entryId,
  String? pictureId,
});

/// The longest voice note; it then stops and saves by itself (D-292).
const Duration voiceNoteLimit = Duration(minutes: 10);

/// A recording shorter than this is not kept (D-292).
const Duration voiceNoteMinimum = Duration(milliseconds: 500);

/// The note subject of [target]: type and id.
({String type, String id}) voiceSubject(VoiceTarget target) {
  final picture = target.pictureId;
  if (picture != null) return (type: 'picture', id: picture);
  final entry = target.entryId;
  if (entry != null) return (type: 'entry', id: entry);
  final room = target.roomId;
  if (room != null) return (type: 'room', id: room);
  return (type: 'customer', id: target.customerId);
}

/// Keeps finished recordings as notes (D-290): cleans the M4A (D-285),
/// then writes the note, its recording's upload row and the device
/// transcript in one transaction through [MediaWriter.addNote], and
/// deletes the working file.
class VoiceNotes {
  VoiceNotes(this._db, this._writer, this._files);

  final WioDatabase _db;
  final MediaWriter _writer;
  final CaptureFiles _files;

  /// A new working path for the next recording.
  Future<String> newPath() => _files.newRecordingPath();

  /// Keeps the recording at [path] of [length] as a note about [target]
  /// with [transcript]. Returns the note's id, or null when the recording
  /// was too short (D-292). The working file is deleted either way.
  Future<String?> keep({
    required VoiceTarget target,
    required String path,
    required Duration length,
    required String transcript,
  }) async {
    try {
      if (length < voiceNoteMinimum) return null;
      final bytes = await _files.read(path);
      cleanM4a(bytes);
      await _files.overwrite(path, bytes);
      final customer = await (_db.select(
        _db.customers,
      )..where((c) => c.id.equals(target.customerId))).getSingle();
      final subject = voiceSubject(target);
      return await _writer.addNote(
        workspaceId: customer.workspaceId,
        subjectType: subject.type,
        subjectId: subject.id,
        audio: PreparedAudio(
          path: path,
          seconds: (length.inMilliseconds / 1000).round(),
        ),
        transcript: transcript,
      );
    } finally {
      await discard(path);
    }
  }

  /// Deletes the working file at [path]; the start-up sweep takes it when
  /// this fails (D-268).
  Future<void> discard(String path) async {
    try {
      await _files.delete(path);
    } on Object catch (error) {
      debugPrint('wio voice: working file not deleted: $error');
    }
  }
}
