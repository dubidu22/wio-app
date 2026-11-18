import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../results.dart';
import '../services.dart';
import 'big_button.dart';
import 'labels.dart';
import 'result_view.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.services});
  final SpikeServices services;

  Future<void> _copy(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final device = await services.platform.deviceInfo();
    await services.copyToClipboard(resultsAsMarkdown(device, services.results.results));
    messenger.showSnackBar(SnackBar(content: Text(l.copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final results = services.results.results;
    return Scaffold(
      appBar: spikeAppBar(context, l.results, backLabel: l.back),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: results.isEmpty
                  ? Center(child: Text(l.resultsEmpty))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const Divider(height: 32),
                      itemBuilder: (context, i) {
                        final r = results[i];
                        final item = r.itemId == 'free' ? l.freeNoteShort : r.itemId;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${r.mode.label(context)} · $item',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            ResultView(result: r),
                          ],
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: BigButton(
                key: const ValueKey('copy'),
                label: l.copyResults,
                onPressed: results.isEmpty ? null : () => _copy(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
