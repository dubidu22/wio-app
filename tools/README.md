# tools

Developer tooling, demo data and scripts. Lane `lane:platform`.

| Path | What |
| --- | --- |
| `ci/check-needs.sh` | Decides the `ci-passed` check from the results of all CI jobs (D-34) |
| `ci/flutter-test.sh` | Runs `flutter test` and fails when no test passed (D-35) |
| `ci/web-network-check.mjs` | Loads the web build in headless Chromium and fails on any request to another host (D-40) |
| `ci/test/` | Tests of the scripts above: `ci/test/check-needs.test.sh`, `ci/test/flutter-test.test.sh`, and `ci/test/web-network-check.test.mjs` with its fixtures (`npm run test:web-check`, needs Playwright's Chromium) |
| `package.json` | Pinned Node tools: Redocly CLI (`npm run lint:openapi`), Playwright (`npm run check:web`) |
