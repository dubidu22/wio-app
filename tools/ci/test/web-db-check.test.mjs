// Tests for web-db-check.mjs (D-86, D-87, TST-01): the check passes only when
// the database exists and no database error was logged.
// Run: node --test tools/ci/test/web-db-check.test.mjs (needs Playwright's Chromium).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
import { checkWebDatabase } from '../web-db-check.mjs';

const fixture = (name) => fileURLToPath(new URL(`./fixtures/${name}`, import.meta.url));
const fast = { startTimeoutMs: 3_000, databaseTimeoutMs: 3_000, settleMs: 1_000 };

test('a database in IndexedDB passes', async () => {
  const result = await checkWebDatabase(fixture('web-db-indexeddb'), fast);
  assert.equal(result.ok, true, JSON.stringify(result));
  assert.equal(result.storage, 'IndexedDB');
});

test('a database in OPFS passes', async () => {
  const result = await checkWebDatabase(fixture('web-db-opfs'), fast);
  assert.equal(result.ok, true, JSON.stringify(result));
  assert.equal(result.storage, 'OPFS');
});

test('no database fails', async () => {
  const result = await checkWebDatabase(fixture('web-db-none'), fast);
  assert.equal(result.ok, false);
  assert.match(result.error ?? '', /no database "wio"/);
});

test('a drift error in the console fails even when the database exists', async () => {
  const result = await checkWebDatabase(fixture('web-db-error'), fast);
  assert.equal(result.ok, false);
  assert.ok(result.errors.some((line) => /drift worker failed/.test(line)), JSON.stringify(result));
});

test('a page where the app never starts fails', async () => {
  const result = await checkWebDatabase(fixture('web-db-no-app'), fast);
  assert.equal(result.ok, false);
  assert.match(result.error ?? '', /did not start/);
});
