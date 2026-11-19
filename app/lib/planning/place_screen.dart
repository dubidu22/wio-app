import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/entry_writer.dart';
import '../l10n/app_localizations.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'place_choices.dart';
import 'place_providers.dart';
import 'place_words.dart';

/// Whether the room list sets the entry's place or its target (D-452).
enum PickMode { place, target }

/// Where the entry screen of [customerId]'s entry [entryId] is (D-451).
String entryLocation(String customerId, String entryId) =>
    '/customers/$customerId/entries/$entryId';

/// Part of the entry task (D-451): the customer's sites with their rooms as
/// big buttons (plan 107, UX rules 1 and 3). In [PickMode.place] a room
/// opens the spot step ("Boden", [SpotScreen]); in [PickMode.target] a room
/// is the target at once. The bottom button clears the place or target.
/// The current room and the target room carry words, not only a colour
/// (D-455).
class PlaceScreen extends ConsumerWidget {
  const PlaceScreen({
    required this.customerId,
    required this.entryId,
    required this.mode,
    super.key,
  });

  final String customerId;
  final String entryId;
  final PickMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final choices = ref.watch(
      placeChoicesProvider((customerId: customerId, entryId: entryId)),
    );
    final current = switch (choices) {
      AsyncData(value: final PlaceChoices c) =>
        mode == PickMode.place ? c.place : c.target,
      _ => Place.none,
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(
          mode == PickMode.place ? l10n.placeTitle : l10n.targetTitle,
        ),
      ),
      body: switch (choices) {
        AsyncData(value: final PlaceChoices c) => _RoomList(
          customerId: customerId,
          choices: c,
          mode: mode,
        ),
        AsyncData() => ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HintText(l10n.entryMissing),
          ),
        ),
        AsyncError(:final error) => LoadFailed(
          message: l10n.loadFailed,
          error: error,
        ),
        _ => const SizedBox.shrink(),
      },
      bottomNavigationBar: current.isNone
          ? null
          : _ClearBar(customerId: customerId, entryId: entryId, mode: mode),
    );
  }
}

class _RoomList extends ConsumerWidget {
  const _RoomList({
    required this.customerId,
    required this.choices,
    required this.mode,
  });

  final String customerId;
  final PlaceChoices choices;
  final PickMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final entry = choices.entry;
    bool isLive(String id) => choices.room(id) != null;
    String? nameOf(String id) => choices.room(id)?.name;
    final now = mode == PickMode.place
        ? placeWords(l10n, choices.place, isLiveRoom: isLive, roomName: nameOf)
        : switch (choices.target.roomId) {
            null => l10n.targetNone,
            final id when !isLive(id) => l10n.placeRoomDeleted,
            final id => nameOf(id) ?? l10n.unnamedRoom,
          };
    final sites = mode == PickMode.place
        ? choices.sitesTargetFirst
        : choices.sites;
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Text(entryName(l10n, entry), style: textTheme.titleLarge),
          Text(l10n.placeNow(now), style: textTheme.bodyLarge),
          if (sites.isEmpty) HintText(l10n.customerSitesEmpty),
          for (final site in sites) ...<Widget>[
            SectionHeading(site.name ?? l10n.unnamedSite),
            if (site.address != null)
              Text(site.address!, style: textTheme.bodyMedium),
            if (site.rooms.isEmpty) HintText(l10n.siteRoomsEmpty),
            for (final room in site.rooms)
              PickButton(
                label: room.name ?? l10n.unnamedRoom,
                marks: <String>[
                  if (mode == PickMode.place && choices.place.roomId == room.id)
                    l10n.placeHere,
                  if (mode == PickMode.target &&
                      choices.target.roomId == room.id)
                    l10n.targetHere,
                  if (mode == PickMode.place &&
                      choices.target.roomId == room.id)
                    l10n.placeTargetMark,
                ],
                current: mode == PickMode.place
                    ? choices.place.roomId == room.id
                    : choices.target.roomId == room.id,
                onPressed: () => mode == PickMode.place
                    ? context.go(
                        '${entryLocation(customerId, entry.id)}/ort/${room.id}',
                      )
                    : pick(
                        context,
                        ref,
                        customerId: customerId,
                        entryId: entry.id,
                        mode: PickMode.target,
                        place: room.floor,
                      ),
              ),
          ],
        ],
      ),
    );
  }
}

/// "Nicht abgelegt" or "Kein Ziel" at the bottom, shown only when there is
/// something to clear (plan 107). Not a filled main button: the rooms are
/// the choice.
class _ClearBar extends ConsumerWidget {
  const _ClearBar({
    required this.customerId,
    required this.entryId,
    required this.mode,
  });

  final String customerId;
  final String entryId;
  final PickMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: wioMaxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
              ),
              onPressed: () => pick(
                context,
                ref,
                customerId: customerId,
                entryId: entryId,
                mode: mode,
                place: Place.none,
              ),
              child: Text(
                mode == PickMode.place ? l10n.placeClear : l10n.targetClear,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Writes [place] as the entry's place (one `move_entry`) or target (one
/// `upsert` of the seven `target_*` fields), then goes back to the entry
/// (D-452, D-453). The current place or target writes nothing (D-454; the
/// writer skips it). A room deleted meanwhile shows a plain hint.
Future<void> pick(
  BuildContext context,
  WidgetRef ref, {
  required String customerId,
  required String entryId,
  required PickMode mode,
  required Place place,
}) async {
  final writer = ref.read(entryWriterProvider);
  final messenger = ScaffoldMessenger.of(context);
  final failed = AppLocalizations.of(context).placeFailed;
  try {
    if (mode == PickMode.place) {
      await writer.move(entryId, place);
    } else {
      await writer.setTarget(entryId, place);
    }
  } on ArgumentError {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
    return;
  }
  if (context.mounted) context.go(entryLocation(customerId, entryId));
}

/// A full-width button of at least 72 px with a name and the words that
/// mark it (D-455), like the customer screen's room buttons (D-259). The
/// current choice also gets a thicker border, which only supports the
/// words (D-5).
class PickButton extends StatelessWidget {
  const PickButton({
    required this.label,
    required this.onPressed,
    this.marks = const <String>[],
    this.current = false,
    super.key,
  });

  final String label;
  final List<String> marks;
  final bool current;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(72),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: current
              ? BorderSide(color: theme.colorScheme.primary, width: 3)
              : null,
        ),
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(label, style: theme.textTheme.titleLarge),
            if (marks.isNotEmpty)
              Text(marks.join(' · '), style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
