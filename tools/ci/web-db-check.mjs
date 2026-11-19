// Loads a built web app in headless Chromium and fails unless the app's local
// database opens in the browser (D-70, D-87): a database named `wio` must
// appear in IndexedDB or in the origin-private file system (OPFS), and no page
// error or console error may mention drift, sqlite, the worker or wasm.
// Requests to other hosts are aborted, as in web-network-check.mjs, and
// anything the hosting's Content-Security-Policy blocks fails (D-366).
//
// Usage: node tools/ci/web-db-check.mjs app/build/web [database name]
//        node tools/ci/web-db-check.mjs --url https://app… (deployed app, D-368)
import { fileURLToPath } from 'node:url';
import { openTarget, parseArgs, waitForFlutter } from './lib/web-serve.mjs';

const DATABASE_ERROR = /drift|sqlite|worker|wasm/i;

/** Runs in the page: where the database `name` is stored, or null. */
async function findDatabase(name) {
  if (typeof indexedDB.databases === 'function') {
    const databases = await indexedDB.databases();
    if (databases.some((db) => db.name === name)) return 'IndexedDB';
  }
  try {
    // drift keeps OPFS databases under drift_db/<name>; accept the root too.
    const root = await navigator.storage.getDirectory();
    for await (const [entry, handle] of root.entries()) {
      if (entry === name) return 'OPFS';
      if (handle.kind === 'directory') {
        for await (const inner of handle.keys()) {
          if (inner === name) return 'OPFS';
        }
      }
    }
  } catch {
    // No OPFS in this browser context.
  }
  return null;
}

/**
 * Opens `target` (a build folder or a URL) in Chromium and reports where the
 * database is.
 * @returns {Promise<{ok: boolean, storage: string | null, errors: string[], error: string | null}>}
 */
export async function checkWebDatabase(
  target,
  { name = 'wio', startTimeoutMs = 60_000, databaseTimeoutMs = 30_000, settleMs = 2_000, headers = true } = {},
) {
  const { context, url, violations, close } = await openTarget(target, { headers });
  const errors = [];
  let storage = null;
  let error = null;
  try {
    const page = await context.newPage();
    page.on('pageerror', (e) => errors.push(`page error: ${e.message}`));
    page.on('console', (message) => {
      if (message.type() === 'error' && DATABASE_ERROR.test(message.text())) {
        errors.push(`console error: ${message.text()}`);
      }
    });
    await page.goto(url, { waitUntil: 'load' });
    try {
      await waitForFlutter(page, startTimeoutMs);
    } catch (e) {
      throw new Error(`the app did not start: ${e.message.split('\n')[0]}`);
    }
    const deadline = Date.now() + databaseTimeoutMs;
    while (storage === null && Date.now() < deadline && errors.length === 0) {
      storage = await page.evaluate(findDatabase, name);
      if (storage === null) await page.waitForTimeout(250);
    }
    if (storage === null && errors.length === 0) {
      error = `no database "${name}" in IndexedDB or OPFS after ${databaseTimeoutMs} ms`;
    } else {
      // Errors from the worker can arrive just after the database is created.
      await page.waitForTimeout(settleMs);
    }
  } catch (e) {
    error = e.message.split('\n')[0];
  } finally {
    await close();
  }
  errors.push(...violations);

  return { ok: error === null && errors.length === 0 && storage !== null, storage, errors, error };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const { target, rest } = parseArgs(process.argv.slice(2), 'app/build/web');
  const result = await checkWebDatabase(target, { name: rest[0] ?? 'wio' });
  for (const line of result.errors) console.error(line);
  if (result.error) console.error(result.error);
  if (!result.ok) process.exit(1);
  console.log(`the web database opened (${result.storage}) with no database errors`);
}
