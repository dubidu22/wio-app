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

/// The media folder of this device, or null where there is none (the web,
/// D-246) or it cannot be found. Screens look up picture files in it
/// synchronously (D-257, D-260). Tests override it.
final mediaFolderProvider = FutureProvider<String?>((ref) async {
  final store = ref.watch(mediaStoreProvider);
  if (!store.supported) {
    return null;
  }
  try {
    return await store.folder();
  } on Object {
    return null;
  }
});
