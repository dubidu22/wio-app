/// Prefix of a recording kept in the web's memory (D-335).
const String webMemoryPrefix = 'memory:';

/// See `note_audio.dart`.
String? localNoteAudio(String? folder, String sha256) =>
    '$webMemoryPrefix$sha256';
