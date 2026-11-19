/// See `note_audio.dart`.
String? localNoteAudio(String? folder, String sha256) =>
    folder == null ? null : '$folder/$sha256';
