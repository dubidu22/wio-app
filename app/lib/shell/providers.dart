import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../data/open_database.dart';
import '../data/queries.dart';

/// The device's database. Tests override it with an in-memory one (D-68).
final databaseProvider = Provider<WioDatabase>((ref) {
  final db = openWioDatabase();
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

/// Level 1: today's and later jobs.
final jobListProvider = StreamProvider<JobList>(retry: _noRetry, (ref) {
  final db = ref.watch(databaseProvider);
  final today = calendarDate(ref.watch(clockProvider)());
  return watchJobList(db, today);
});

/// Level 2: one customer with sites and rooms; null when it does not exist.
final customerProvider = StreamProvider.family<CustomerView?, String>(
  retry: _noRetry,
  (ref, customerId) {
    return watchCustomer(ref.watch(databaseProvider), customerId);
  },
);
