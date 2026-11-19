import 'dart:io';

/// See `note_audio.dart`.
String? localNoteAudio(String folder, String sha256) {
  final path = '$folder/$sha256';
  return File(path).existsSync() ? path : null;
}
