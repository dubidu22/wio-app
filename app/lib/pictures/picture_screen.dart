import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../l10n/app_localizations.dart';
import '../media/local_picture.dart';
import '../media/media_store.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'picture_tile.dart';

/// One picture, full screen (D-259). Part of the level-3 task it was opened
/// from: "Zurück" returns to the room or the customer (D-261). The buttons
/// "Nachher aufnehmen", "Notiz" and "Löschen" and the overlay come with #59;
/// they go into the Scaffold's bottomNavigationBar here.
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
        AsyncData(value: final Picture value) => _PictureBody(picture: value),
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
    );
  }
}

class _PictureBody extends ConsumerWidget {
  const _PictureBody({required this.picture});

  final Picture picture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final folder = ref.watch(mediaFolderProvider).value;
    final size = MediaQuery.sizeOf(context);
    final image = localPicture(
      folder,
      picture.fileSha256,
      cacheWidth: (size.width * MediaQuery.devicePixelRatioOf(context)).round(),
    );
    final words = <Widget>[
      Text(pictureTime(l10n, picture), style: textTheme.bodyLarge),
      if (picture.afterOf != null)
        Text(l10n.pictureAfter, style: textTheme.bodyLarge),
    ];
    if (image == null) {
      return ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[HintText(l10n.pictureNotOnDevice), ...words],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Image(
            image: image,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            semanticLabel: l10n.pictureTitle,
            errorBuilder: (context, error, stack) =>
                Center(child: HintText(l10n.pictureNotOnDevice)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: words,
          ),
        ),
      ],
    );
  }
}
