import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/queries.dart';
import '../shell/providers.dart';
import 'media_files.dart';
import 'media_store.dart';

/// Where one picture or recording file stands on this device (D-332).
enum MediaFileState {
  /// The media folder is not listed yet: show no hint that may be wrong.
  unknown,

  /// The file is here.
  present,

  /// The file is queued or coming in during the current sync run (D-333).
  loading,

  /// The file is not here and not coming in now.
  missing,
}

/// Which files are on this device and which are coming in (D-332).
@immutable
class MediaPresence {
  const MediaPresence({
    required this.listed,
    this.present = const <String>{},
    this.loading = const <String>{},
  });

  /// False until the media folder was listed once.
  final bool listed;
  final Set<String> present;
  final Set<String> loading;

  MediaFileState of(String sha256) {
    if (!listed) return MediaFileState.unknown;
    if (present.contains(sha256)) return MediaFileState.present;
    if (loading.contains(sha256)) return MediaFileState.loading;
    return MediaFileState.missing;
  }

  MediaPresence copyWith({Set<String>? present, Set<String>? loading}) =>
      MediaPresence(
        listed: listed,
        present: present ?? this.present,
        loading: loading ?? this.loading,
      );
}

/// The set of files on this device (D-332): one listing of the media
/// folder at start, then kept current by downloads, by the web's memory and
/// by one check of each hash that new rows bring; a hash once known present
/// is never checked again.
final mediaPresenceProvider =
    NotifierProvider<MediaPresenceNotifier, MediaPresence>(
      MediaPresenceNotifier.new,
    );

class MediaPresenceNotifier extends Notifier<MediaPresence> {
  @override
  MediaPresence build() {
    final store = ref.watch(mediaStoreProvider);
    if (!store.supported) {
      // The web: what is in memory (D-334).
      store.onDropped = _dropped;
      ref.onDispose(() => store.onDropped = null);
      return MediaPresence(listed: true, present: store.memoryHashes);
    }
    final folder = ref.watch(mediaFolderProvider);
    if (folder.isLoading && !folder.hasValue) {
      return const MediaPresence(listed: false);
    }
    final path = folder.value;
    if (path == null) return const MediaPresence(listed: true);
    Set<String> present;
    try {
      present = listMediaFolder(path);
    } on Object {
      present = <String>{};
    }
    final checked = <String>{};
    final subscription = watchMediaRefs(ref.read(databaseProvider)).listen((
      refs,
    ) {
      if (!ref.mounted) return;
      for (final item in refs) {
        final sha = item.sha256;
        // Known present or already looked at: no second stat (D-332).
        if (state.present.contains(sha) || !checked.add(sha)) continue;
        bool exists;
        try {
          exists = mediaFileExists(path, sha);
        } on Object {
          exists = false;
        }
        if (exists) markPresent(sha);
      }
    }, onError: (Object _) {});
    ref.onDispose(() => unawaited(subscription.cancel()));
    return MediaPresence(listed: true, present: present);
  }

  /// The file [sha256] is now on the device.
  void markPresent(String sha256) {
    if (state.present.contains(sha256) && !state.loading.contains(sha256)) {
      return;
    }
    state = state.copyWith(
      present: <String>{...state.present, sha256},
      loading: <String>{...state.loading}..remove(sha256),
    );
  }

  /// The files queued or coming in now (D-333); empty when the step ends.
  void setLoading(Set<String> loading) {
    if (setEquals(loading, state.loading)) return;
    state = state.copyWith(loading: Set<String>.unmodifiable(loading));
  }

  void _dropped(String sha256) {
    if (!ref.mounted) return;
    state = state.copyWith(
      present: <String>{...state.present}..remove(sha256),
    );
  }
}

/// Files that screens show now (D-328). A screen wants a file while it
/// watches [mediaFileProvider] for it.
class MediaWants {
  final Map<String, int> _counts = <String, int>{};

  /// Told when a screen starts to show a file no other screen shows.
  void Function(String sha256)? onWanted;

  /// Told when the set changes (the web keeps these in memory, D-334).
  void Function(Set<String> wanted)? onChanged;

  Set<String> get all => _counts.keys.toSet();

  void add(String sha256) {
    final count = (_counts[sha256] ?? 0) + 1;
    _counts[sha256] = count;
    if (count == 1) {
      onChanged?.call(all);
      onWanted?.call(sha256);
    }
  }

  void remove(String sha256) {
    final count = (_counts[sha256] ?? 0) - 1;
    if (count > 0) {
      _counts[sha256] = count;
      return;
    }
    _counts.remove(sha256);
    onChanged?.call(all);
  }
}

final mediaWantsProvider = Provider<MediaWants>((ref) {
  final wants = MediaWants();
  final store = ref.watch(mediaStoreProvider);
  wants.onChanged = store.keepInMemory;
  return wants;
});

final _mediaWantProvider = Provider.autoDispose.family<void, String>((
  ref,
  sha256,
) {
  final wants = ref.watch(mediaWantsProvider);
  wants.add(sha256);
  ref.onDispose(() => wants.remove(sha256));
});

/// The state of the file [sha256], for tiles, the picture screen, the after
/// camera and note cards (D-332). Watching it tells the downloads that a
/// screen shows this file (D-328).
final mediaFileProvider = Provider.autoDispose.family<MediaFileState, String>((
  ref,
  sha256,
) {
  ref.watch(_mediaWantProvider(sha256));
  return ref.watch(mediaPresenceProvider.select((p) => p.of(sha256)));
});

/// Files coming in now, for the job list's status line (D-333).
final downloadingCountProvider = Provider<int>(
  (ref) => ref.watch(mediaPresenceProvider.select((p) => p.loading.length)),
);
