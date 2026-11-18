import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'database.dart';

/// Opens the database on this device.
///
/// Native: a file in Application Support, which Android never backs up
/// (D-72: backup is off in the manifest); iOS backup exclusion follows in M2.
/// Web: SQLite compiled to WebAssembly from `web/sqlite3.wasm`, run in
/// `web/drift_worker.js`, stored in the browser (D-70). Nothing is loaded
/// from another host.
WioDatabase openWioDatabase() {
  return WioDatabase(
    driftDatabase(
      name: 'wio',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
}
