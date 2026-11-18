# Hand test: speech spike

For Colin, on the spike phone (O-10). About 25 minutes. Android 13 or newer
is best; Android 12 can run only the first two modes.

**Nothing leaves the phone:** the test runs in airplane mode, and the app has
no internet permission.

## Before you start

1. Open the latest **spike-speech-apk** run under the repository's **Actions**
   tab on GitHub and download the artifact **speech-spike-apk**. Unzip it; the
   file inside is `app-release.apk`.
2. Copy the APK to the phone and open it. Android asks once to allow
   installing from this source; allow it, then **Installieren**.
3. With internet still on, open **Sprach-Test**, tap **Nur erkennen**, and
   allow the microphone.
   - If the app says German is not loaded yet, tap **Deutsch laden**, wait two
     minutes, then **Nochmal prüfen**.
   - If it says recognition does not work without internet, stop here and
     tell us the phone model and Android version: this phone cannot do it.
4. Turn on **airplane mode** and turn **Wi-Fi off**.

## The test

Quiet room, phone about 30 cm from your mouth, normal speaking voice.

For each of the four mode buttons, from top to bottom:

1. Tap the mode button.
2. For sentences 1 to 5: tap **Sprechen**, read the sentence aloud, tap
   **Stopp**, wait for the text, tap **Weiter**.
3. For **Freie Notiz**: tap **Sprechen**, talk freely for about 45 seconds
   about a made-up job, pausing twice for about 5 seconds, then **Stopp**.
4. After the last item, the results open. Tap **Zurück** to go to the next
   mode.

If a mode shows an error or says "Die Aufnahme ist stumm", just continue: that
is a result too.

Then once more with background noise (radio on, or a tap running): repeat
**Gleichzeitig** or **Gleichzeitig, eine Aufnahme**, whichever worked better,
sentences 1 to 5 only.

## Send the results

1. On the start screen tap **Ergebnisse**, then **Ergebnis kopieren**.
2. Airplane mode off, paste into the project chat.
3. Add one line: phone model and Android version (Settings → About phone), and
   whether the transcripts felt usable to you.

## What we learn

| Question | Answered by |
| --- | --- |
| Record and recognize at once? | Modes 1 and 2: text **and** a recording that is not silent |
| German quality | "Fehlerquote" on sentences 1 to 5 |
| Speed | "Zeit bis zum Text" |
| Long notes with pauses | Free note: does recognition stop by itself? |
| Fallback (D-22) | Mode 3 |
