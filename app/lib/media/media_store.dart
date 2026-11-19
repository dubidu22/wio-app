import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_store_native.dart'
    if (dart.library.js_interop) 'media_store_web.dart';

export 'media_store_native.dart'
    if (dart.library.js_interop) 'media_store_web.dart';

/// The device's media folder (D-240). Tests override it with a temporary
/// folder.
final mediaStoreProvider = Provider<MediaStore>(
  (ref) => MediaStore.appSupport(),
);
