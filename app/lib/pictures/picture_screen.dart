import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../camera/camera_providers.dart';
import '../data/database.dart';
import '../l10n/app_localizations.dart';
import '../media/local_picture.dart';
import '../media/media_store.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'picture_tile.dart';

/// How long "Rückgängig" stays after "Löschen" (UX rule 9).
const Duration undoTime = Duration(seconds: 8);

/// Width of the before and after tiles under the picture (D-280).
const double _relatedTileWidth = 140;

/// One picture, full screen (D-259). Part of the level-3 task it was opened
/// from: "Zurück" returns to the room or the customer (D-261).
///
/// Main button "Nachher aufnehmen" opens the after camera (D-276, not on
/// the web, D-283); "Löschen" deletes at once with "Rückgängig" (D-278).
/// Its after pictures, or its before picture, are tiles under it with a
/// word (D-280). Pinch zoom is a view aid only (D-279). "Sprechen" comes
/// with the voice note (#60, D-75).
class PictureScreen extends ConsumerWidget {
  const PictureScreen({
    required this.customerId,
    required this.pictureId,
    this.roomId,
    super.key,
  });

  final String customerId;

  /// The room it was opened from; null for a picture without a room.
  final String? roomId;
  final String pictureId;

  /// The room's or customer's screen this picture belongs to.
  String get _base => roomId == null
      ? '/customers/$customerId'
      : '/customers/$customerId/rooms/$roomId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final picture = ref.watch(
      pictureProvider((
        customerId: customerId,
        roomId: roomId,
        pictureId: pictureId,
      )),
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(l10n.pictureTitle),
      ),
      body: switch (picture) {
        AsyncData(value: final Picture value) => _PictureBody(
          picture: value,
          base: _base,
        ),
        AsyncData() => ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HintText(l10n.pictureMissing),
          ),
        ),
        AsyncError(:final error) => LoadFailed(
          message: l10n.loadFailed,
          error: error,
        ),
        _ => const SizedBox.shrink(),
      },
      bottomNavigationBar: switch (picture) {
        AsyncData(value: final Picture value) => _PictureButtons(
          picture: value,
          base: _base,
        ),
        _ => null,
      },
    );
  }
}

/// "Löschen" and the main button "Nachher aufnehmen" (UX rule 3).
class _PictureButtons extends ConsumerStatefulWidget {
  const _PictureButtons({required this.picture, required this.base});

  final Picture picture;
  final String base;

  @override
  ConsumerState<_PictureButtons> createState() => _PictureButtonsState();
}

class _PictureButtonsState extends ConsumerState<_PictureButtons> {
  /// A second press while the first delete runs does nothing (PR 72 S1).
  bool _deleting = false;

  Picture get picture => widget.picture;
  String get base => widget.base;

  Future<void> _delete() async {
    if (_deleting) return;
    _deleting = true;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final writer = ref.read(mediaWriterProvider);
    final id = picture.id;
    try {
      await writer.deletePicture(id);
    } on Object {
      if (mounted) _deleting = false;
      rethrow;
    }
    router.go(base);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.pictureDeleted),
        // UX rule 9: the note goes by itself; an action would otherwise
        // keep it on screen.
        duration: undoTime,
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => writer.restorePicture(id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canTake = ref.watch(canTakePicturesProvider);
    final delete = OutlinedButton(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
      onPressed: _delete,
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.pictureDelete)),
    );
    return SafeArea(
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: wioMaxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: <Widget>[
                Expanded(child: delete),
                if (canTake) ...<Widget>[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                      ),
                      onPressed: () =>
                          context.go('$base/pictures/${picture.id}/nachher'),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.pictureTakeAfter),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PictureBody extends ConsumerWidget {
  const _PictureBody({required this.picture, required this.base});

  final Picture picture;
  final String base;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final folder = ref.watch(mediaFolderProvider);
    if (folder.isLoading && !folder.hasValue) {
      // No hint until the folder is known (rule 7).
      return const SizedBox.shrink();
    }
    // Full size (at most 2560 px, D-219), so zooming stays sharp (D-279).
    final image = localPicture(folder.value, picture.fileSha256);
    final words = <Widget>[
      Text(pictureTime(l10n, picture), style: textTheme.bodyLarge),
      if (picture.afterOf != null)
        Text(l10n.pictureAfter, style: textTheme.bodyLarge),
    ];
    final related = _Related(picture: picture, base: base);
    if (image == null) {
      return ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            HintText(l10n.pictureNotOnDevice),
            ...words,
            related,
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ClipRect(
            child: InteractiveViewer(
              maxScale: 4,
              child: Image(
                image: image,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                semanticLabel: l10n.pictureTitle,
                errorBuilder: (context, error, stack) =>
                    Center(child: HintText(l10n.pictureNotOnDevice)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: words,
          ),
        ),
        related,
      ],
    );
  }
}

/// The picture's after pictures under "Nachher", or for an after picture
/// its before picture under "Vorher", as tiles with "Öffnen" (D-280). A
/// deleted before picture is left out; the after picture stays (D-278).
class _Related extends ConsumerWidget {
  const _Related({required this.picture, required this.base});

  final Picture picture;
  final String base;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final customerId = picture.customerId;
    if (customerId == null) return const SizedBox.shrink();
    final beforeId = picture.afterOf;
    final List<Picture> tiles;
    final String heading;
    if (beforeId != null) {
      final before = ref
          .watch(
            pictureProvider((
              customerId: customerId,
              roomId: null,
              pictureId: beforeId,
            )),
          )
          .value;
      tiles = <Picture>[?before];
      heading = l10n.pictureBefore;
    } else {
      tiles =
          ref
              .watch(
                afterPicturesProvider((
                  customerId: customerId,
                  pictureId: picture.id,
                )),
              )
              .value ??
          const <Picture>[];
      heading = l10n.pictureAfterPictures;
    }
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              heading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final (index, tile) in tiles.indexed) ...<Widget>[
                  if (index > 0) const SizedBox(width: 12),
                  SizedBox(
                    width: _relatedTileWidth,
                    child: PictureTile(
                      picture: tile,
                      width: _relatedTileWidth,
                      location: '$base/pictures/${tile.id}',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
