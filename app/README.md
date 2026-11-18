# app

Flutter app for Android, iOS and web. Lane `lane:app`; `app/lib/planning/` is lane `lane:planning`.

The Flutter version is pinned once, in `pubspec.yaml` under `environment: flutter:` (D-41).

| Command (run in `app/`) | What |
| --- | --- |
| `flutter pub get` | Dependencies; also generates `lib/l10n/app_localizations*.dart` from the ARB files |
| `dart format --output=none --set-exit-if-changed lib test` | Format check |
| `flutter analyze --fatal-infos --fatal-warnings` | Strict analysis |
| `flutter test --exclude-tags golden,ux` | Unit and widget tests |
| `flutter test --tags ux` | UX rules: 56-px touch targets and labelled buttons for every screen in `test/ux/screen_catalog.dart` |
| `flutter test --tags golden` | Golden images at 390 × 844 (Linux only; skipped elsewhere). Update with `--update-goldens`; golden files are critical |
| `flutter build web --wasm --no-web-resources-cdn --release` | Web build that loads nothing from a CDN (D-40) |

- UI text is German first and lives only in `lib/l10n/app_de.arb`.
- A new screen goes in a file named `*_screen.dart` and into `test/ux/screen_catalog.dart`; a test fails otherwise.
- Use `package:material_ui` and `package:cupertino_ui`, not the deprecated `package:flutter/material.dart` (Flutter 3.50).
