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
  // Without the hosting's headers, so the request is made and recorded
  // (the CSP would block it before it leaves, see the next test).
  const result = await checkWebBuild(fixture('web-foreign'), { ...fast, headers: false });
  assert.equal(result.ok, false);
  assert.ok(result.foreign.some((url) => url.startsWith('https://fonts.googleapis.com/')), JSON.stringify(result));
});

test('a page where the app never starts fails', async () => {
  const result = await checkWebBuild(fixture('web-no-app'), fast);
  assert.equal(result.ok, false);
  assert.match(result.error ?? '', /did not start/);
});

test('under the hosting headers, the Google font is blocked by the CSP and fails', async () => {
  const result = await checkWebBuild(fixture('web-foreign'), fast);
  assert.equal(result.ok, false);
  assert.ok(result.violations.some((line) => /fonts\.googleapis\.com/.test(line)), JSON.stringify(result));
});

test('an inline script runs without headers but is blocked under the hosting CSP (D-366)', async () => {
  const plain = await checkWebBuild(fixture('web-csp-inline'), { ...fast, headers: false });
  assert.equal(plain.ok, true, JSON.stringify(plain));
  const strict = await checkWebBuild(fixture('web-csp-inline'), fast);
  assert.equal(strict.ok, false);
  assert.ok(strict.violations.some((line) => /script-src/.test(line)), JSON.stringify(strict));
});

test('a deployed app: its own origin and the allowed API pass, other hosts are foreign (D-368)', async () => {
  // Two local servers stand in for the deployed origin and its API, so the
  // test itself never leaves the machine.
  const { createServer } = await import('node:http');
  const listen = async (handler) => {
    const server = createServer(handler);
    await new Promise((ok) => server.listen(0, '127.0.0.1', ok));
    return server;
  };
  const api = await listen((_req, res) => { res.writeHead(204); res.end(); });
  const apiOrigin = `http://localhost:${api.address().port}`;
  const page = '<!DOCTYPE html><html><head><meta charset="utf-8"></head><body><flutter-view></flutter-view>'
    + `<img src="${apiOrigin}/pixel.png"><img src="https://tracker.example.net/t.png"></body></html>`;
  const app = await listen((_req, res) => { res.writeHead(200, { 'content-type': 'text/html' }); res.end(page); });
  try {
    const url = `http://127.0.0.1:${app.address().port}/`;
    const result = await checkWebBuild(url, { ...fast, allow: [`${apiOrigin}/v1`] });
    assert.ok(result.local.some((u) => u.startsWith(`${apiOrigin}/`)), JSON.stringify(result));
    assert.deepEqual(result.foreign, ['https://tracker.example.net/t.png']);
    assert.equal(result.ok, false);
  } finally {
    app.close();
    api.close();
  }
});
