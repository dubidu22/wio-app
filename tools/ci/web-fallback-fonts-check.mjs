// Checks a built web app against its bundled fallback fonts (issue #15,
// D-40). Flutter's web engine fetches a Noto font for glyphs Roboto lacks,
// at `fontFallbackBaseUrl` + a path from its own font table. The app serves
// some of those families itself from assets/fallback-fonts/. This check
// fails when a path the engine asks for is missing (for example after a
// Flutter upgrade changed the font versions), when a bundled file is no
// longer asked for, or when the engine's font table cannot be found, so the
// check never passes without checking.
//
// Usage: node tools/ci/web-fallback-fonts-check.mjs app/build/web
import { readdirSync, readFileSync, existsSync, statSync } from 'node:fs';
import { join, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const FONT_DIR = join('assets', 'fallback-fonts');
const BASE_URL = 'assets/fallback-fonts/';

function filesUnder(dir) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const path = join(dir, entry.name);
    return entry.isDirectory() ? filesUnder(path) : [path];
  });
}

/**
 * @returns {{ok: boolean, errors: string[], checked: number}}
 */
export function checkFallbackFonts(buildDir) {
  const errors = [];
  const fontRoot = join(buildDir, FONT_DIR);
  const bundled = filesUnder(fontRoot)
    .map((path) => relative(fontRoot, path).split(sep).join('/'))
    .filter((path) => path.endsWith('.woff2'));
  const families = [...new Set(bundled.map((path) => path.split('/')[0]))];
  if (families.length === 0) errors.push(`no fallback fonts under ${FONT_DIR}`);

  const bootstrap = join(buildDir, 'flutter_bootstrap.js');
  if (!existsSync(bootstrap) || !readFileSync(bootstrap, 'utf8').includes(`fontFallbackBaseUrl: "${BASE_URL}"`)) {
    errors.push(`flutter_bootstrap.js does not set fontFallbackBaseUrl to "${BASE_URL}"`);
  }

  // The engine's font table, from the JavaScript and the WebAssembly build.
  const compiled = ['main.dart.js', 'main.dart.wasm']
    .map((name) => join(buildDir, name))
    .filter((path) => existsSync(path) && statSync(path).isFile())
    .map((path) => readFileSync(path, 'latin1'))
    .join('\n');
  const pathPattern = /\b([a-z0-9]+\/v\d+\/[A-Za-z0-9_-]+(?:\.\d+)?\.woff2)\b/g;
  const asked = new Set([...compiled.matchAll(pathPattern)].map((m) => m[1]));
  if (![...asked].some((path) => path.startsWith('notocoloremoji/'))) {
    errors.push('the engine font table was not found in main.dart.js or main.dart.wasm');
  }

  const wanted = [...asked].filter((path) => families.includes(path.split('/')[0]));
  const have = new Set(bundled);
  for (const path of wanted) {
    if (!have.has(path)) errors.push(`missing: ${path} (the engine asks for it)`);
  }
  const wantedSet = new Set(wanted);
  for (const path of bundled) {
    if (!wantedSet.has(path)) errors.push(`stale: ${path} (the engine no longer asks for it)`);
  }
  return { ok: errors.length === 0, errors, checked: wanted.length };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const result = checkFallbackFonts(process.argv[2] ?? 'app/build/web');
  for (const error of result.errors) console.error(error);
  if (!result.ok) {
    console.error('see app/web/assets/fallback-fonts/README.md to refresh the fonts');
    process.exit(1);
  }
  console.log(`all ${result.checked} fallback font files the engine asks for are bundled`);
}
