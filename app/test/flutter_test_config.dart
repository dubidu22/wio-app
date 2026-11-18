import 'dart:async';

import 'support/fonts.dart';

/// Runs before every test file: loads the bundled font so text in widget and
/// golden tests is real text, not the test font's boxes (D-40).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  await testMain();
}
