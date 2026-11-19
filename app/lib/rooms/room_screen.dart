import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import '../pictures/picture_tile.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';

/// Level 3: one room with its pictures (KB workflows.md "Take pictures of a
/// room", D-259). The main button "Fotos" comes with the camera (#58,
/// D-258): it goes into the Scaffold's bottomNavigationBar here; notes of
/// the room come with #61.
class RoomScreen extends ConsumerWidget {
  const RoomScreen({required this.customerId, required this.roomId, super.key});

  final String customerId;
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final room = ref.watch(roomProvider((customerId: customerId, id: roomId)));
    final title = switch (room) {
      AsyncData(value: final RoomScreenView view) =>
        view.name ?? l10n.unnamedRoom,
      _ => '',
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(title),
      ),
      body: switch (room) {
        AsyncData(value: final RoomScreenView view) => _RoomBody(
          customerId: customerId,
          view: view,
        ),
        AsyncData() => ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HintText(l10n.roomMissing),
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

class _RoomBody extends ConsumerWidget {
  const _RoomBody({required this.customerId, required this.view});

  final String customerId;
  final RoomScreenView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final pictures = ref.watch(roomPicturesProvider(view.id));
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              view.siteName ?? l10n.unnamedSite,
              style: textTheme.bodyLarge,
            ),
          ),
          SectionHeading(l10n.roomPictures),
          switch (pictures) {
            AsyncData(value: final List<Picture> list) when list.isEmpty =>
              HintText(l10n.roomPicturesEmpty),
            AsyncData(value: final List<Picture> list) => PictureGrid(
              pictures: list,
              locationOf: (picture) =>
                  '/customers/$customerId/rooms/${view.id}'
                  '/pictures/${picture.id}',
            ),
            AsyncError(:final error) => LoadFailed(
              message: l10n.loadFailed,
              error: error,
            ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}
