import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/entry_queries.dart' show KeyChoice, PropertyOn;
import '../l10n/app_localizations.dart';
import '../planning/place_screen.dart' show entryLocation;
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'property_value.dart';
import 'word_chip.dart';

/// **Eigenschaften** on the entry screen (plan 104): a chip for every
/// property key used before, most recently used first. A key with a value
/// on this entry says it in words ("Gewicht: 12 kg"); a tap opens the value
/// screen. **Neue Eigenschaft** opens the screen for a new key.
class EntryPropertiesSection extends ConsumerWidget {
  const EntryPropertiesSection({
    required this.customerId,
    required this.entryId,
    super.key,
  });

  final String customerId;
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final base = entryLocation(customerId, entryId);
    final choices = ref.watch(keyChoicesProvider);
    final values = ref.watch(entryPropertiesProvider(entryId));
    final Widget chips = switch ((choices, values)) {
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
        LoadFailed(message: l10n.loadFailed, error: error),
      (
        AsyncData(value: final List<KeyChoice> all),
        AsyncData(value: final List<PropertyOn> on),
      ) =>
        all.isEmpty
            ? HintText(l10n.propertiesEmpty)
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final choice in all)
                    _chip(context, l10n, base, choice.key.id, choice, on),
                ],
              ),
      _ => const SizedBox.shrink(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeading(l10n.propertiesHeading),
        chips,
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
            onPressed: () => context.go('$base/eigenschaft/neu'),
            child: Text(l10n.propertyNew),
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    AppLocalizations l10n,
    String base,
    String keyId,
    KeyChoice choice,
    List<PropertyOn> on,
  ) {
    PropertyOn? mine;
    for (final value in on) {
      if (value.key.id == keyId) mine = value;
    }
    return WordChip(
      label: mine == null
          ? choice.key.name
          : l10n.propertyChip(
              choice.key.name,
              formatValue(mine.value, mine.key),
            ),
      chosen: mine != null,
      onPressed: () => context.go('$base/eigenschaft/$keyId'),
    );
  }
}
