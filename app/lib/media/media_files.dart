import 'media_files_native.dart'
    if (dart.library.js_interop) 'media_files_web.dart'
    as platform;

/// Hashes of the finished files in the media [folder] (D-332): one listing
/// at start, unfinished parts and temporary copies left out. Synchronous:
/// one directory read, once, never in a widget's build.
Set<String> listMediaFolder(String folder) => platform.listMediaFolder(folder);

/// Whether the file with [sha256] is in the media [folder]; asked once per
/// new hash, never for a hash known present (D-332).
bool mediaFileExists(String folder, String sha256) =>
    platform.mediaFileExists(folder, sha256);
