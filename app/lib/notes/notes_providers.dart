import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/queries.dart';
import '../media/media_presence.dart';
import '../media/media_store.dart';
import '../shell/providers.dart';
import 'note_audio.dart';
import 'note_player.dart';
import 'note_player_platform.dart';

/// What notes are about on a screen: subject type and id (D-298).
typedef NoteSubject = ({String type, String id});

/// The subject of a screen under [customerId]: the picture, else the entry
/// (plan 103), else the room, else the customer (as the voice note, D-295).
NoteSubject noteSubjectOf({
  required String customerId,
  String? roomId,
  String? entryId,
  String? pictureId,
}) {
  if (pictureId != null) return (type: 'picture', id: pictureId);
  if (entryId != null) return (type: 'entry', id: entryId);
  if (roomId != null) return (type: 'room', id: roomId);
  return (type: 'customer', id: customerId);
}

/// Live notes of a subject, oldest first (D-245, D-298).
final notesProvider = StreamProvider.family<List<Note>, NoteSubject>(
  retry: (count, error) => null,
  (ref, subject) =>
      watchNotesOf(ref.watch(databaseProvider), subject.type, subject.id),
);

/// One live note, or null when it is gone.
final noteProvider = StreamProvider.family<Note?, String>(
  retry: (count, error) => null,
  (ref, id) => watchNote(ref.watch(databaseProvider), id),
);

/// Where the player finds a recording, or null when it is not on the
/// device (D-305). Follows the file's state, so a card shows Abspielen as
/// soon as a download lands (D-332).
final noteAudioProvider = Provider.autoDispose.family<String?, String>((
  ref,
  sha256,
) {
  if (ref.watch(mediaFileProvider(sha256)) != MediaFileState.present) {
    return null;
  }
  return localNoteAudio(ref.watch(mediaFolderProvider).value, sha256);
});

/// The player of this build (D-300, D-335). Tests override it with a fake.
final notePlayerProvider = Provider<NotePlayer>(
  (ref) => platformNotePlayer(ref.watch(mediaStoreProvider)),
);

/// Whether this build plays recordings (D-300, D-335, D-350): Android and
/// iOS, where the media store keeps files, and the web from memory.
final canPlayNotesProvider = Provider<bool>(
  (ref) =>
      kIsWeb ||
      ((defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS) &&
          ref.watch(mediaStoreProvider).supported),
);
