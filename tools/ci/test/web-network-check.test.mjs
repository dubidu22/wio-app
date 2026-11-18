// Tests for web-network-check.mjs (D-40, TST-01): the guard must fail on a
// request to another host and on an app that never starts.
// Run: node --test tools/ci/test/web-network-check.test.mjs (needs Playwright's Chromium).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
import { checkWebBuild } from '../web-network-check.mjs';

const fixture = (name) => fileURLToPath(new URL(`./fixtures/${name}`, import.meta.url));
const fast = { startTimeoutMs: 3_000, settleMs: 500 };

test('a page that only loads local files passes', async () => {
  const result = await checkWebBuild(fixture('web-local'), fast);
  assert.equal(result.ok, true, JSON.stringify(result));
  assert.deepEqual(result.foreign, []);
  assert.ok(result.local.length >= 2);
});

test('a page that loads a Google font fails and names the request', async () => {
  const result = await checkWebBuild(fixture('web-foreign'), fast);
  assert.equal(result.ok, false);
  assert.ok(result.foreign.some((url) => url.startsWith('https://fonts.googleapis.com/')), JSON.stringify(result));
});

test('a page where the app never starts fails', async () => {
  const result = await checkWebBuild(fixture('web-no-app'), fast);
  assert.equal(result.ok, false);
  assert.match(result.error ?? '', /did not start/);
});
