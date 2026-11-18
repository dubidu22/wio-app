import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// UX rule 3 (KB 01-product/ux-rules.md): touch targets at least 56 x 56
/// logical pixels, stricter than Android's 48.
const AccessibilityGuideline wioTapTargetGuideline = MinimumTapTargetGuideline(
  size: Size(56, 56),
  link: 'docs/kb/01-product/ux-rules.md, rule 3',
);

/// Checks one screen against every automated UX rule.
Future<void> expectMeetsUxRules(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(wioTapTargetGuideline));
  // UX rule 1: every action has a word on it, so every tap target has a label.
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  handle.dispose();
}
