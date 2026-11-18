# migrations

Versioned SQL migrations for MariaDB (D-38). Lane `lane:api`; every change here is critical (D-24).

## Running

- Files are named `NNNN_description.sql` (four digits, then lower case letters, digits and underscores) and run in number order through `bin/migrate`, which records each one in `schema_migrations` with its SHA-256 checksum.
- On the hosting, the same runner is reached over SSH or through a one-time-token endpoint; which one is the deploy workflow's choice (O-6, D-56).
- CI applies every file to an empty `mariadb:10.11` database on every PR and compares the result with `tests/Db/Schema/schema-snapshot.json`.

## Rules (D-55)

1. **Never edit a file that has been merged.** Add a new one. The runner refuses to run when an applied file changed or is missing.
2. **Forward only.** There are no down migrations: MariaDB commits DDL immediately, so a half-applied file cannot be rolled back. Fix forward; production is dumped before every migration.
3. **One DDL statement per file** for every migration after schema v1 (`0001` to `0007`, which only ever run on an empty database; the runner refuses a database that has tables but no history).
4. **Expand, then contract.** The code before and after a deploy must both work with the new schema: add a column or table first, switch the code in a later release, remove the old one after that.
5. **Update the snapshot in the same PR**: run the tests once with `WIO_UPDATE_SCHEMA_SNAPSHOT=1`, review the diff of `schema-snapshot.json`, and commit it.

## Patterns every table follows

`tests/Db/Schema/SchemaRulesTest.php` checks these, so a table that breaks one fails CI.

| Pattern | Rule | Decision |
| --- | --- | --- |
| IDs | `CHAR(36) CHARACTER SET ascii COLLATE ascii_bin`, lower-case canonical UUID, with `CONSTRAINT ck_<table>_id CHECK (id REGEXP …)` | D-47 |
| Common fields | `id`, `workspace_id`, then own fields, then `created_at`, `created_by`, `updated_at`, `updated_by`, `revision`, `deleted_at`; times `DATETIME(3)` in UTC set by the server; `KEY ix_<table>_revision (workspace_id, revision)` | D-52, D-53 |
| Workspace | Every table has `CONSTRAINT fk_<table>_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id)` | D-49 |
| **Composite foreign keys (mandatory for every new child table)** | Every parent has `UNIQUE KEY uq_<table>_scope (workspace_id, id)`. A child never references a parent by its id alone: it references `(workspace_id, parent_id)` → `parent (workspace_id, id)`, so it cannot point into another workspace. | D-49 |
| Customer | A table whose records belong to a customer has `customer_id` (null in personal workspaces), `UNIQUE KEY uq_<table>_customer_scope (workspace_id, customer_id, id)`, a key `(workspace_id, customer_id)` → `customers`, and for every parent that also has `customer_id` a second key `(workspace_id, customer_id, parent_id)` → `parent (workspace_id, customer_id, id)`. Links to `users` are exempt: users are actors, not records a customer owns. Where both child and parent allow a null `customer_id`, both also carry `no_customer TINYINT UNSIGNED AS (customer_id <=> NULL) STORED` (the parent with `UNIQUE (workspace_id, no_customer, id)`) and the child a key `(workspace_id, no_customer, parent_id)`, because InnoDB skips a foreign key with a null column: without the flag a child could drop its customer and vanish from that customer's reads and pulls. A table that links to a customer-scoped parent must itself have `customer_id`. | D-48, D-49 |
| Deletes | Tombstones (`deleted_at`); every foreign key is `ON DELETE RESTRICT ON UPDATE RESTRICT` | D-49 |
| Unique values | Unique among live rows only: `alive TINYINT UNSIGNED AS (IF(deleted_at IS NULL, 1, NULL)) STORED` closes the unique key. Names and e-mails compare through a key the server makes (`Wio\Schema\NameKey`) | D-51 |
| Kinds | Small fixed kinds from the KB as `VARCHAR` with `CHECK (… IN (…))`, never `ENUM`; no built-in states with meaning (D-5) | D-53 |
| JSON | `LONGTEXT` with `CHECK (JSON_VALID(…))` | D-53 |
| No triggers, routines or events | Rules such as append-only `place_history` live in the server code and its tests | D-54 |
| MariaDB version | Only features of 10.5 and older | D-57 |
