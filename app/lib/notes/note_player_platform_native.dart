import '../media/media_store.dart';
import 'note_player.dart';

/// The phone's player: the app's own channel `wio/player` (D-300).
NotePlayer platformNotePlayer(MediaStore store) => ChannelNotePlayer();
