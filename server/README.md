# server

PHP 8.3 API (Slim 4, D-37) and versioned SQL migrations for MariaDB (D-38). Lane `lane:api`.

| Command (run in `server/`) | What |
| --- | --- |
| `composer install` | Dependencies |
| `composer check` | Everything CI runs: lint, code style, PHPStan, Psalm taint, tests |
| `composer test` | All PHPUnit suites (`unit`, `db`, `api`); `db` and `api` need MariaDB |
| `php bin/migrate` | Apply pending migrations to the database in `WIO_DB_DSN` |
| `php bin/create-owner …` | Create a workspace and its owner (see below) |
| `php bin/set-owner-password …` | Set a lost owner password, optionally signing out all devices |

A local MariaDB for the tests, with the throw-away settings that `phpunit.xml.dist` expects:

```sh
docker run -d --name wio-mariadb -p 3306:3306 -e MARIADB_DATABASE=wio_test -e MARIADB_USER=wio_test -e MARIADB_PASSWORD=wio_test -e MARIADB_ROOT_PASSWORD=root_test mariadb:10.11
```

Psalm needs PHP 8.3.16 or newer at run time (CI has it).

Configuration comes only from the environment: `WIO_DB_DSN`, `WIO_DB_USER`, `WIO_DB_PASSWORD`. Required PHP extensions: `intl`, `mbstring`, `pdo_mysql`, `sodium` (Argon2id, D-108).

## Owner sign-in (plan 005, D-108 to D-120)

- **Every request except `/health` and `/auth/sign-in` needs `Authorization: Bearer <token>`.** `Wio\Auth\AuthMiddleware` turns the token into an `AuthContext` (workspace, user, role, customer, device). Code takes the workspace and role from that context, never from the request (D-112). `public/.htaccess` passes the header on under CGI/FPM.
- **Passwords**: Argon2id with PHP's defaults, in the server-only table `user_passwords`. Only owners have one in M1. A hash with older options is upgraded at the next sign-in.
- **Tokens**: `wio_` + 32 random bytes, shown once. `device_tokens` keeps only the SHA-256. Sign-out and revoke delete the row. A token is invalid after 180 days without use, or when its user or workspace is deleted or a helper's link expired.
- **Limits**: at most 10 failed sign-ins per e-mail and 30 per IP address in 15 minutes, then `429` with `Retry-After`. `sign_in_failures` keeps SHA-256 hashes of the e-mail key and the IP address for 24 hours. The privacy notice names it.
- **Errors**: every error is problem+json with a `code` (D-116). Logs never get a request body, a header or a database value.

### First workspace and owner

The password comes from standard input, never from the command line. At a terminal it is asked twice with echo off. Without a way to hide it, the script refuses.

```sh
php bin/create-owner --workspace-name="Umzüge Beispiel" --plan=professional \
    --email=inhaber@example.org --display-name="Inhaber Beispiel" < password.txt
php bin/set-owner-password --email=inhaber@example.org [--workspace-id=UUID] [--revoke-devices] < password.txt
```

Passwords set here need 12 to 1024 characters. Both scripts print only ids. There is no reset e-mail in M1. If the hosting has no SSH (O-6), #10's ops endpoint calls the same classes (`Wio\Ops\CreateOwner`, `Wio\Ops\SetOwnerPassword`).
