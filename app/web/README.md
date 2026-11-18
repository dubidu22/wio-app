# Web build files

`sqlite3.wasm` and `drift_worker.js` run the local database in the browser
(D-36, D-70). They are committed so every build is reproducible and loads
nothing from another host (D-40). Data stays in the browser (OPFS or
IndexedDB).

When `sqlite3` or `drift` in `pubspec.lock` changes, download the matching
files from the release pages below, replace them here and update this table.
`test/platform/web_database_files_test.dart` fails until hashes and versions
agree.

| File | Package | Version | Source | SHA-256 | Licence |
| --- | --- | --- | --- | --- | --- |
| `sqlite3.wasm` | sqlite3 | 3.9.1 | https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.9.1 | e7451780e78c56ff864fe9317a0fbcd6aeb2e8de3beba7f5efd963202f7ec3d9 | SQLite: public domain; sqlite3.dart glue: MIT |
| `drift_worker.js` | drift | 2.35.4 | https://github.com/simolus3/drift/releases/tag/drift-2.35.4 | 48c950cd8e3bc3cddb34816c860e228be8832bef07a297c27e9907c057ff8162 | MIT |
