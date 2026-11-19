import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../camera/camera_providers.dart';
import '../media/media_store.dart';
import '../shell/providers.dart';
import 'voice_notes.dart';
import 'voice_recorder.dart';

/// The phone's recorder (D-284). Tests override it with a fake.
final voiceRecorderProvider = Provider<VoiceRecorder>(
  (ref) => ChannelVoiceRecorder(),
);

/// Whether this build records voice notes (D-295): Android only, where the
/// media store keeps files. Not the web (Q1) and not iOS until #63.
final canRecordVoiceProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      ref.watch(mediaStoreProvider).supported,
);

/// Keeps finished recordings as notes (D-290).
final voiceNotesProvider = Provider<VoiceNotes>(
  (ref) => VoiceNotes(
    ref.watch(databaseProvider),
    ref.watch(mediaWriterProvider),
    ref.watch(captureFilesProvider),
  ),
);
