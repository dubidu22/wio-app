import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/entry_queries.dart';
import '../data/entry_writer.dart';
import '../l10n/app_localizations.dart';
import '../media/local_picture.dart';
import '../media/media_presence.dart';
import '../media/media_store.dart';
import '../planning/place_screen.dart' show entryLocation;
import '../planning/place_words.dart';
import '../shell/layout.dart';

/// Side of an entry's thumbnail in a list.
const double _thumbSize = 72;

/// The widgets of an entry list (plan 105) for the children of a screen's
/// own `ListView`, so rows are built only while they scroll into view
/// (P6): a hint while there are none, else the hint for entries without a
/// place (UX rule 7) and one [EntryRow] each. While the list loads there is
/// nothing, as for the picture grids.
List<Widget> entryListChildren(
  BuildContext context, {
  required AsyncValue<EntryList> entries,
  required String customerId,
  required String emptyText,
}) {
  final l10n = AppLocalizations.of(context);
  return switch (entries) {
    AsyncData(value: final EntryList list) when list.rows.isEmpty => <Widget>[
      HintText(emptyText),
    ],
    AsyncData(value: final EntryList list) => <Widget>[
      if (list.unplaced > 0) HintText(l10n.entryListUnplaced(list.unplaced)),
      for (final row in list.rows)
        EntryRow(customerId: customerId, row: row, list: list),
    ],
    AsyncError(:final error) => <Widget>[
      LoadFailed(message: l10n.loadFailed, error: error),
    ],
    _ => const <Widget>[],
  };
}

/// One entry in a list: a full-width button of at least 72 px (UX rules 1
/// and 3) with the thumbnail of its first picture, its name, its place in
/// words and its labels by name (plan 105, P1). A tap opens the entry on
/// top of the screen it was tapped on, so Back returns there (P7).
class EntryRow extends ConsumerWidget {
  const EntryRow({
    required this.customerId,
    required this.row,
    required this.list,
    super.key,
  });

  final String customerId;
  final EntryListRow row;
  final EntryList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final entry = row.entry;
    final place = placeWords(
      l10n,
      Place.of(entry),
      isLiveRoom: list.isLiveRoom,
      roomName: list.roomName,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(_thumbSize + 24),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(12),
        ),
        onPressed: () => context.push(entryLocation(customerId, entry.id)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExcludeSemantics(child: _Thumbnail(picture: row.picture)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(entryName(l10n, entry), style: textTheme.titleMedium),
                  Text(place, style: textTheme.bodyLarge),
                  if (row.labels.isNotEmpty)
                    Text(
                      l10n.entryListLabels(row.labels.join(', ')),
                      style: textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The entry's first picture, square; an empty frame when it has none or its
/// file is not on this device (yet). Watching the file's state asks the
/// downloads for it only while the row is on screen (D-328).
class _Thumbnail extends ConsumerWidget {
  const _Thumbnail({required this.picture});

  final Picture? picture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final frame = ColoredBox(color: theme.colorScheme.surfaceContainerHighest);
    final sha = picture?.fileSha256;
    ImageProvider? image;
    if (sha != null &&
        ref.watch(mediaFileProvider(sha)) == MediaFileState.present) {
      final pixels = (_thumbSize * MediaQuery.devicePixelRatioOf(context))
          .round();
      image = localPicture(
        ref.watch(mediaStoreProvider),
        ref.watch(mediaFolderProvider).value,
        sha,
        cacheWidth: pixels,
      );
    }
    return SizedBox.square(
      dimension: _thumbSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: image == null
            ? frame
            : Image(
                image: image,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stack) => frame,
              ),
      ),
    );
  }
}
