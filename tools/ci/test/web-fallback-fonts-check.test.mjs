// Tests for web-fallback-fonts-check.mjs (issue #15, D-86): the check must
// fail on a missing file, a stale file, a missing font table and a build
// that would fetch fallback fonts from Google.
// Run: node --test tools/ci/test/web-fallback-fonts-check.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
import { checkFallbackFonts } from '../web-fallback-fonts-check.mjs';

const fixture = (name) => fileURLToPath(new URL(`./fixtures/${name}`, import.meta.url));

test('a build that bundles every asked-for file passes', () => {
  const result = checkFallbackFonts(fixture('fonts-ok'));
  assert.equal(result.ok, true, JSON.stringify(result));
  assert.equal(result.checked, 2);
});

test('a file the engine asks for but the build lacks fails', () => {
  const result = checkFallbackFonts(fixture('fonts-missing'));
  assert.equal(result.ok, false);
  assert.ok(result.errors.some((e) => e.startsWith('missing: notocoloremoji/v39/abc.1.woff2')), JSON.stringify(result));
});

test('a bundled file the engine no longer asks for fails', () => {
  const result = checkFallbackFonts(fixture('fonts-stale'));
  assert.equal(result.ok, false);
  assert.ok(result.errors.some((e) => e.startsWith('stale: notocoloremoji/v39/old.0.woff2')), JSON.stringify(result));
});

test('a build without the engine font table fails', () => {
  const result = checkFallbackFonts(fixture('fonts-no-table'));
  assert.equal(result.ok, false);
  assert.ok(result.errors.some((e) => e.includes('font table was not found')), JSON.stringify(result));
});

test('a build without the local fontFallbackBaseUrl fails', () => {
  const result = checkFallbackFonts(fixture('fonts-gstatic'));
  assert.equal(result.ok, false);
  assert.ok(result.errors.some((e) => e.includes('fontFallbackBaseUrl')), JSON.stringify(result));
});

test('an empty folder fails', () => {
  const result = checkFallbackFonts(fixture('does-not-exist'));
  assert.equal(result.ok, false);
});
