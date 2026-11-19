import 'dart:io';

import 'package:material_ui/material_ui.dart';

/// See `local_picture.dart`.
ImageProvider? localPicture(String folder, String sha256, {int? cacheWidth}) {
  final file = File('$folder/$sha256');
  if (!file.existsSync()) {
    return null;
  }
  final image = FileImage(file);
  if (cacheWidth == null) {
    return image;
  }
  // Never decoded larger than the file itself (D-257).
  return ResizeImage(
    image,
    width: cacheWidth,
    policy: ResizeImagePolicy.fit,
    allowUpscaling: false,
  );
}
