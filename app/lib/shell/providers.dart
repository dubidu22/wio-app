import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/session_provider.dart';
import '../data/database.dart';
import '../data/entry_queries.dart';
import '../data/entry_writer.dart';
import '../data/local_writer.dart';
import '../data/open_database.dart';
import '../data/queries.dart';

/// The device's database. Tests override it with an in-memory one (D-68).
/// A new database deletes a session left by an earlier install (D-122).
final databaseProvider = Provider<WioDatabase>((ref) {
  final db = openWioDatabase(
    onFirstCreate: () => ref.read(tokenStoreProvider).delete(),
  );
  ref.onDispose(db.close);
  return db;
});

/// The current time. Tests override it with a fixed time.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Where the app's source code is (AGPL-3.0 section 13, D-29, D-73). A
/// modified version passes its own with `--dart-define=WIO_SOURCE_URL=...`.
const String wioSourceUrl = String.fromEnvironment(
  'WIO_SOURCE_URL',
  defaultValue: 'https://github.com/dubidu22/wio-app',
);

/// Writes entries, their places and targets, labels and properties with
/// their outbox changes (D-434..D-447); the place pickers use it (plan 107).
final entryWriterProvider = Provider<EntryWriter>((ref) {
  final db = ref.watch(databaseProvider);
  return EntryWriter(db, LocalWriter(db, clock: ref.watch(clockProvider)));
});

/// The source code address used by the app.
final sourceUrlProvider = Provider<Uri>((ref) => Uri.parse(wioSourceUrl));

/// Opens [uri] outside the app; true when a browser took it.
typedef LinkOpener = Future<bool> Function(Uri uri);

Future<bool> _openInBrowser(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    return false;
  }
}

/// Opens links in the external browser. Tests override it.
final linkOpenerProvider = Provider<LinkOpener>((ref) => _openInBrowser);

/// Reading the local database again does not fix a broken one; the screen
/// shows the error instead (D-65).
Duration? _noRetry(int retryCount, Object error) => null;

/// Level 1: today's and later jobs. Rebuilds just after the next local
/// midnight, so a list left open overnight moves the new day under "Heute".
final jobListProvider = StreamProvider<JobList>(retry: _noRetry, (ref) {
  final db = ref.watch(databaseProvider);
  final now = ref.watch(clockProvider)();
  final nextDay = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
  final timer = Timer(nextDay.difference(now), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return watchJobList(db, calendarDate(now));
});

/// Level 2: one customer with sites and rooms; null when it does not exist.
final customerProvider = StreamProvider.family<CustomerView?, String>(
  retry: _noRetry,
  (ref, customerId) {
    return watchCustomer(ref.watch(databaseProvider), customerId);
  },
);

/// Key of a room or a picture below a customer in the routes (D-259).
typedef CustomerItem = ({String customerId, String id});

/// Level 3: one room of a customer; null when it does not exist (D-264).
final roomProvider = StreamProvider.family<RoomScreenView?, CustomerItem>(
  retry: _noRetry,
  (ref, key) => watchRoom(ref.watch(databaseProvider), key.customerId, key.id),
);

/// Live pictures of one room, oldest first (D-245).
final roomPicturesProvider = StreamProvider.family<List<Picture>, String>(
  retry: _noRetry,
  (ref, roomId) => watchPicturesOfRoom(ref.watch(databaseProvider), roomId),
);

/// Live pictures of one customer that belong to no room (D-245).
final customerPicturesProvider = StreamProvider.family<List<Picture>, String>(
  retry: _noRetry,
  (ref, customerId) => watchPicturesOfCustomerWithoutRoom(
    ref.watch(databaseProvider),
    customerId,
  ),
);

/// Live after pictures of one picture of a customer (D-280).
final afterPicturesProvider =
    StreamProvider.family<
      List<Picture>,
      ({String customerId, String pictureId})
    >(
      retry: _noRetry,
      (ref, key) => watchAfterPictures(
        ref.watch(databaseProvider),
        key.customerId,
        key.pictureId,
      ),
    );

/// One picture of a customer, optionally checked to be in a room; null
/// when it does not exist (D-259).
final pictureProvider =
    StreamProvider.family<
      Picture?,
      ({String customerId, String? roomId, String pictureId})
    >(
      retry: _noRetry,
      (ref, key) => watchPicture(
        ref.watch(databaseProvider),
        key.customerId,
        key.pictureId,
        roomId: key.roomId,
      ),
    );

/// Live entry [id]; null when it does not exist or is deleted.
final entryProvider = StreamProvider.family<Entry?, String>(
  retry: _noRetry,
  (ref, id) => watchEntry(ref.watch(databaseProvider), id),
);
