import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';

/// The camera may not be used: the person refused it, or the phone does
/// not allow it (D-269).
class CameraDenied implements Exception {
  const CameraDenied();
}

/// No camera, or it failed to start.
class CameraUnavailable implements Exception {
  const CameraUnavailable(this.cause);

  final Object cause;

  @override
  String toString() => 'CameraUnavailable($cause)';
}

/// What the camera screen needs from a camera. Tests use a fake.
abstract class CaptureCamera {
  /// Starts the live image; asks for the permission the first time.
  /// Throws [CameraDenied] or [CameraUnavailable].
  Future<void> open();

  /// The live image, once [open] finished.
  Widget preview();

  /// Takes one shot and returns the path of its file.
  Future<String> takePicture();

  /// Stops the camera; [open] may be called again afterwards.
  Future<void> close();
}

/// Makes a new camera for each time the screen opens.
typedef CaptureCameraFactory = CaptureCamera Function();

/// The device camera through the `camera` plugin (D-265): back camera,
/// about 3840 x 2160, no sound (D-266).
class PluginCaptureCamera implements CaptureCamera {
  CameraController? _controller;

  static const Set<String> _deniedCodes = <String>{
    'CameraAccessDenied',
    'CameraAccessDeniedWithoutPrompt',
    'CameraAccessRestricted',
  };

  @override
  Future<void> open() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const CameraUnavailable('no camera');
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _controller = controller;
      await controller.initialize();
    } on CameraException catch (error) {
      await close();
      if (_deniedCodes.contains(error.code)) {
        throw const CameraDenied();
      }
      throw CameraUnavailable(error);
    }
  }

  @override
  Widget preview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return CameraPreview(controller);
  }

  @override
  Future<String> takePicture() async {
    final controller = _controller;
    if (controller == null) {
      throw const CameraUnavailable('not open');
    }
    try {
      return (await controller.takePicture()).path;
    } on CameraException catch (error) {
      throw CameraUnavailable(error);
    }
  }

  @override
  Future<void> close() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}
