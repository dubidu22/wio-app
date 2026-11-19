import 'dart:io';

final RegExp _hash = RegExp(r'^[0-9a-f]{64}$');

/// See `media_files.dart`.
Set<String> listMediaFolder(String folder) {
  final dir = Directory(folder);
  if (!dir.existsSync()) return <String>{};
  return <String>{
    for (final entry in dir.listSync(followLinks: false))
      if (entry is File && _hash.hasMatch(entry.uri.pathSegments.last))
        entry.uri.pathSegments.last,
  };
}

/// See `media_files.dart`.
bool mediaFileExists(String folder, String sha256) =>
    File('$folder/$sha256').existsSync();
