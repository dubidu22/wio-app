import 'package:material_ui/material_ui.dart';

import 'local_picture_native.dart'
    if (dart.library.js_interop) 'local_picture_web.dart'
    as platform;

/// The picture file with [sha256] in the media [folder] as an image,
/// decoded at most [cacheWidth] pixels wide (D-257), or null when the file
/// is not on this device (D-260). The web keeps no files (D-246).
ImageProvider? localPicture(String? folder, String sha256, {int? cacheWidth}) {
  if (folder == null) {
    return null;
  }
  return platform.localPicture(folder, sha256, cacheWidth: cacheWidth);
}
