# tools

Developer tooling, demo data and scripts. Lane `lane:platform`.

| Path | What |
| --- | --- |
| `ci/check-needs.sh` | Decides the `ci-passed` check from the results of all CI jobs (D-34) |
| `ci/flutter-test.sh` | Runs `flutter test` and fails when no test passed (D-35) |
| `ci/web-network-check.mjs` | Loads the web build in headless Chromium and fails on any request to another host (D-40) |
| `ci/web-db-check.mjs` | Loads the web build in headless Chromium and fails unless the local database `wio` opens (IndexedDB or OPFS) without drift or sqlite errors (D-87) |
| `ci/generated-code-fresh.sh` | Runs code generators and fails when they change or add a file, so committed generated code stays fresh (D-85) |
| `ci/lib/web-serve.mjs` | Local static server and a Chromium context that aborts requests to other hosts, shared by both web checks |
| `ci/test/` | Tests of the scripts above: `ci/test/check-needs.test.sh`, `ci/test/flutter-test.test.sh`, `ci/test/generated-code-fresh.test.sh`, and `ci/test/web-network-check.test.mjs` and `ci/test/web-db-check.test.mjs` with their fixtures (`npm run test:web-check`, `npm run test:web-db`, need Playwright's Chromium) |
| `demo/demo-workspace.json` | The invented demo workspace for server tests, sync tests and goldens; format and rules in `demo/README.md` |
| `package.json` | Pinned Node tools: Redocly CLI (`npm run lint:openapi`), Playwright (`npm run check:web`, `npm run check:web-db`) |
