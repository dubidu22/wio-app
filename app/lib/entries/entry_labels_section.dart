import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/entry_queries.dart' show LabelOn;
import '../l10n/app_localizations.dart';
import '../planning/place_screen.dart' show entryLocation;
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'word_chip.dart';

/// **Labels** on the entry screen (plan 104): a chip for every label of the
/// workspace, most recently used first. A tap adds the label, a tap on a
/// chosen chip ("… · gewählt") takes it off again; **Neues Label** opens
/// its own screen.
class EntryLabelsSection extends ConsumerWidget {
  const EntryLabelsSection({
    required this.customerId,
    required this.entryId,
    super.key,
  });

  final String customerId;
  final String entryId;

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    Label label,
    LabelOn? on,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).vocabularyNotSaved;
    final writer = ref.read(entryWriterProvider);
    try {
      if (on != null) {
        await writer.removeLabel(on.linkId);
      } else {
        await writer.addLabel((type: 'entry', id: entryId), label.id);
      }
    } on Object catch (error) {
      debugPrint('wio entry: label not saved: $error');
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final choices = ref.watch(labelChoicesProvider);
    final chosen = ref.watch(entryLabelsProvider(entryId));
    final Widget chips = switch ((choices, chosen)) {
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
        LoadFailed(message: l10n.loadFailed, error: error),
      (
        AsyncData(value: final List<Label> all),
        AsyncData(value: final List<LabelOn> on),
      ) =>
        all.isEmpty
            ? HintText(l10n.labelsEmpty)
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final label in all)
                    Builder(
                      builder: (context) {
                        LabelOn? mine;
                        for (final link in on) {
                          if (link.label.id == label.id) mine = link;
                        }
                        return WordChip(
                          label: mine == null
                              ? label.name
                              : l10n.labelChosen(label.name),
                          chosen: mine != null,
                          onPressed: () => _toggle(context, ref, label, mine),
                        );
                      },
                    ),
                ],
              ),
      _ => const SizedBox.shrink(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeading(l10n.labelsHeading),
        chips,
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
            onPressed: () =>
                context.go('${entryLocation(customerId, entryId)}/label'),
            child: Text(l10n.labelNew),
          ),
        ),
      ],
    );
  }
}
