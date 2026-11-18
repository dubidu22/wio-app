# Speech spike (throwaway)

A small Flutter app that measures, on a real phone and in airplane mode, how
well the phone's **own on-device** speech recognizer handles German, and
whether the app can keep an M4A recording at the same time (issue #9, KB
O-3, D-10, D-22). It lives here under D-45 and is deleted once the voice-note
feature has landed. It is **not product code**.

Plan: `plans/plan-009-app-speech-spike.md` in the project folder. Hand test:
[HAND-TEST.md](HAND-TEST.md).

## Modes

| # | Button | How |
| --- | --- | --- |
| 0 | Nur erkennen | `speech_to_text`, on-device, no recording (quality baseline) |
| 1 | Gleichzeitig | `speech_to_text` on-device + `record` M4A in parallel (two microphone users) |
| 2 | Gleichzeitig, eine Aufnahme | Own Kotlin: one `AudioRecord` feeds the on-device recognizer (`EXTRA_AUDIO_SOURCE`) and an AAC/M4A encoder. Android 13+ |
| 3 | Erst aufnehmen, dann erkennen | `record` M4A, then own Kotlin decodes the file and feeds it to the on-device recognizer (D-22). Android 13+ |

## Privacy (D-46)

- Every mode runs only after `SpeechChannel.kt` has confirmed on-device
  recognition (`isOnDeviceRecognitionAvailable`, and on Android 13+
  `checkRecognitionSupport` with German installed). `speech_to_text` with
  `onDevice: true` alone is not enough: on Android it silently falls back to
  the default, possibly online recognizer.
- Modes 2 and 3 only ever create `createOnDeviceSpeechRecognizer`.
- The release APK has no `INTERNET` permission (`tools:node="remove"` in the
  manifest; CI fails if it comes back).
- Recordings and results stay in the app's private folder. **Ergebnis
  kopieren** only puts a text table on the clipboard.
- Android backup is off: `allowBackup="false"`, `fullBackupContent="false"`
  and `data_extraction_rules.xml` excluding every domain from cloud backup and
  device transfer, so recordings and transcripts do not go to Google Drive or
  to a new phone. CI checks the built APK's manifest for it.
- iOS is not built yet. Before any iOS build, recordings and `results.json`
  must be excluded from iCloud backup (`NSURLIsExcludedFromBackupKey`, or
  stored outside Documents); otherwise the `Info.plist` usage text ("Nichts
  wird ins Internet geschickt") is untrue.
- The web build is deliberately not included: the browser's speech API sends
  audio to a server.

## Run and check

```sh
flutter pub get
flutter analyze --fatal-infos
flutter test
flutter build apk --release
```

The APK for the hand test is built by `.github/workflows/spike-speech-apk.yml`
and uploaded as the run artifact `speech-spike-apk`.

Screenshots at 390x844 (not goldens; outside `test/`):

```sh
SPIKE_FONT=/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf SPIKE_FONT_BOLD=/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf SPIKE_OUT=build/screenshots flutter test screenshot/
```

## What is tested where

| What | Where |
| --- | --- |
| Word error rate, German number normalisation, run timing, silence detection, guard refusal, results format, 56 px targets, German texts only from ARB | `flutter test` (34 tests) |
| Plugins and the Kotlin channel on a phone | Colin's hand test only; nothing device-specific is faked as passing |

## Licences of direct dependencies (INV-01)

| Package | Licence |
| --- | --- |
| speech_to_text 7.5.0 | BSD-3-Clause |
| record 7.2.0 | BSD-3-Clause |
| path_provider | BSD-3-Clause |
| material_ui | BSD-3-Clause |
| intl, flutter_localizations, flutter_lints | BSD-3-Clause |
