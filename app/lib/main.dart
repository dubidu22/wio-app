import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'sync/sync_runner.dart';

/// [args] holds `background` when the phone started the app for background
/// sync without a screen (D-381); the app then draws nothing until it comes
/// to the front, and no run starts by itself.
void main([List<String> args = const <String>[]]) {
  runApp(
    ProviderScope(
      overrides: [
        startedInBackgroundProvider.overrideWithValue(
          args.contains('background'),
        ),
      ],
      child: const WioApp(),
    ),
  );
}
