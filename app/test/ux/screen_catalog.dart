import 'package:material_ui/material_ui.dart';
import 'package:wio_app/start/start_screen.dart';

/// Every screen of the app, keyed by its source file under lib/.
/// screens_test.dart checks each one against the UX rules and fails when a
/// file named *_screen.dart is missing here.
final Map<String, Widget Function()> screenCatalog =
    <String, Widget Function()>{
      'lib/start/start_screen.dart': () => const StartScreen(),
    };
