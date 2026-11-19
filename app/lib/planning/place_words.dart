import '../data/database.dart';
import '../data/entry_writer.dart';
import '../l10n/app_localizations.dart';

/// Place words shared by the pickers, the entry screen (#103), entry lists
/// (#105) and the place history (#108) (D-456).
///
/// [roomName] gives the name of a live room (null for a room without a
/// name) and is not called for an unknown room; [isLiveRoom] says whether
/// the room is still there. A room-only place is on the floor (D-450).
/// Fixtures, slots and floor points come with M4; until then such a place
/// reads like the room's floor.
String placeWords(
  AppLocalizations l10n,
  Place place, {
  required bool Function(String roomId) isLiveRoom,
  required String? Function(String roomId) roomName,
}) {
  final roomId = place.roomId;
  if (roomId == null) return l10n.placeNone;
  if (!isLiveRoom(roomId)) return l10n.placeRoomDeleted;
  return l10n.placeOnFloor(roomName(roomId) ?? l10n.unnamedRoom);
}

/// The target in words: "Ziel: Küche", or "Kein Ziel" (D-9, D-456).
String targetWords(
  AppLocalizations l10n,
  Place target, {
  required bool Function(String roomId) isLiveRoom,
  required String? Function(String roomId) roomName,
}) {
  final roomId = target.roomId;
  if (roomId == null) return l10n.targetNone;
  if (!isLiveRoom(roomId)) return l10n.targetWords(l10n.placeRoomDeleted);
  return l10n.targetWords(roomName(roomId) ?? l10n.unnamedRoom);
}

/// An entry's name: its title, else its code, else "Eintrag ohne Namen".
String entryName(AppLocalizations l10n, Entry entry) {
  final title = entry.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  final code = entry.code;
  if (code != null && code.isNotEmpty) return code;
  return l10n.unnamedEntry;
}
