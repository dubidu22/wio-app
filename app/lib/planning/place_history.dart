import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/entry_queries.dart';
import '../l10n/app_localizations.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'place_providers.dart';
import 'place_words.dart';

/// One move spoken: "Von Küche, Boden nach Wohnzimmer, Boden, Do. 19.11.,
/// 09:05". The first placement starts at "Noch nicht abgelegt" (D-425); a
/// room that was deleted reads "Raum gelöscht".
String placeStepSpoken(
  AppLocalizations l10n,
  PlaceStep step,
  DateTime now, {
  required bool Function(String roomId) isLiveRoom,
  required String? Function(String roomId) roomName,
}) => l10n.placeHistoryStepSemantics(
  placeWords(l10n, step.from, isLiveRoom: isLiveRoom, roomName: roomName),
  placeWords(l10n, step.to, isLiveRoom: isLiveRoom, roomName: roomName),
  placeStepTime(l10n, step, now),
);

/// When the move happened, in the device's time zone; the year only when it
/// is not the current one. A move the server has not confirmed says
/// "wird gesendet": the device time is never shown (D-440).
String placeStepTime(AppLocalizations l10n, PlaceStep step, DateTime now) {
  if (step.pending) return l10n.placeHistoryPending;
  final moved = DateTime.tryParse(step.movedAt)?.toLocal();
  if (moved == null) return l10n.placeHistoryPending;
  return moved.year == now.toLocal().year
      ? l10n.placeHistoryTime(moved)
      : l10n.placeHistoryTimeYear(moved);
}

/// The section **Verlauf** of the entry screen: every place the entry had,
/// newest first, one row per move (plan 108). Read only: no button and no
/// gesture, the history is append-only (D-54).
class PlaceHistorySection extends ConsumerWidget {
  const PlaceHistorySection({
    required this.customerId,
    required this.entryId,
    super.key,
  });

  final String customerId;
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steps = ref.watch(placeHistoryProvider(entryId));
    final choices = ref
        .watch(placeChoicesProvider((customerId: customerId, entryId: entryId)))
        .value;
    final now = ref.watch(clockProvider)();
    bool isLive(String id) => choices?.room(id) != null;
    String? nameOf(String id) => choices?.room(id)?.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeading(l10n.placeHistoryTitle),
        switch (steps) {
          AsyncData(value: final List<PlaceStep> list) =>
            list.isEmpty
                ? HintText(l10n.placeHistoryEmpty)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final step in list)
                        _StepRow(
                          from: placeWords(
                            l10n,
                            step.from,
                            isLiveRoom: isLive,
                            roomName: nameOf,
                          ),
                          to: placeWords(
                            l10n,
                            step.to,
                            isLiveRoom: isLive,
                            roomName: nameOf,
                          ),
                          when: placeStepTime(l10n, step, now),
                          spoken: placeStepSpoken(
                            l10n,
                            step,
                            now,
                            isLiveRoom: isLive,
                            roomName: nameOf,
                          ),
                        ),
                    ],
                  ),
          AsyncError() => HintText(l10n.loadFailed),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.from,
    required this.to,
    required this.when,
    required this.spoken,
  });

  final String from;
  final String to;
  final String when;
  final String spoken;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Semantics(
        container: true,
        label: spoken,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // The arrow is drawn, not typed: not every font has it.
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: <Widget>[
                  Text(from, style: textTheme.bodyLarge),
                  const Icon(Icons.arrow_forward, size: 18),
                  Text(to, style: textTheme.bodyLarge),
                ],
              ),
              Text(when, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
