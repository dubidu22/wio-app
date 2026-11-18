# Third-party licences

Every direct dependency, bundled asset and CI tool of wio-app, with its licence (D-44, INV-01). A pull request that adds, removes or upgrades one across a major version updates this file and names the licence in its body. Transitive dependencies are pinned in `app/pubspec.lock`, `server/composer.lock` and `tools/package-lock.json`; the nightly licence check (KB `03-process/ci.md`) will verify them.

Banned: SSPL, non-commercial, proprietary, GPL-2.0-only, other licences incompatible with AGPL-3.0, and anything unclear.

## Shipped with the app (Flutter)

| Package or asset | Version | Licence | Why |
| --- | --- | --- | --- |
| Flutter SDK (`flutter`, `flutter_localizations`) | 3.50.0 | BSD-3-Clause | App framework (D-16) |
| `material_ui` | 1.11.1 | BSD-3-Clause | Material widgets (decoupled from the SDK in Flutter 3.50) |
| `cupertino_ui` | 1.1.7 | BSD-3-Clause | Cupertino localisations used by Material widgets |
| `intl` | 0.20.3 | BSD-3-Clause | Localisation (ARB files) |
| Roboto font, Regular and Medium (`app/assets/fonts/`) | googlefonts/roboto `main` at 38062f4, v2 hinted | Apache-2.0 (text in `app/assets/fonts/LICENSE.txt`) | Bundled so no platform fetches fonts from a CDN (D-40) |

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
| `phpunit/phpunit` | 12.5.44 | BSD-3-Clause | PHP tests |
| `phpstan/phpstan`, `phpstan/phpstan-strict-rules` | 2.3.6, 2.1.1 | MIT | Static analysis (D-39) |
| `vimeo/psalm` | 6.5.0 | MIT | Taint analysis (D-39) |
| `friendsofphp/php-cs-fixer` | 3.95.32 | MIT | PHP code style |
| `php-parallel-lint/php-parallel-lint` | 1.4.0 | BSD-2-Clause | PHP syntax check |
| `@redocly/cli` | 2.80.0 | MIT | OpenAPI lint (D-43) |
| `playwright` | 1.63.0 | Apache-2.0 | Web network check in headless Chromium (D-40) |
| actionlint | 1.7.12 | MIT | Workflow lint (D-42) |
| ShellCheck | runner's version | GPL-3.0-or-later | Shell script lint; a tool only, never linked or shipped |
| GitHub Actions: `actions/*`, `github/codeql-action` | pinned by SHA in `.github/workflows/` | MIT | CI |
| GitHub Actions: `subosito/flutter-action`, `shivammathur/setup-php` | pinned by SHA | MIT | CI |
| MariaDB container `mariadb:10.11` | 10.11 | GPL-2.0 (server, run as a separate program in CI) | Test database; not linked or shipped |
