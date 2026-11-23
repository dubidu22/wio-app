import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:wio_app/scan/qr_scanner.dart';

/// A QR scanner for widget tests (plan 102): a grey preview, and codes
/// only when a test calls [read].
class FakeQrScanner implements QrScanner {
  FakeQrScanner({this.openError});

  /// Thrown by [open], for example `CameraDenied`.
  Exception? openError;

  int opened = 0;
  int closed = 0;
  bool get isOpen => opened > closed;

  final StreamController<String> _codes = StreamController<String>.broadcast();

  @override
  Stream<String> get codes => _codes.stream;

  /// The scanner reads [code] from the live image.
  void read(String code) => _codes.add(code);

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
      key: ValueKey<String>('fake-scan-preview'),
      color: Color(0xFF6B7780),
    ),
  );

  /// When set, [close] waits for it, as the real camera waits for its
  /// controller to let go (PR 113 M1).
  Completer<void>? closeGate;

  @override
  Future<void> close() async {
    final gate = closeGate;
    if (gate != null) await gate.future;
    closed++;
  }
}
