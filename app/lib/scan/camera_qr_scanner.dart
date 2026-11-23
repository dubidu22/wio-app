import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../camera/capture_camera.dart';
import 'qr_decoder.dart';
import 'qr_scanner.dart';

/// One frame's brightness plane, sent to the decoding isolate.
typedef BrightnessFrame = ({Uint8List y, int width, int height, int stride});

String? _decodeFrame(BrightnessFrame frame) =>
    decodeQr(frame.y, frame.width, frame.height, frame.stride);

/// Decodes one frame off the UI thread. Tests replace it.
typedef FrameDecoder = Future<String?> Function(BrightnessFrame frame);

/// Decodes in a background isolate (`compute`), D-463.
Future<String?> decodeInBackground(BrightnessFrame frame) =>
    compute(_decodeFrame, frame);

/// The QR scanner of D-463: the `camera` plugin's back camera at about
/// 1280 x 720 streams YUV 4:2:0 frames; only the brightness plane of a
/// frame is decoded with zxing2, off the UI thread. At most one frame is
/// being decoded at a time; frames arriving meanwhile are dropped, so a
/// slow phone reads fewer frames instead of building a queue. Frames stay
/// in memory and are never written anywhere; only the code text leaves
/// this class (D-427).
class CameraQrScanner implements QrScanner {
  CameraQrScanner({this._decode = decodeInBackground});

  final FrameDecoder _decode;
  CameraController? _controller;
  final StreamController<String> _codes = StreamController<String>.broadcast();
  bool _busy = false;

  static const Set<String> _deniedCodes = <String>{
    'CameraAccessDenied',
    'CameraAccessDeniedWithoutPrompt',
    'CameraAccessRestricted',
  };

  @override
  Stream<String> get codes => _codes.stream;

  @override
  Future<void> open() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw const CameraUnavailable('no camera');
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      _controller = controller;
      await controller.initialize();
      await controller.startImageStream(_onFrame);
    } on CameraException catch (error) {
      await close();
      if (_deniedCodes.contains(error.code)) throw const CameraDenied();
      throw CameraUnavailable(error);
    }
  }

  void _onFrame(CameraImage image) {
    if (_busy || image.planes.isEmpty) return;
    final plane = image.planes.first;
    _busy = true;
    // A copy: the plugin reuses the frame's buffer once this returns.
    final frame = (
      y: Uint8List.fromList(plane.bytes),
      width: image.width,
      height: image.height,
      stride: plane.bytesPerRow,
    );
    unawaited(_read(frame));
  }

  Future<void> _read(BrightnessFrame frame) async {
    try {
      final text = await _decode(frame);
      if (text != null && _controller != null) _codes.add(text);
    } on Object {
      // A frame that cannot be read is like a frame without a code.
    } finally {
      _busy = false;
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
  Future<void> close() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } on Object {
      // Disposing below stops the stream as well.
    }
    await controller.dispose();
  }
}
