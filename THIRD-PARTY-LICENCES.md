# Third-party licences

Every direct dependency, bundled asset and CI tool of wio-app, with its licence (D-44, INV-01). A pull request that adds, removes or upgrades one across a major version updates this file and names the licence in its body. Transitive dependencies are pinned in `app/pubspec.lock`, `server/composer.lock` and `tools/package-lock.json`; the nightly licence check (KB `03-process/ci.md`) will verify them.

Banned: SSPL, non-commercial, proprietary, GPL-2.0-only, other licences incompatible with AGPL-3.0, and anything unclear.

## Shipped with the app (Flutter)

| Package or asset | Version | Licence | Why |
| --- | --- | --- | --- |
| Flutter SDK (`flutter`, `flutter_localizations`) | 3.50.0 | BSD-3-Clause | App framework (D-16) |
| `material_ui` | 1.11.1 | BSD-3-Clause | Material widgets (decoupled from the SDK in Flutter 3.50) |
| Transitive: `cupertino_ui` | 1.1.7 | BSD-3-Clause | Cupertino localisations, part of `material_ui`'s delegate list |
| `intl` | 0.20.3 | BSD-3-Clause | Localisation (ARB files) |
| Material Icons font (`MaterialIcons-Regular.otf`, bundled by `uses-material-design: true`, tree-shaken in release builds) | from the Flutter 3.50.0 SDK | Apache-2.0 | Icons used by Material widgets (for example the back arrow) |
| Roboto font, Regular and Medium (`app/assets/fonts/`) | googlefonts/roboto `main` at 38062f4, v2 hinted | Apache-2.0 (text in `app/assets/fonts/LICENSE.txt`) | Bundled so no platform fetches fonts from a CDN (D-40) |
| `flutter_riverpod`, `riverpod` | 3.5.0 | MIT | State management (D-36, D-68) |
| `drift` | 2.35.4 | MIT | Typed local database (D-36, D-64) |
| `drift_flutter` | 0.3.1 | MIT | Opens the database on each platform (D-70) |
| `sqlite3` | 3.9.1 | MIT | SQLite bindings; its build hook bundles SQLite (D-71) |
| SQLite (bundled native library from the `sqlite3` build hook, checked against SHA-256 values in the package) | as shipped by `sqlite3` 3.9.1 | Public domain | Database engine on Android, iOS and desktop (D-71) |
| `app/web/sqlite3.wasm` | from sqlite3.dart release `sqlite3-3.9.1` (SHA-256 in `app/web/README.md`) | SQLite: public domain; glue code: MIT | Database engine in the browser (D-70) |
| `app/web/drift_worker.js` | from drift release `drift-2.35.4` (SHA-256 in `app/web/README.md`) | MIT | Runs the browser database in a worker (D-70) |
| `go_router` | 18.1.4 | BSD-3-Clause | Routing and web URLs (D-69) |
| `url_launcher` | 6.3.3 | BSD-3-Clause | Opens the source code in the browser (D-73) |
| `path_provider` | 2.1.6 | BSD-3-Clause | Application Support folder for the database (D-72) |
| `uuid` | 4.6.0 | MIT | UUID v7 made on the device (D-67) |
| Transitive: `state_notifier` | 1.0.0 | MIT | Used by `riverpod` |
| Transitive: `sqlite3_flutter_libs`, `sqlcipher_flutter_libs` | 0.6.0+eol, 0.7.0+eol | MIT | Empty end-of-life packages named by `drift_flutter`; no native code |
| Transitive: platform packages of `url_launcher` and `path_provider`; `jni`, `jni_flutter`, `jni_util`, `objective_c` (used by `path_provider`); `meta`, `collection`, `async`, `stack_trace` and other Dart team packages | see `app/pubspec.lock` | BSD-3-Clause | Used by the packages above |

## Shipped with the server (PHP)

| Package | Version | Licence | Why |
| --- | --- | --- | --- |
| `slim/slim` | 4.15.3 | MIT | HTTP framework (D-37) |
| `slim/psr7` | 1.8.1 | MIT | PSR-7 messages for Slim |
| Transitive: `nikic/fast-route` | 1.3.1 | BSD-3-Clause | Router used by Slim |
| Transitive: `psr/*`, `fig/http-message-util`, `ralouphie/getallheaders` | see `server/composer.lock` | MIT | Interfaces and helpers used by Slim |

## Development and CI only (not shipped)

| Tool | Version | Licence | Why |
| --- | --- | --- | --- |
| `flutter_lints` | 6.0.0 | BSD-3-Clause | Analyzer rules |
| `drift_dev`, `build_runner` | 2.35.3, 2.17.1 | MIT, BSD-3-Clause | Generates the database code and schema dumps (D-77) |
| `crypto` | 3.0.8 | BSD-3-Clause | Test of the web database files' SHA-256 (D-70) |
| `phpunit/phpunit` | 12.5.44 | BSD-3-Clause | PHP tests |
| `phpstan/phpstan`, `phpstan/phpstan-strict-rules` | 2.3.6, 2.1.1 | MIT | Static analysis (D-39) |
| `vimeo/psalm` | 6.5.0 | MIT | Taint analysis (D-39) |
| `friendsofphp/php-cs-fixer` | 3.95.32 | MIT | PHP code style |
| `php-parallel-lint/php-parallel-lint` | 1.4.0 | BSD-2-Clause | PHP syntax check |
| `@redocly/cli` | 2.80.0 | MIT | OpenAPI lint (D-43) |
| `league/openapi-psr7-validator` | 0.24 | MIT | Validates every API test request and response against `api/openapi.yaml` (D-93) |
| `symfony/yaml` | 7.4.23 | MIT | Reads `api/openapi.yaml` in the contract tests |
| Transitive: `devizzent/cebe-php-openapi`, `justinrainbow/json-schema`, `respect/validation`, `respect/stringifier`, `riverline/multipart-parser`, `psr/cache` | see `server/composer.lock` | MIT | Used by the OpenAPI validator |
| Transitive: `marc-mabe/php-enum` | 4.7.2 | BSD-3-Clause | Used by `justinrainbow/json-schema` |
| `tonik` (in `api/codegen/`, with its own lockfile) | 0.11.1 | MIT | Generates the Dart API client from `api/openapi.yaml` (D-91) |
| `playwright` | 1.63.0 | Apache-2.0 | Web network check in headless Chromium (D-40) |
| actionlint | 1.7.12 | MIT | Workflow lint (D-42) |
| ShellCheck | runner's version | GPL-3.0-or-later | Shell script lint; a tool only, never linked or shipped |
| GitHub Actions: `actions/*`, `github/codeql-action` (the action code) | pinned by SHA in `.github/workflows/` | MIT | CI |
| CodeQL CLI and query packs (downloaded by `github/codeql-action`) | bundled with v4.39.3 | GitHub CodeQL Terms and Conditions | Workflow scanning in CI only (D-39); run as GitHub's service, never shipped |
| Chromium (downloaded by `npx playwright install chromium`) | the build matching Playwright 1.63.0 | BSD-3-Clause, plus the licences of its bundled components | Headless browser for the web network check in CI only (D-40) |
| GitHub Actions: `subosito/flutter-action`, `shivammathur/setup-php` | pinned by SHA | MIT | CI |
| MariaDB container `mariadb:10.11` | 10.11 | GPL-2.0 (server, run as a separate program in CI) | Test database; not linked or shipped |
