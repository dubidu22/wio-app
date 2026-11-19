import '../data/database.dart';
import '../l10n/app_localizations.dart';

/// A length as m:ss, e.g. 0:45 or 10:00 (D-307).
String noteClock(Duration length) {
  final seconds = length.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// The note's time line: server time, or "Noch nicht gesendet" while it is
/// unknown (D-306), then the length of a recording (D-307).
String noteLine(AppLocalizations l10n, Note note) {
  final created = note.createdAt == null
      ? null
      : DateTime.tryParse(note.createdAt!);
  final time = created == null
      ? l10n.noteNotSent
      : l10n.noteTime(created.toLocal());
  final seconds = note.audioSeconds;
  if (note.audioSha256 == null || seconds == null) return time;
  return '$time · ${l10n.noteLength(noteClock(Duration(seconds: seconds)))}';
}

/// What a card shows: the text, else the transcript, else "Ohne Text"
/// (D-308).
String noteBody(AppLocalizations l10n, Note note) =>
    note.noteText ?? note.transcript ?? l10n.noteNoText;
