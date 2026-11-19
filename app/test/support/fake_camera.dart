import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:wio_app/camera/capture_camera.dart';

import 'jpeg_metadata.dart';

/// A camera for widget tests (plan 058): its preview is a plain grey area,
/// and each shot is a small JPEG with location EXIF written to [folder].
class FakeCamera implements CaptureCamera {
  FakeCamera({this.folder, this.openError});

  /// Where shots are written; null takes no shots (goldens).
  final String? folder;

  /// Thrown by [open], for example [CameraDenied].
  Exception? openError;

  int opened = 0;
  int closed = 0;
  int shots = 0;
  bool get isOpen => opened > closed;

  @override
  Future<void> open() async {
    opened++;
    final error = openError;
    if (error != null) throw error;
  }

  @override
  Widget preview() => const AspectRatio(
    aspectRatio: 9 / 16,
    child: ColoredBox(
      key: ValueKey<String>('fake-preview'),
      color: Color(0xFF6B7780),
    ),
  );

  @override
  Future<String> takePicture() async {
    final target = folder;
    if (target == null) throw StateError('no folder for shots');
    final file = File('$target/shot-${shots++}.jpg');
    file.writeAsBytesSync(
      shotWithLocation(width: 320, height: 240, shade: shots * 50),
    );
    return file.path;
  }

  @override
  Future<void> close() async {
    closed++;
  }
}
