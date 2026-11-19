import 'dart:io';

import 'package:material_ui/material_ui.dart';

/// See `local_picture.dart`.
ImageProvider? localPicture(String folder, String sha256, {int? cacheWidth}) {
  final file = File('$folder/$sha256');
  if (!file.existsSync()) {
    return null;
  }
  return ResizeImage.resizeIfNeeded(cacheWidth, null, FileImage(file));
}
