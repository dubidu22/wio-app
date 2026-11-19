import 'package:material_ui/material_ui.dart';

import 'local_picture_native.dart'
    if (dart.library.js_interop) 'local_picture_web.dart'
    as platform;
import 'media_store.dart';

/// The picture file with [sha256] as an image, decoded at most [cacheWidth]
/// pixels wide (D-257): from the media [folder] on phones, from memory on
/// the web (D-334). Call it only for a file whose state is present
/// (D-332); null when there is nothing to show after all.
ImageProvider? localPicture(
  MediaStore store,
  String? folder,
  String sha256, {
  int? cacheWidth,
}) {
  final image = platform.localPicture(store, folder, sha256);
  if (image == null || cacheWidth == null) return image;
  // Never decoded larger than the file itself (D-257).
  return ResizeImage(
    image,
    width: cacheWidth,
    policy: ResizeImagePolicy.fit,
    allowUpscaling: false,
  );
}
