import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../camera/take_pictures_button.dart';
import '../data/database.dart';
import '../data/entry_writer.dart';
import '../l10n/app_localizations.dart';
import '../notes/notes_section.dart';
import '../pictures/picture_screen.dart' show undoTime;
import '../pictures/picture_tile.dart';
import '../planning/place_choices.dart';
import '../planning/place_history.dart';
import '../planning/place_providers.dart';
import '../planning/place_screen.dart' show entryLocation;
import '../planning/place_words.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';

/// Level 3: one entry (KB workflows.md, plan 103). Shows its name and code,
/// **Titel ändern**, its pictures (each opens the picture view under the
/// entry), its notes, the place with **Ort ändern**, the target with
/// **Ziel**, the place history **Verlauf** (plan 108) and **Löschen** with
/// **Rückgängig** (UX rule 9). The main button is **Fotos**, **Sprechen**
/// sits beside it (D-295).
class EntryScreen extends ConsumerWidget {
  const EntryScreen({
    required this.customerId,
    required this.entryId,
    super.key,
  });

  final String customerId;
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The entry's own live row gives name, code, place and target. The
    // place choices only name the rooms here. They once missed changes made
    // on the screens above this one (issue 115, fixed in watchReads); the
    // entry's own row stays the source of the entry's fields.
    final entry = ref.watch(entryProvider(entryId));
    final choices = ref.watch(
      placeChoicesProvider((customerId: customerId, entryId: entryId)),
    );
    final base = entryLocation(customerId, entryId);
    final Entry? found = entry.value;
    final PlaceChoices? rooms = choices.value;
    // An entry of another customer is not this customer's (as the pickers).
    final present = found != null && found.customerId == customerId;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(l10n.entryTitle),
      ),
      body: switch ((entry, choices)) {
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          LoadFailed(message: l10n.loadFailed, error: error),
        (AsyncData(), AsyncData()) when !present => ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HintText(l10n.entryMissing),
          ),
        ),
        _ when present && rooms != null => _EntryBody(
          customerId: customerId,
          entry: found,
          rooms: rooms,
        ),
        _ => const SizedBox.shrink(),
      },
      bottomNavigationBar: present && rooms != null
          ? TakePicturesBar(
              cameraLocation: '$base/kamera',
              speakLocation: '$base/sprechen',
            )
          : null,
    );
  }
}

class _EntryBody extends ConsumerWidget {
  const _EntryBody({
    required this.customerId,
    required this.entry,
    required this.rooms,
  });

  final String customerId;
  final Entry entry;
  final PlaceChoices rooms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final base = entryLocation(customerId, entry.id);
    final pictures = ref.watch(entryPicturesProvider(entry.id));
    bool isLive(String id) => rooms.room(id) != null;
    String? nameOf(String id) => rooms.room(id)?.name;
    final code = entry.code;
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Text(entryName(l10n, entry), style: textTheme.headlineSmall),
          if (code != null && code.isNotEmpty)
            Text(l10n.entryCode(code), style: textTheme.bodyLarge),
          _ActionButton(
            label: l10n.entryChangeTitle,
            location: '$base/titel',
            top: 12,
          ),
          SectionHeading(l10n.entryPictures),
          switch (pictures) {
            AsyncData(value: final List<Picture> list) when list.isEmpty =>
              HintText(l10n.entryPicturesEmpty),
            AsyncData(value: final List<Picture> list) => PictureGrid(
              pictures: list,
              locationOf: (picture) => '$base/pictures/${picture.id}',
            ),
            AsyncError(:final error) => LoadFailed(
              message: l10n.loadFailed,
              error: error,
            ),
            _ => const SizedBox.shrink(),
          },
          NotesSection(subject: (type: 'entry', id: entry.id), base: base),
          SectionHeading(l10n.entryPlaceHeading),
          Text(
            placeWords(
              l10n,
              Place.of(entry),
              isLiveRoom: isLive,
              roomName: nameOf,
            ),
            style: textTheme.titleMedium,
          ),
          _ActionButton(label: l10n.placeTitle, location: '$base/ort', top: 8),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              targetWords(
                l10n,
                Place.targetOf(entry),
                isLiveRoom: isLive,
                roomName: nameOf,
              ),
              style: textTheme.titleMedium,
            ),
          ),
          _ActionButton(
            label: l10n.targetTitle,
            location: '$base/ziel',
            top: 8,
          ),
          PlaceHistorySection(customerId: customerId, entryId: entry.id),
          _DeleteButton(customerId: customerId, entryId: entry.id),
        ],
      ),
    );
  }
}

/// A full-width outlined button of 64 px that opens [location] (UX rules 1
/// and 3).
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.location,
    required this.top,
  });

  final String label;
  final String location;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
        onPressed: () => context.go(location),
        child: Text(label),
      ),
    );
  }
}

/// **Löschen**: deletes at once, goes to the customer and offers
/// **Rückgängig** for 8 seconds (UX rule 9, plan 103). A second press while
/// the first delete runs does nothing.
class _DeleteButton extends ConsumerStatefulWidget {
  const _DeleteButton({required this.customerId, required this.entryId});

  final String customerId;
  final String entryId;

  @override
  ConsumerState<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends ConsumerState<_DeleteButton> {
  bool _deleting = false;

  Future<void> _delete() async {
    if (_deleting) return;
    _deleting = true;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final writer = ref.read(entryWriterProvider);
    final id = widget.entryId;
    try {
      await writer.deleteEntry(id);
    } on Object {
      if (mounted) _deleting = false;
      rethrow;
    }
    router.go('/customers/${widget.customerId}');
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.entryDeleted),
        // UX rule 9: the note goes by itself; an action would otherwise
        // keep it on screen.
        duration: undoTime,
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            try {
              await writer.restoreEntry(id);
            } on DuplicateCode {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.entryUndoFailed)),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
        onPressed: _delete,
        child: Text(l10n.entryDelete),
      ),
    );
  }
}
