import 'note_audio_native.dart'
    if (dart.library.js_interop) 'note_audio_web.dart'
    as platform;

/// The path of the recording with [sha256] in the media [folder], or null
/// when it is not on this device (D-305). The web keeps no files before
/// #62 (D-246).
String? localNoteAudio(String? folder, String sha256) {
  if (folder == null) return null;
  return platform.localNoteAudio(folder, sha256);
}
