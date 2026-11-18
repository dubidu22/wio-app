# app

Flutter app for Android, iOS and web. Lane `lane:app`; `app/lib/planning/` is lane `lane:planning`.

The Flutter version is pinned once, in `pubspec.yaml` under `environment: flutter:` (D-41).

| Command (run in `app/`) | What |
| --- | --- |
| `flutter pub get` | Dependencies; also generates `lib/l10n/app_localizations*.dart` from the ARB files |
| `dart format --output=none --set-exit-if-changed lib test` | Format check |
| `flutter analyze --fatal-infos --fatal-warnings` | Strict analysis |
| `flutter test --exclude-tags golden,ux` | Unit and widget tests |
| `flutter test --tags ux` | UX rules: 56-px touch targets and labelled buttons for every screen in `test/ux/screen_catalog.dart`, at phone and tablet size and at text scale 2 |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerates the drift code (`lib/data/*.g.dart`); generated files are committed (D-77) |
| `dart run drift_dev make-migrations` | After a change to `lib/data/tables.dart`: raise `schemaVersion`, then run this to add the schema dump under `drift_schemas/` and the migration test helpers (D-65) |
| `flutter test --tags golden` | Golden images of every catalogue screen at 390 × 844 and 820 × 1180 (D-76; Linux only; skipped elsewhere). Update with `--update-goldens`; golden files are critical |
| `flutter build web --wasm --no-web-resources-cdn --release` | Web build that loads nothing from a CDN (D-40) |

- UI text is German first and lives only in `lib/l10n/app_de.arb`.
- A new screen goes in a file named `*_screen.dart` and into `test/ux/screen_catalog.dart`; a test fails otherwise.
- Use `package:material_ui`, not the deprecated `package:flutter/material.dart` (Flutter 3.50). Localisation delegates come from `wioLocalizationsDelegates` in `lib/app.dart`.
- Local data: `lib/data/` (drift on SQLite, D-36, D-64). Every write on the device goes through `LocalWriter`, which also queues the change in the outbox (D-66). The web build needs `web/sqlite3.wasm` and `web/drift_worker.js`; see `web/README.md` (D-70).
- Android backup is off for the whole app (D-72); `test/platform/android_backup_test.dart` guards it.
