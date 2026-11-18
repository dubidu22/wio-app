# api

`openapi.yaml` is the API contract. It is the only interface between the app and the server (INV-02): the server's routes and the generated Dart client both follow it. Lane `lane:api`. Every change to it is critical (D-24) and touches two lanes, so a PR that changes it takes `lane:infra`. Plan: `plans/plan-004-api-contract.md` (D-89 to D-100).

## Version and subset (D-89, D-90)

The contract is OpenAPI **3.0.3**, written so that it means the same in 3.1. `server/tests/Api/Contract/ContractSubsetTest.php` enforces these rules:

| Rule | Instead |
| --- | --- |
| No `$ref` with sibling keys | `allOf: [$ref]` next to `type`, `nullable` or `description` |
| `nullable: true` always beside a `type` | |
| No `exclusiveMinimum`/`exclusiveMaximum`, `example`, `const` | `minimum`/`maximum`; files in `examples/`; a one-value `enum` |
| No `x-` extensions | Plain OpenAPI, so every tool reads the same thing |

## Evolution (D-99)

1. Changes within v1 are additive only: new operations, new optional request fields, new response fields, and new documented values of open strings (`EntityName`, `ChangeResult.reason`, `Problem.code`).
2. Request schemas are closed (`additionalProperties: false`). Response schemas stay open, and apps ignore fields and open-string values they do not know.
3. The server deploys before the app.
4. A breaking change needs a new path and a decision in the KB.
5. Integers that grow (`revision`, byte counts) declare `maximum: 9007199254740991`, because a Dart `int` on the web is a JavaScript number.

## Record schemas (D-95)

Each synced table of the database has one record schema (`Room`, `Entry`, …). `ContractSchemaTest` compares them with `server/tests/Db/Schema/schema-snapshot.json`. A migration that adds a column therefore also changes this file in the same PR.

## Server tests (D-93, D-94)

- Every API test extends `server/tests/Api/ContractTestCase` and declares the operations it calls with `#[Operation('…')]`. Its requests and responses are validated against this file.
- `server/tests/Api/pending-operations.php` lists the operations the server does not implement yet. `RouteParityTest` keeps routes, contract and that list in step, and the list must be empty before M1 closes.

## Examples

`examples/<request|response>.<Schema>.<case>.json` holds bodies that must validate, and `examples/invalid/` holds bodies that must not. All data is invented (`example.org`, postal code `00000`). The server test and the app's round-trip test read the same files.

## Dart client (D-91, D-92)

`generate-dart-client.sh` runs tonik, pinned in `codegen/pubspec.lock`, and writes `app/packages/wio_api/` plus its `CONTRACT_SHA256`. Run it after every change to `openapi.yaml` and commit the result. Never edit the generated package by hand.
