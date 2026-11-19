import 'package:material_ui/material_ui.dart';

import 'media_store.dart';

/// See `local_picture.dart`: the web shows files kept in memory (D-334).
ImageProvider? localPicture(MediaStore store, String? folder, String sha256) {
  final bytes = store.bytesOf(sha256);
  return bytes == null ? null : MemoryImage(bytes);
}
