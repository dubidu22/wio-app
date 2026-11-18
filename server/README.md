# server

PHP 8.3 API (Slim 4, D-37) and versioned SQL migrations for MariaDB (D-38). Lane `lane:api`.

| Command (run in `server/`) | What |
| --- | --- |
| `composer install` | Dependencies |
| `composer check` | Everything CI runs: lint, code style, PHPStan, Psalm taint, tests |
| `composer test` | All PHPUnit suites (`unit`, `db`, `api`, `permission`); all but `unit` need MariaDB |
| `php bin/migrate` | Apply pending migrations to the database in `WIO_DB_DSN` |
| `php bin/create-owner …` | Create a workspace and its owner (see below) |
| `php bin/set-owner-password …` | Set a lost owner password, optionally signing out all devices |

A local MariaDB for the tests, with the throw-away settings that `phpunit.xml.dist` expects:

```sh
docker run -d --name wio-mariadb -p 3306:3306 -e MARIADB_DATABASE=wio_test -e MARIADB_USER=wio_test -e MARIADB_PASSWORD=wio_test -e MARIADB_ROOT_PASSWORD=root_test mariadb:10.11
```

Psalm needs PHP 8.3.16 or newer at run time (CI has it).

Configuration comes only from the environment: `WIO_DB_DSN`, `WIO_DB_USER`, `WIO_DB_PASSWORD`, and optionally `WIO_CORS_ORIGINS`. Required PHP extensions: `intl`, `mbstring`, `pdo_mysql`, `sodium` (Argon2id, D-108).

## Sync (plan 006, D-172 to D-191)

- `POST /sync/push` applies each change in its own transaction and remembers every answer by `change_id` for 180 days (`applied_changes`). **A retry of a `change_id` always gets the stored answer, a rejection included:** the app fixes the cause and sends the change again with a new `change_id`.
- Same-field clashes are found through `field_versions`; the later value wins, the earlier one goes to `conflicts`.
- `GET /sync/pull` reads the synced tables by revision in one consistent snapshot, filtered by the token's role in SQL. `since` above the workspace counter answers `410 resync_required`.
- Push validates `fields` against `src/Sync/RecordSchemas.php`, generated from `api/openapi.yaml`. After a change of a record schema, run `php bin/generate-record-schemas` and commit the result; a unit test fails until you do.
- Rights for push are in `src/Sync/Rights.php`, one table per role.

## CORS (plan 010 addendum, D-164 to D-171)

- `WIO_CORS_ORIGINS` lists the web app's origins, comma-separated, matched exactly: `https://host[:port]`, lower case, no path or trailing slash. `*`, `null`, wildcards, paths and other `http` origins are dropped. A full `http://localhost:<port>` is accepted for local and staging configs; **production's value never lists localhost.** Empty or missing means no CORS headers at all.
- `CorsMiddleware` is the outermost middleware. It answers preflights itself (204, before the app-version check and auth), and adds `Access-Control-Allow-Origin`, `Access-Control-Expose-Headers: Retry-After` and `Vary: Origin` to every answer for a listed origin, problem answers included. It never sends `Access-Control-Allow-Credentials`, because auth is a bearer token.

## App version (plan 033, D-140 to D-149)

- Every request may carry `Wio-App-Version: major.minor.patch[+build]`. `AppVersionMiddleware` checks it on every route, before auth: no header passes, a malformed one gets `400 invalid_request`, and a version below the minimum gets `426 upgrade_required` with `minimum_app_version`. Only `major.minor.patch` is compared.
- **The minimum** is `src/AppVersion/MinimumAppVersion.php` (`null` = none). Raise it only in a reviewed PR, and only after the new app version is live in every store and on the web (D-145): every older app stops syncing until it is updated. Its local data stays on the device.

## Owner sign-in (plan 005, D-108 to D-120)

- **Every request except `/health` and `/auth/sign-in` needs `Authorization: Bearer <token>`.** `Wio\Auth\AuthMiddleware` turns the token into an `AuthContext` (workspace, user, role, customer, device). Code takes the workspace and role from that context, never from the request (D-112). `public/.htaccess` passes the header on under CGI/FPM.
- **Passwords**: Argon2id with PHP's defaults, in the server-only table `user_passwords`. Only owners have one in M1. A hash with older options is upgraded at the next sign-in.
- **Tokens**: `wio_` + 32 random bytes, shown once. `device_tokens` keeps only the SHA-256. Sign-out and revoke delete the row. A token is invalid after 180 days without use, or when its user or workspace is deleted or a helper's link expired.
- **Limits**: at most 10 failed sign-ins per e-mail and 30 per IP address in 15 minutes, then `429` with `Retry-After`. An IPv6 client counts by its /64, an IPv4-mapped address as its IPv4 address (D-137). Each attempt records its row before the password check and counts the window including it, so parallel attempts cannot exceed the limit. `sign_in_failures` keeps SHA-256 hashes of the e-mail key and the IP key for 24 hours. The privacy notice names it.
- **Errors**: every error is problem+json with a `code` (D-116). Logs never get a request body, a header or a database value.

### First workspace and owner

The password comes from standard input, never from the command line. At a terminal it is asked twice with echo off. Without a way to hide it, the script refuses.

```sh
php bin/create-owner --workspace-name="Umzüge Beispiel" --plan=professional \
    --email=inhaber@example.org --display-name="Inhaber Beispiel" < password.txt
php bin/set-owner-password --email=inhaber@example.org [--workspace-id=UUID] [--revoke-devices] < password.txt
```

Passwords set here need 12 to 1024 characters. Both scripts print only ids. There is no reset e-mail in M1. If the hosting has no SSH (O-6), #10's ops endpoint calls the same classes (`Wio\Ops\CreateOwner`, `Wio\Ops\SetOwnerPassword`).
