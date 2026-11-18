import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'services.dart';
import 'ui/start_screen.dart';

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key, required this.services});
  final SpikeServices services;

  @override
  Widget build(BuildContext context) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        // German first (D-23): listed first, so it is the fallback.
        supportedLocales: const [Locale('de'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2E5E4E),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          // Android default; the screenshot run loads a stand-in under this name.
          fontFamily: 'Roboto',
        ),
        home: StartScreen(services: services),
      );
}
