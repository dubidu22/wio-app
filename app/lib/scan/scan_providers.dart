import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camera_qr_scanner.dart';
import 'qr_scanner.dart';

/// Makes the QR scanner (D-463, D-464). Tests override it with a fake.
final qrScannerProvider = Provider<QrScannerFactory>(
  (ref) => CameraQrScanner.new,
);
