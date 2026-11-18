@Tags(<String>['ux'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/pump.dart';
import '../support/ux_guidelines.dart';

/// Proves the UX check can fail (TST-01): without these, a broken guideline
/// would let every screen pass.
Widget _buttonScreen({required double size, required Widget child}) {
  return Scaffold(
    body: Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Semantics(
          button: true,
          child: GestureDetector(onTap: () {}, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a 48-px button fails the 56-px rule', (tester) async {
    await pumpScreen(
      tester,
      _buttonScreen(size: 48, child: const Text('Foto')),
    );
    final handle = tester.ensureSemantics();
    final result = await wioTapTargetGuideline.evaluate(tester);
    handle.dispose();
    expect(result.passed, isFalse);
  });

  testWidgets('a 56-px button with a word passes every UX rule', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _buttonScreen(size: 56, child: const Text('Foto')),
    );
    await expectMeetsUxRules(tester);
  });

  testWidgets('a button without a word fails the label rule', (tester) async {
    await pumpScreen(
      tester,
      _buttonScreen(size: 56, child: const SizedBox.expand()),
    );
    final handle = tester.ensureSemantics();
    final result = await labeledTapTargetGuideline.evaluate(tester);
    handle.dispose();
    expect(result.passed, isFalse);
  });
}
