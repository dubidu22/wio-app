@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/start/start_screen.dart';

import '../support/pump.dart';

/// Goldens are rendered on Linux only, where CI renders them (plan 002).
final bool _notLinux = !Platform.isLinux;

void main() {
  testWidgets('start screen', skip: _notLinux, (tester) async {
    await pumpScreen(tester, const StartScreen());
    await expectLater(
      find.byType(StartScreen),
      matchesGoldenFile('goldens/start_screen.png'),
    );
  });
}
