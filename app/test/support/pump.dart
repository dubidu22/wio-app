import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/app.dart';
import 'package:wio_app/l10n/app_localizations.dart';

/// Phone size used by goldens and screenshots in PRs (CLAUDE.md: 390 x 844).
const Size phoneSize = Size(390, 844);

/// Pumps [screen] inside the app's theme and German localisation at phone size.
Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: wioLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: wioTheme(),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}
