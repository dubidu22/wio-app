# migrations

Versioned SQL migrations for MariaDB (D-38). Lane `lane:api`; every change here is critical.

- One file per change, named `NNNN_description.sql` (four digits, then lower case letters, digits and underscores), for example `0001_initial_schema.sql`.
- Files run in number order through `bin/migrate`, which records each one in `schema_migrations` with its SHA-256 checksum.
- Never edit a file that has run anywhere; add a new one. The runner refuses to run when an applied file changed.
- MariaDB commits DDL immediately, so a failed file can leave half its statements applied. Keep files small, one concern each.
- CI applies every file to an empty database on every PR.
