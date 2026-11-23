import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../camera/camera_providers.dart';
import '../data/database.dart';
import '../data/media_writer.dart';
import '../l10n/app_localizations.dart';
import '../pictures/picture_screen.dart' show undoTime;
import '../planning/place_screen.dart' show entryLocation;
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'note_format.dart';
import 'note_player.dart';
import 'notes_providers.dart';
import 'notes_section.dart';

/// One note, part of the room, picture or customer task it was opened from
/// (D-299, as D-271). One optional field (D-302): the transcript of a voice
/// note or the text of a text note, saved on **Fertig**, back and the app
/// going to the background; nothing is required (UX rule 4, D-303).
/// **Löschen** deletes at once with **Rückgängig** (D-309). Without
/// [noteId] it is a new text note (D-304).
class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({
    required this.customerId,
    this.roomId,
    this.entryId,
    this.pictureId,
    this.noteId,
    super.key,
  });

  final String customerId;
  final String? roomId;

  /// The entry the note is about, or the entry the picture was opened
  /// from (plan 103).
  final String? entryId;
  final String? pictureId;

  /// The note to show; null for a new text note.
  final String? noteId;

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  late final MediaWriter _writer;
  late final WioDatabase _db;
  late final NotePlayer _player;
  // Kept while mounted: a save after back runs when the screen is gone.
  late ScaffoldMessengerState _messenger;
  late AppLocalizations _l10n;
  late final AppLifecycleListener _lifecycle;
  final TextEditingController _field = TextEditingController();

  /// Whether [_field] holds the note's text yet.
  bool _filled = false;

  /// Whether the note has a recording; its field is then the transcript.
  bool _voice = false;

  /// The id of the new note once it was saved (by the app going to the
  /// background, before Fertig).
  String? _created;
  bool _deleting = false;

  /// Saves run one after another, so a new note is added once.
  Future<void> _saves = Future<void>.value();

  String? get _id => widget.noteId ?? _created;

  /// The screen this note belongs to.
  String get _base {
    final customer = '/customers/${widget.customerId}';
    final room = widget.roomId;
    final entry = widget.entryId;
    final base = entry != null
        ? entryLocation(widget.customerId, entry)
        : room == null
        ? customer
        : '$customer/rooms/$room';
    final picture = widget.pictureId;
    return picture == null ? base : '$base/pictures/$picture';
  }

  @override
  void initState() {
    super.initState();
    _writer = ref.read(mediaWriterProvider);
    _db = ref.read(databaseProvider);
    _player = ref.read(notePlayerProvider);
    _lifecycle = AppLifecycleListener(
      onPause: _toBackground,
      onHide: _toBackground,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
    _l10n = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _stopPlaying();
    _field.dispose();
    super.dispose();
  }

  void _toBackground() {
    _stopPlaying();
    unawaited(_save());
  }

  void _stopPlaying() {
    final id = _id;
    if (id != null && _player.playback.value.noteId == id) {
      unawaited(_player.stop());
    }
  }

  Future<void> _save() {
    // The field's value now, not when an earlier save ends.
    final value = _field.text;
    return _saves = _saves.then((_) => _saveNow(value));
  }

  Future<void> _saveNow(String value) async {
    if (_deleting || (!_filled && widget.noteId != null)) return;
    try {
      final id = _id;
      if (id == null) {
        if (value.trim().isEmpty) return;
        final customer = await (_db.select(
          _db.customers,
        )..where((c) => c.id.equals(widget.customerId))).getSingle();
        final subject = noteSubjectOf(
          customerId: widget.customerId,
          roomId: widget.roomId,
          entryId: widget.entryId,
          pictureId: widget.pictureId,
        );
        _created = await _writer.addNote(
          workspaceId: customer.workspaceId,
          subjectType: subject.type,
          subjectId: subject.id,
          text: value,
        );
      } else if (_voice) {
        // The recording and its hash never change (D-302).
        await _writer.editNote(id, transcript: Value<String?>(value));
      } else if (value.trim().isNotEmpty) {
        await _writer.editNote(id, text: Value<String?>(value));
      }
    } on Object catch (error) {
      debugPrint('wio note: not saved: $error');
      _messenger.showSnackBar(SnackBar(content: Text(_l10n.noteNotSaved)));
    }
  }

  Future<void> _done() async {
    await _save();
    if (mounted) context.go(_base);
  }

  Future<void> _delete() async {
    final id = _id;
    if (_deleting || id == null) return;
    _deleting = true;
    _stopPlaying();
    final router = GoRouter.of(context);
    try {
      await _saves;
      await _writer.deleteNote(id);
    } on Object {
      if (mounted) _deleting = false;
      rethrow;
    }
    router.go(_base);
    _messenger.showSnackBar(
      SnackBar(
        content: Text(_l10n.noteDeleted),
        // UX rule 9: the note goes by itself (as D-278).
        duration: undoTime,
        persist: false,
        action: SnackBarAction(
          label: _l10n.undo,
          onPressed: () => _writer.restoreNote(id),
        ),
      ),
    );
  }

  void _fill(Note note) {
    if (_filled) return;
    _filled = true;
    _voice = note.audioSha256 != null;
    _field.text = (_voice ? note.transcript : note.noteText) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.noteId;
    final note = id == null ? null : ref.watch(noteProvider(id));
    final Note? value = note?.value;
    if (value != null) _fill(value);
    final Widget body;
    if (id == null) {
      body = _Fields(field: _field, voice: false, note: null, isNew: true);
    } else if (value != null) {
      body = _Fields(field: _field, voice: _voice, note: value, isNew: false);
    } else if (note is AsyncData<Note?> && !_deleting) {
      body = ContentWidth(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: HintText(l10n.noteMissing),
        ),
      );
    } else if (note is AsyncError<Note?>) {
      body = LoadFailed(message: l10n.loadFailed, error: note.error);
    } else {
      body = const SizedBox.shrink();
    }
    return StopNotesOnOpen(
      keep: widget.noteId,
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) unawaited(_save());
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: WioBackButton(label: l10n.noteDone, onPressed: _done),
            leadingWidth: wioBackButtonWidth(context),
            title: Text(l10n.noteTitle),
          ),
          body: body,
          bottomNavigationBar: value == null
              ? null
              : SafeArea(
                  child: Align(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: wioMaxContentWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(64),
                          ),
                          onPressed: _delete,
                          child: Text(l10n.noteDelete),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// The time line, playback of a voice note and the one optional field.
class _Fields extends StatefulWidget {
  const _Fields({
    required this.field,
    required this.voice,
    required this.note,
    required this.isNew,
  });

  final TextEditingController field;
  final bool voice;
  final Note? note;
  final bool isNew;

  @override
  State<_Fields> createState() => _FieldsState();
}

class _FieldsState extends State<_Fields> {
  @override
  void initState() {
    super.initState();
    widget.field.addListener(_changed);
  }

  @override
  void dispose() {
    widget.field.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final note = widget.note;
    final field = TextField(
      controller: widget.field,
      autofocus: widget.isNew,
      minLines: 3,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.voice ? l10n.noteTranscriptField : l10n.noteTextField,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
      ),
    );
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          if (note != null && widget.voice)
            NotePlayControlColumn(note: note)
          else if (note != null)
            Text(noteLine(l10n, note), style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          field,
          if (note != null && !widget.voice && widget.field.text.trim().isEmpty)
            HintText(l10n.noteEmptyKept),
        ],
      ),
    );
  }
}
