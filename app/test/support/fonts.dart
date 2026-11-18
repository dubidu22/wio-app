import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/app.dart';

/// Font files declared in pubspec.yaml, loaded once per test run.
const List<String> appFontAssets = <String>[
  'assets/fonts/Roboto-Regular.ttf',
  'assets/fonts/Roboto-Medium.ttf',
];

Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader(wioFontFamily);
  for (final asset in appFontAssets) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
  // The icon font that `uses-material-design: true` bundles, so icons in
  // goldens are real glyphs (for example the arrow of "Zurück", D-74).
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();
}
