// Tests for the header half of web-serve.mjs (D-364, D-366): CI's local
// server must send exactly what the hosting's .htaccess template sets.
// Run: node --test tools/ci/test/web-headers.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { HTACCESS_TEMPLATE, headersFor, templateHeaders } from '../lib/web-serve.mjs';

test('every answer gets the template headers, no-cache by default', () => {
  const headers = headersFor('index.html', templateHeaders());
  assert.equal(headers['Cache-Control'], 'no-cache');
  assert.equal(headers['X-Content-Type-Options'], 'nosniff');
  assert.equal(headers['Referrer-Policy'], 'no-referrer');
  assert.equal(headers['Strict-Transport-Security'], 'max-age=31536000');
  assert.match(headers['Content-Security-Policy'], /^default-src 'self'; script-src 'self' 'wasm-unsafe-eval';/);
  assert.match(headers['Content-Security-Policy'], /frame-ancestors 'none'$/);
});

test('version.json and release.txt are never stored (D-363)', () => {
  const parsed = templateHeaders();
  assert.equal(headersFor('version.json', parsed)['Cache-Control'], 'no-store');
  assert.equal(headersFor('release.txt', parsed)['Cache-Control'], 'no-store');
  assert.equal(headersFor('main.dart.js', parsed)['Cache-Control'], 'no-cache');
  assert.equal(headersFor('xversion.json', parsed)['Cache-Control'], 'no-cache');
});

test('connect-src is the own origin plus exactly the API origin', () => {
  const none = headersFor('index.html', templateHeaders())['Content-Security-Policy'];
  assert.match(none, /connect-src 'self';/);
  const api = headersFor('index.html', templateHeaders('https://api-staging.example.org'))['Content-Security-Policy'];
  assert.match(api, /connect-src 'self' https:\/\/api-staging\.example\.org;/);
});

test('HSTS never covers other subdomains (the business website)', () => {
  const lines = readFileSync(HTACCESS_TEMPLATE, 'utf8').split('\n').filter((l) => /Strict-Transport-Security/.test(l) && !l.startsWith('#'));
  assert.equal(lines.length, 1);
  assert.doesNotMatch(lines[0], /includeSubDomains|preload/);
});

test('every Header line in the template is in the parsed form', () => {
  const text = readFileSync(HTACCESS_TEMPLATE, 'utf8');
  const all = text.split('\n').filter((l) => /^\s*Header\b/.test(l));
  const parsed = templateHeaders();
  assert.equal(all.length, parsed.always.length + parsed.files.length, 'a Header line the parsers would skip');
});
