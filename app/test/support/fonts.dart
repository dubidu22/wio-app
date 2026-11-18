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
}
