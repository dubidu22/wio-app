# server

PHP 8.3 API (Slim 4, D-37) and versioned SQL migrations for MariaDB (D-38). Lane `lane:api`.

| Command (run in `server/`) | What |
| --- | --- |
| `composer install` | Dependencies |
| `composer check` | Everything CI runs: lint, code style, PHPStan, Psalm taint, tests |
| `composer test` | All PHPUnit suites (`unit`, `db`, `api`); `db` and `api` need MariaDB |
| `php bin/migrate` | Apply pending migrations to the database in `WIO_DB_DSN` |

A local MariaDB for the tests, with the throw-away settings that `phpunit.xml.dist` expects:

```sh
docker run -d --name wio-mariadb -p 3306:3306 -e MARIADB_DATABASE=wio_test -e MARIADB_USER=wio_test -e MARIADB_PASSWORD=wio_test -e MARIADB_ROOT_PASSWORD=root_test mariadb:10.11
```

Psalm needs PHP 8.3.16 or newer at run time (CI has it).

Configuration comes only from the environment: `WIO_DB_DSN`, `WIO_DB_USER`, `WIO_DB_PASSWORD`. Required PHP extensions: `intl`, `mbstring`, `pdo_mysql`.
