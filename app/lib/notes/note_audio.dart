import 'note_audio_native.dart'
    if (dart.library.js_interop) 'note_audio_web.dart'
    as platform;

/// Where the player finds the recording with [sha256], for a file whose
/// state is present (D-332): a path in the media [folder] on phones, a
/// memory key on the web (D-334, D-335). Null when there is none.
String? localNoteAudio(String? folder, String sha256) =>
    platform.localNoteAudio(folder, sha256);
