# Demo workspace

`demo-workspace.json` is the invented demo data for server tests, sync tests, golden images and report snapshots (D-78). Every person, place, e-mail and address in it is made up (INV-07).

| Workspace | Plan | What it holds |
| --- | --- | --- |
| Demo Umzüge | professional | Owner Kim Muster; customer Familie Beispiel with a customer user and a helper; sites Alte Wohnung (Küche, Keller) and Neue Wohnung (Küche); doors, a window and three fixtures (the cellar shelf has 4 levels × 2 compartments); labels and property keys; seven entries in every place state (on a shelf, on the floor, not placed, moved twice, with a target place, deleted); place history; text notes; jobs on 19 and 20 Nov 2026; five pictures of 19 Nov (Küche two and an after picture, Keller one, one without a room) |
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
| Ids are `01990000-0000-7000-8000-TTTTNNNNNNNN`: `TTTT` is the table code below (the table number in hexadecimal), `NNNNNNNN` the row number in hexadecimal | Readable in dumps and test failures; never collides with other test ids (D-79) |
| Revisions run from 1 per workspace in insert order; a later change (a tombstone) gets a higher one | Sync tests can pull "since revision n" (D-52) |
| E-mails end in `@example.org`; `contact` holds an e-mail only, no phone number; every address has the postal code `00000`; no string anywhere holds another `@` address or a phone-like run of digits | Never real data, checked by the test (D-81) |
| An entry's place equals the `to_` place of its newest `place_history` row, and every move starts where the last one ended. An entry placed when it was created has its first history row at the entry's `created_at`; a later move is no later than the entry's `updated_at` | Every place change writes history in the same transaction (KB data-model.md) |
| `rooms.outline` is a list of `{"x_cm", "y_cm"}` corners, clockwise from the top left. `openings.wall_index` counts from 0: wall *i* runs from corner *i* to corner *i*+1, and the last wall runs back to corner 0 | Provisional, the planning lane may change both in M4 (D-83) |

| Table | Code | Table | Code | Table | Code |
| --- | --- | --- | --- | --- | --- |
| workspaces | `0001` | openings | `0006` | place_history | `000b` |
| users | `0002` | fixtures | `0007` | entity_labels | `000c` |
| customers | `0003` | labels | `0008` | entity_properties | `000d` |
| sites | `0004` | property_keys | `0009` | notes | `000e` |
| rooms | `0005` | entries | `000a` | jobs | `000f` |
| pictures | `0010` | | | | |

The next table takes 17, code `0011`.

## Changing it

1. Edit the JSON by hand; keep one row per line, so a review diff shows whole rows.
2. A migration that adds a column to a table in the file makes the server test fail until every row of that table lists the column. Set `schema_up_to` to the newest migration the file was checked against.
3. Voice notes (M2), time blocks, sign-offs and expenses (M5) and conflicts (sync) are added by the issue that first needs them.
4. Run `cd server && composer test` (needs MariaDB); the test is `tests/Db/DemoWorkspaceTest.php`. Run `cd app && flutter test test/data/demo_workspace_test.dart` too: a column added to a table the app holds fails there until the app's local table has it (D-84).

## Picture files

Every `pictures` row has its file in `media/<file_sha256>.jpg` (D-262): drawn scenes, 640 × 480 JPEG, quality 85, no EXIF, no camera photos. `file_bytes`, `width_px`, `height_px` and `file_mime` match the file; the app test `test/data/demo_workspace_test.dart` checks that. A new picture needs a new file named by its hash; never change the bytes of an existing file, the hash in the rows would no longer match.

## Users

| Who | How |
| --- | --- |
| Server tests | `Wio\Tests\Support\DemoWorkspace::fromFile()->load($pdo)` on a migrated database |
| App tests | `DemoWorkspace.fromFile().load(db)` from `app/test/support/demo_workspace.dart` loads the rows of the app's local tables into an in-memory database and sets `sync_state` (D-84) |
