import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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

  /// When set, [open] waits for it, as the real camera waits for the
  /// permission prompt.
  Completer<void>? openGate;

  /// Thrown by [takePicture].
  Exception? shotError;

  int opened = 0;
  int closed = 0;
  int shots = 0;
  bool get isOpen => opened > closed;

  @override
  Future<void> open() async {
    opened++;
    final gate = openGate;
    if (gate != null) await gate.future;
    final error = openError;
    if (error != null) throw error;
  }

  @override
  Widget preview({Widget? overlay}) => AspectRatio(
    aspectRatio: 9 / 16,
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const ColoredBox(
          key: ValueKey<String>('fake-preview'),
          color: Color(0xFF6B7780),
        ),
        ?overlay,
      ],
    ),
  );

  /// The bytes of every shot taken, in order: the camera's own frames.
  final List<Uint8List> shotBytes = <Uint8List>[];

  @override
  Future<String> takePicture() async {
    final error = shotError;
    if (error != null) throw error;
    final target = folder;
    if (target == null) throw StateError('no folder for shots');
    final file = File('$target/shot-${shots++}.jpg');
    final bytes = shotWithLocation(width: 320, height: 240, shade: shots * 50);
    shotBytes.add(bytes);
    file.writeAsBytesSync(bytes);
    return file.path;
  }

  @override
  Future<void> close() async {
    closed++;
  }
}
