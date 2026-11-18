# wio-app

A field app for tidy-up and moving work: document the work with pictures and voice notes, place boxes and things in rooms and on shelves, and give customers one clear report of **what is where**.

One Flutter code base for Android, iOS and web, with a PHP 8.3 + MariaDB API. The user interface ships in German first. `wio-app` is a working name.

## Status

Early development (milestone M1, Foundation). Nothing here is ready for use yet.

## Repository layout

| Folder | What lives there |
| --- | --- |
| `app/` | Flutter app (Android, iOS, web) |
| `server/` | PHP 8.3 API and database migrations |
| `api/` | OpenAPI contract (`openapi.yaml`), the single source for client and server |
| `tools/` | Developer tooling, demo data, scripts |
| `.github/` | CI, release and deploy workflows |

How to build and test is in [`CLAUDE.md`](CLAUDE.md) until a contributor guide replaces it.

## Contributing

Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a pull request.

## Licence

Copyright (C) 2026 the wio-app authors.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3 only (`AGPL-3.0-only`). See [`LICENSE`](LICENSE).

If you run a modified version of this software for users over a network, the AGPL requires you to offer them the corresponding source code.
