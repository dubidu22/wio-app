// Loads a built web app in headless Chromium and fails if the page requests
// anything from a host other than the local test server (D-40, INV-04).
// Requests to other hosts are recorded and aborted, so the check itself
// never contacts a third party.
//
// Usage: node tools/ci/web-network-check.mjs app/build/web
import { fileURLToPath } from 'node:url';
import { openLocalApp, waitForFlutter } from './lib/web-serve.mjs';

/**
 * Serves `dir`, opens it in Chromium and returns what the page requested.
 * @returns {Promise<{ok: boolean, local: string[], foreign: string[], error: string | null}>}
 */
export async function checkWebBuild(dir, { startTimeoutMs = 60_000, settleMs = 5_000 } = {}) {
  const { context, origin, local, foreign, close } = await openLocalApp(dir);

  let error = null;
  try {
    const page = await context.newPage();
    await page.goto(origin, { waitUntil: 'load' });
    // The app has started once Flutter attaches its view to the page.
    await waitForFlutter(page, startTimeoutMs);
    // Give late requests (fonts, deferred engine parts) time to start.
    await page.waitForTimeout(settleMs);
  } catch (e) {
    error = `the app did not start: ${e.message.split('\n')[0]}`;
  } finally {
    await close();
  }

  if (error === null && local.length === 0) error = 'no requests at all: the check did not run';
  return { ok: error === null && foreign.length === 0, local, foreign, error };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const result = await checkWebBuild(process.argv[2] ?? 'app/build/web');
  console.log(`local requests: ${result.local.length}`);
  if (result.foreign.length > 0) {
    console.error('requests to other hosts (not allowed, D-40):');
    for (const url of result.foreign) console.error(`  ${url}`);
  }
  if (result.error) console.error(result.error);
  if (!result.ok) process.exit(1);
  console.log('no requests left the local server');
}
