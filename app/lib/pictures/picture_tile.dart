import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import '../media/local_picture.dart';
import '../media/media_presence.dart';
import '../media/media_store.dart';

/// Space between picture tiles.
const double _gap = 12;

/// Narrowest a picture tile gets; a phone shows two per row.
const double _minTileWidth = 150;

/// When [picture] was taken, in the device's time, as shown under it.
String pictureTime(AppLocalizations l10n, Picture picture) {
  final taken = picture.takenAt ?? picture.createdAt;
  final time = taken == null ? null : DateTime.tryParse(taken);
  return time == null
      ? l10n.pictureNoTime
      : l10n.pictureTakenAt(time.toLocal());
}

/// Pictures as a grid of tiles, oldest first, each after picture right
/// behind its before picture (D-259, D-281). [locationOf] is the
/// address of the picture screen for one picture.
class PictureGrid extends StatelessWidget {
  const PictureGrid({
    required this.pictures,
    required this.locationOf,
    super.key,
  });

  final List<Picture> pictures;
  final String Function(Picture picture) locationOf;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + _gap) / (_minTileWidth + _gap))
            .floor()
            .clamp(1, 6);
        final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: <Widget>[
            for (final picture in withAfterPicturesBehind(pictures))
              SizedBox(
                width: width,
                child: PictureTile(
                  picture: picture,
                  width: width,
                  location: locationOf(picture),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// One picture: a button with its thumbnail, time and the word "Öffnen"
/// (UX rule 1, D-259). A picture whose file is not on this device is a
/// plain text tile without "Öffnen" (D-260), saying "Foto wird geladen."
/// while it comes in (D-333); the tile turns into the picture when it lands
/// (D-332). While the media folder is not listed yet, the tile shows an
/// empty frame and the time only.
class PictureTile extends ConsumerWidget {
  const PictureTile({
    required this.picture,
    required this.width,
    required this.location,
    super.key,
  });

  final Picture picture;
  final double width;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(mediaFileProvider(picture.fileSha256));
    final pixels = (width * MediaQuery.devicePixelRatioOf(context)).round();
    final image = state == MediaFileState.present
        ? localPicture(
            ref.watch(mediaStoreProvider),
            ref.watch(mediaFolderProvider).value,
            picture.fileSha256,
            cacheWidth: pixels,
          )
        : null;
    final time = pictureTime(l10n, picture);
    final words = <Widget>[
      Text(time, style: theme.textTheme.bodyMedium),
      if (picture.afterOf != null)
        Text(l10n.pictureAfter, style: theme.textTheme.bodyMedium),
    ];
    if (state == MediaFileState.unknown) {
      // The folder is not listed yet: no hint that may be wrong (rule 7).
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 6),
              ...words,
            ],
          ),
        ),
      );
    }
    if (image == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                // "wird geladen" only while it comes in (D-333).
                state == MediaFileState.loading
                    ? l10n.pictureLoading
                    : l10n.pictureNotOnDevice,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              ...words,
            ],
          ),
        ),
      );
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(56, 56),
        alignment: Alignment.topLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => context.go(location),
      child: Semantics(
        label: l10n.pictureOpenLabel(time),
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image(
                  image: image,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stack) => Center(
                    child: Text(
                      l10n.pictureNotOnDevice,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            ...words,
            Text(l10n.pictureOpen, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
