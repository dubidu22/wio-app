import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../engine.dart';
import '../services.dart';
import 'big_button.dart';
import 'labels.dart';
import 'results_screen.dart';
import 'test_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.services});
  final SpikeServices services;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: spikeAppBar(context, l.appTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.startHeading, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            for (final mode in SpikeMode.values) ...[
              BigButton(
                key: ValueKey('mode-${mode.name}'),
                label: mode.label(context),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => TestScreen(services: services, mode: mode))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 20),
                child: Text(mode.hint(context)),
              ),
            ],
            BigButton(
              key: const ValueKey('results'),
              label: l.results,
              primary: false,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => ResultsScreen(services: services))),
            ),
            const SizedBox(height: 12),
            BigButton(
              key: const ValueKey('source-code'),
              label: l.sourceCode,
              primary: false,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l.sourceCode),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.sourceCodeText),
                      const SizedBox(height: 8),
                      const SelectableText(sourceCodeUrl),
                    ],
                  ),
                  actions: [
                    BigButton(
                      label: l.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
