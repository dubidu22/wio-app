import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../l10n/app_localizations.dart';
import '../shell/layout.dart';
import 'note_format.dart';
import 'note_player.dart';
import 'notes_providers.dart';

/// The **Notizen** section of a room, customer or picture screen (D-298):
/// one card per note, oldest first, then **Notiz schreiben** (D-304).
/// [base] is the address of the screen; notes open under
/// `<base>/notizen/<id>`. Playback stops when the section goes away or the
/// app goes to the background (D-301).
class NotesSection extends ConsumerStatefulWidget {
  const NotesSection({required this.subject, required this.base, super.key});

  final NoteSubject subject;
  final String base;

  @override
  ConsumerState<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends ConsumerState<NotesSection> {
  late final NotePlayer _player;
  final Set<String> _ids = <String>{};
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _player = ref.read(notePlayerProvider);
    _lifecycle = AppLifecycleListener(
      onPause: () => stopIfPlaying(_player, _ids),
      onHide: () => stopIfPlaying(_player, _ids),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    stopIfPlaying(_player, _ids);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notes = ref.watch(notesProvider(widget.subject));
    final write = Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
        onPressed: () => context.go('${widget.base}/notizen/neu'),
        child: Text(l10n.notesWrite),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SectionHeading(l10n.notesHeading),
        switch (notes) {
          AsyncData(value: final List<Note> list) when list.isEmpty => HintText(
            l10n.notesEmpty,
          ),
          AsyncData(value: final List<Note> list) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final note in _remember(list))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NoteCard(
                    note: note,
                    location: '${widget.base}/notizen/${note.id}',
                  ),
                ),
            ],
          ),
          AsyncError(:final error) => LoadFailed(
            message: l10n.loadFailed,
            error: error,
          ),
          _ => const SizedBox.shrink(),
        },
        write,
      ],
    );
  }

  List<Note> _remember(List<Note> notes) {
    _ids
      ..clear()
      ..addAll(notes.map((n) => n.id));
    return notes;
  }
}

/// Stops [player] when one of [ids] plays (D-301).
void stopIfPlaying(NotePlayer player, Iterable<String> ids) {
  final playing = player.playback.value.noteId;
  if (playing != null && ids.contains(playing)) unawaited(player.stop());
}

/// One note: time and length, up to four lines of text (D-308), then
/// **Abspielen** and **Öffnen** (D-299).
class NoteCard extends StatelessWidget {
  const NoteCard({required this.note, required this.location, super.key});

  final Note note;
  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final line = noteLine(l10n, note);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: NotePlayControl(
          note: note,
          builder: (context, play) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(play.line ?? line, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                noteBody(l10n, note),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
              ?play.hint,
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  if (play.button != null) ...<Widget>[
                    Expanded(child: play.button!),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () => context.go(location),
                      child: Text(
                        l10n.noteOpen,
                        semanticsLabel: l10n.noteOpenLabel(line),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What [NotePlayControl] hands its builder: the time line while playing,
/// a plain hint, and **Abspielen** / **Stopp** where it can play.
typedef NotePlayParts = ({String? line, Widget? hint, Widget? button});

/// Playback of one note (D-300, D-301, D-305): **Abspielen**, which turns
/// into **Stopp** with "Läuft · 0:12 / 0:45" while it plays; for a
/// recording not on the device, or a build without a player, a plain hint
/// and no button (D-75). Text notes get nothing.
class NotePlayControl extends ConsumerWidget {
  const NotePlayControl({required this.note, required this.builder, super.key});

  final Note note;
  final Widget Function(BuildContext context, NotePlayParts parts) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sha = note.audioSha256;
    if (sha == null) {
      return builder(context, (line: null, hint: null, button: null));
    }
    final l10n = AppLocalizations.of(context);
    final path = ref.watch(noteAudioProvider(sha));
    if (path == null) {
      return builder(context, (
        line: null,
        hint: HintText(l10n.noteNotOnDevice),
        button: null,
      ));
    }
    if (!ref.watch(canPlayNotesProvider)) {
      return builder(context, (
        line: null,
        hint: HintText(l10n.noteCannotPlay),
        button: null,
      ));
    }
    // The note's time names it for screen readers (UX rule 1).
    final line = noteLine(l10n, note);
    final player = ref.watch(notePlayerProvider);
    return ValueListenableBuilder<NotePlayback>(
      valueListenable: player.playback,
      builder: (context, playback, _) {
        final playing = playback.noteId == note.id;
        final length = Duration(seconds: note.audioSeconds ?? 0);
        final Widget button = playing
            ? FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: player.stop,
                child: Text(
                  l10n.noteStop,
                  semanticsLabel: l10n.noteStopLabel(line),
                ),
              )
            : OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () => player.play(note.id, path),
                child: Text(
                  l10n.notePlay,
                  semanticsLabel: l10n.notePlayLabel(line),
                ),
              );
        return builder(context, (
          line: playing
              ? l10n.notePlayingLine(
                  noteClock(playback.position),
                  noteClock(length),
                )
              : null,
          hint: playback.failed == note.id
              ? HintText(l10n.notePlayFailed)
              : null,
          button: button,
        ));
      },
    );
  }
}

/// The note screen's playback (D-300): the time line, a hint where it
/// cannot play, and **Abspielen** / **Stopp** at full width.
class NotePlayControlColumn extends StatelessWidget {
  const NotePlayControlColumn({required this.note, super.key});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return NotePlayControl(
      note: note,
      builder: (context, play) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(play.line ?? noteLine(l10n, note), style: textTheme.bodyLarge),
          ?play.hint,
          if (play.button != null) ...<Widget>[
            const SizedBox(height: 8),
            play.button!,
          ],
        ],
      ),
    );
  }
}

/// Stops a playing note once the screen around it opened (D-301): go_router
/// keeps the screen below mounted, so its cards do not stop by themselves.
/// [keep] is a note that may go on playing (the note screen's own note).
class StopNotesOnOpen extends ConsumerStatefulWidget {
  const StopNotesOnOpen({required this.child, this.keep, super.key});

  final Widget child;
  final String? keep;

  @override
  ConsumerState<StopNotesOnOpen> createState() => _StopNotesOnOpenState();
}

class _StopNotesOnOpenState extends ConsumerState<StopNotesOnOpen> {
  @override
  void initState() {
    super.initState();
    final player = ref.read(notePlayerProvider);
    // After this frame: the cards below listen to the player.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playing = player.playback.value.noteId;
      if (playing != null && playing != widget.keep) unawaited(player.stop());
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
