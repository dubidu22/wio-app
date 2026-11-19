import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_writer.dart';
import '../data/media_writer.dart';
import '../media/media_store.dart';
import '../shell/providers.dart';
import '../sync/upload_queue.dart';
import 'capture_camera.dart';
import 'capture_files.dart';
import 'capture_queue.dart';
import 'picture_processor.dart';

/// Makes the device camera (D-265). Tests override it with a fake.
final captureCameraProvider = Provider<CaptureCameraFactory>(
  (ref) => PluginCaptureCamera.new,
);

/// The camera's working folder (D-268). Tests override it.
final captureFilesProvider = Provider<CaptureFiles>(
  (ref) => CaptureFiles.temporary(),
);

/// Resizes and strips a shot (D-267). Tests override it to hold a shot
/// back.
final preparePictureProvider = Provider<PictureProcessor>(
  (ref) => preparePicture,
);

/// Whether this build takes pictures: not on the web (D-274), where the
/// media store keeps no files (D-246).
final canTakePicturesProvider = Provider<bool>(
  (ref) => ref.watch(mediaStoreProvider).supported,
);

/// The one capture queue of the app (D-268). It lives as long as the app,
/// so leaving the camera does not stop it.
final captureQueueProvider = Provider<CaptureQueue>((ref) {
  final db = ref.watch(databaseProvider);
  final clock = ref.watch(clockProvider);
  return CaptureQueue(
    db: db,
    writer: MediaWriter(
      db,
      LocalWriter(db, clock: clock),
      ref.watch(mediaStoreProvider),
      ref.watch(uploadStoreProvider),
      clock: clock,
    ),
    files: ref.watch(captureFilesProvider),
    prepare: ref.watch(preparePictureProvider),
  );
});
