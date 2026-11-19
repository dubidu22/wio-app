# tools

Developer tooling, demo data and scripts. Lane `lane:platform`.

| Path | What |
| --- | --- |
| `ci/check-needs.sh` | Decides the `ci-passed` check from the results of all CI jobs (D-34) |
| `ci/flutter-test.sh` | Runs `flutter test` and fails when no test passed (D-35) |
| `ci/web-network-check.mjs` | Loads the web build in headless Chromium and fails on any request to another host (D-40) or anything the hosting's CSP blocks (D-366); `--url … --allow …` checks the deployed app (D-368) |
| `ci/web-db-check.mjs` | Loads the web build in headless Chromium and fails unless the local database `wio` opens (IndexedDB or OPFS) without drift or sqlite errors (D-87) or CSP violations; `--url …` checks the deployed app |
| `ci/generated-code-fresh.sh` | Runs code generators and fails when they change or add a file, so committed generated code stays fresh (D-85) |
| `ci/lib/web-serve.mjs` | Local static server that sends the headers of `deploy/web/htaccess.template` (D-366), and a Chromium context that aborts requests to other hosts and records CSP violations, shared by both web checks |
| `ci/test/` | Tests of the scripts above: `ci/test/check-needs.test.sh`, `ci/test/flutter-test.test.sh`, `ci/test/generated-code-fresh.test.sh`, and `ci/test/web-network-check.test.mjs` and `ci/test/web-db-check.test.mjs` with their fixtures (`npm run test:web-check`, `npm run test:web-db`, need Playwright's Chromium) |
| `deploy/deploy.sh`, `host.sh`, `smoke.sh`, `build-release.sh` | API deploy to the hosting (plan 010, `deploy-api.yml`) |
| `deploy/resolve.sh` | Environment, commit and mode of an API or web deploy; production only from `api-v*` / `app-v*` tags (D-160, D-359) |
| `deploy/web-deploy.sh`, `web-host.sh`, `web-smoke.sh` | Web deploy (plan 080, `deploy-web.yml`): build per environment, releases in `web/r/<sha>/` switched by one `.htaccess` rename, folder guard for `wio-web-*` only, smoke W1..W6 with switch back (D-360..D-367) |
| `deploy/web/htaccess.template` | Rewrite, cache and security headers of the web origin; CI's local server and the smoke test read their headers from it (D-361, D-363..D-366) |
| `deploy/test/` | `resolve.test.sh` and `web-deploy.test.sh` (CI's tools job); `local-deploy.test.sh` (API, local only, needs MariaDB) |
| `demo/demo-workspace.json` | The invented demo workspace for server tests, sync tests and goldens; format and rules in `demo/README.md` |
| `package.json` | Pinned Node tools: Redocly CLI (`npm run lint:openapi`), Playwright (`npm run check:web`, `npm run check:web-db`); `npm run test:web-headers` |

## Web releases (plan 080)

- Staging: every push to `main` deploys the API, then the web app to `WIO_WEB_ORIGIN` of the `staging` environment, built against its `WIO_API_URL`.
- Production: deploy the API first (tag `api-v*`), then tag `app-vX.Y.Z` on `main` where `X.Y.Z` is `version:` in `app/pubspec.yaml` without `+build`.
- Rollback: run `deploy-web` by hand with mode `rollback` (empty sha = the previous release). It is one `.htaccess` rename on the host.
- `WIO_WEB_ORIGIN` is also the API's CORS allow-list (D-163): changing it in an environment changes which origin that environment's API trusts from its next deploy.
