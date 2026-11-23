import 'package:material_ui/material_ui.dart';

/// What the scan screen needs from a QR scanner (D-464). The engine behind
/// it (D-463) can change without touching a screen. Tests use a fake.
abstract class QrScanner {
  /// Starts the live image and reading; asks for the camera permission the
  /// first time. Throws `CameraDenied` or `CameraUnavailable` (D-269).
  Future<void> open();

  /// The live image, once [open] finished.
  Widget preview();

  /// The text of each QR code read, unchanged (D-51), as often as it is
  /// read. The screen takes the first one that fits (D-466, D-469) and then
  /// closes the scanner.
  Stream<String> get codes;

  /// Stops the camera and reading; [open] may be called again afterwards.
  Future<void> close();
}

/// Makes a new scanner for each time the scan screen opens the camera.
typedef QrScannerFactory = QrScanner Function();
