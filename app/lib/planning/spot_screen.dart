import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import 'place_choices.dart';
import 'place_providers.dart';
import 'place_screen.dart';
import 'place_words.dart';

/// The spot step of the place picker (plan 107, D-451, D-452): where in
/// room [roomId] the entry goes. In M3 the only spot is "Boden" (D-450);
/// M4 lists the room's fixtures here and offers a point on the floor.
class SpotScreen extends ConsumerWidget {
  const SpotScreen({
    required this.customerId,
    required this.entryId,
    required this.roomId,
    super.key,
  });

  final String customerId;
  final String entryId;
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final choices = ref.watch(
      placeChoicesProvider((customerId: customerId, entryId: entryId)),
    );
    final room = switch (choices) {
      AsyncData(value: final PlaceChoices c) => c.room(roomId),
      _ => null,
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(room == null ? '' : room.name ?? l10n.unnamedRoom),
      ),
      body: switch (choices) {
        AsyncData(value: final PlaceChoices c) when room != null =>
          ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: <Widget>[
                Text(
                  entryName(l10n, c.entry),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                PickButton(
                  label: l10n.placeFloor,
                  marks: <String>[if (c.place == room.floor) l10n.placeHere],
                  current: c.place == room.floor,
                  onPressed: () => pick(
                    context,
                    ref,
                    customerId: customerId,
                    entryId: entryId,
                    mode: PickMode.place,
                    place: room.floor,
                  ),
                ),
              ],
            ),
          ),
        AsyncData(value: final PlaceChoices? c) => ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HintText(c == null ? l10n.entryMissing : l10n.roomMissing),
          ),
        ),
        AsyncError(:final error) => LoadFailed(
          message: l10n.loadFailed,
          error: error,
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
