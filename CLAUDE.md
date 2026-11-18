# wio-app

Flutter app (Android, iOS, web) + PHP 8.3/MariaDB API. AGPL-3.0-only. Owner: Colin.
Design, decisions and process: private repo dubidu22/wio-app-design (docs/kb). The KB wins
over this file and over the code until a decision changes it.

## Hard rules
- English for code, identifiers, comments, issues, PRs. UI text German first, only via ARB files.
- Plan before code or tests (plans/issue<N>-<slug>-plan.md in the project folder).
- Never merge your own PR. Squash merge only, by the review thread, at the reviewed head SHA.
- Never commit customer data, real addresses, credentials or tokens.
- Every screen follows the ten UX rules (KB: 01-product/ux-rules.md): visible labelled buttons,
  no long press/swipe/hidden menus, touch targets >= 56 logical px, no required text fields,
  camera opens directly, no settings, no wizards, nothing to customers without "Senden",
  delete with undo.
- No built-in states, icons or categories with meaning; use labels and properties (D-5).

## Critical (fresh review thread, plan approval)
DB schema/migrations; sync protocol; api/openapi.yaml; auth, roles, permission checks; anything
sending data off device/server; golden files; .github release/deploy workflows; privacy texts;
LICENSE; the KB. Decided by the diff, not the label.

## Lanes (one implementation thread per lane, max three at once)
- lane:app       app/lib/ (except planning), its tests
- lane:planning  app/lib/planning/, its tests and goldens
- lane:api       server/, api/openapi.yaml
- lane:platform  .github/, tools/, build and release config

## Commands
- App:    cd app && flutter analyze && flutter test && flutter test --tags golden
- Server: cd server && composer test   (needs MariaDB; CI uses a service container)
- All:    see .github/workflows/ci.yml; the required check is "ci-passed".

## PRs
Title "<area>: <outcome> (#N)". Body: what, tests run (with counts), risk, out of scope,
screenshots at 390x844 for UI changes. Review answers: every finding fixed / deferred (issue) /
declined (reason).
