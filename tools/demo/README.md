# Demo workspace

`demo-workspace.json` is the invented demo data for server tests, sync tests, golden images and report snapshots (D-78). Every person, place, e-mail and address in it is made up (INV-07).

| Workspace | Plan | What it holds |
| --- | --- | --- |
| Demo Umzüge | professional | Owner Kim Muster; customer Familie Beispiel with a customer user and a helper; sites Alte Wohnung (Küche, Keller) and Neue Wohnung (Küche); doors, a window and three fixtures (the cellar shelf has 4 levels × 2 compartments); labels and property keys; seven entries in every place state (on a shelf, on the floor, not placed, moved twice, with a target place, deleted); place history; text notes; jobs on 19 and 20 Nov 2026 |
| Demo privat | personal | Owner Robin Probe; one site, one room, one entry; no customer (the null-customer path) |

## Format

```json
{"format": 1, "schema_up_to": "0007", "tables": [{"table": "workspaces", "rows": [{...}]}, ...]}
```

| Rule | Why |
| --- | --- |
| Tables in insert order, column names exactly as in `server/migrations/`; every row lists every column except the derived ones | The server test loads the file into the real schema, so every foreign key and check proves the data (D-80) |
| Derived columns are left out: generated columns (`alive`, `no_customer`), `name_key`, `email_key`, and the `workspace_counters` table | The database makes generated columns; the loader makes the rest as the server does (`Wio\Schema\NameKey`, highest revision per workspace) |
| Times are ISO-8601 UTC with milliseconds (`2026-11-02T08:01:00.000Z`); dates are `YYYY-MM-DD` | The form sync carries; the loader converts to `DATETIME(3)` |
| JSON columns (`contact`, `outline`, `levels`) are nested JSON | Readable; the loader encodes them |
| Ids are `01990000-0000-7000-8000-TTTTNNNNNNNN`: `TTTT` is the table number below, `NNNNNNNN` the row number | Readable in dumps and test failures; never collides with other test ids (D-79) |
| Revisions run from 1 per workspace in insert order; a later change (a tombstone) gets a higher one | Sync tests can pull "since revision n" (D-52) |
| E-mails end in `@example.org`; `contact` holds an e-mail only, no phone number; every address has the postal code `00000` | Never real data, checked by the test (D-81) |
| An entry's place equals the `to_` place of its newest `place_history` row, and every move starts where the last one ended | Every place change writes history (KB data-model.md) |
| `rooms.outline` is a list of `{"x_cm", "y_cm"}` corners, clockwise from the top left | Provisional, the planning lane may change it in M4 (D-83) |

Table numbers: 1 workspaces, 2 users, 3 customers, 4 sites, 5 rooms, 6 openings, 7 fixtures, 8 labels, 9 property keys, 10 entries, 11 place history, 12 entity labels, 13 entity properties, 14 notes, 15 jobs. The next table takes 16.

## Changing it

1. Edit the JSON by hand; keep one row per line, so a review diff shows whole rows.
2. A migration that adds a column to a table in the file makes the server test fail until every row of that table lists the column. Set `schema_up_to` to the newest migration the file was checked against.
3. Pictures and voice notes (M2), time blocks, sign-offs and expenses (M5) and conflicts (sync) are added by the issue that first needs them.
4. Run `cd server && composer test` (needs MariaDB); the test is `tests/Db/DemoWorkspaceTest.php`.

## Users

| Who | How |
| --- | --- |
| Server tests | `Wio\Tests\Support\DemoWorkspace::fromFile()->load($pdo)` on a migrated database |
| App tests | A loader for the app's local tables follows in a lane:app issue (D-82) |
