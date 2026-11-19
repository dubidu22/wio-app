// Loads a built web app in headless Chromium and fails if the page requests
// anything from a host other than the local test server (D-40, INV-04), or
// if the hosting's Content-Security-Policy blocks anything (D-366).
// Requests to other hosts are recorded and aborted, so the check itself
// never contacts a third party.
//
// Usage: node tools/ci/web-network-check.mjs app/build/web
//        node tools/ci/web-network-check.mjs --url https://app… --allow https://api…
//        (the deployed app, D-368: its own origin and the API are allowed)
import { fileURLToPath } from 'node:url';
import { openTarget, parseArgs, waitForFlutter } from './lib/web-serve.mjs';

/**
 * Opens `target` (a build folder or a URL) in Chromium and returns what the
 * page requested.
 * @returns {Promise<{ok: boolean, local: string[], foreign: string[], violations: string[], error: string | null}>}
 */
export async function checkWebBuild(
  target,
  { startTimeoutMs = 60_000, settleMs = 5_000, allow = [], headers = true } = {},
) {
  const { context, url, local, foreign, violations, close } = await openTarget(target, { allow, headers });

  let error = null;
  try {
    const page = await context.newPage();
    await page.goto(url, { waitUntil: 'load' });
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
  return {
    ok: error === null && foreign.length === 0 && violations.length === 0,
    local, foreign, violations, error,
  };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const { target, allow } = parseArgs(process.argv.slice(2), 'app/build/web');
  const result = await checkWebBuild(target, { allow });
  console.log(`local requests: ${result.local.length}`);
  if (result.foreign.length > 0) {
    console.error('requests to other hosts (not allowed, D-40):');
    for (const url of result.foreign) console.error(`  ${url}`);
  }
  if (result.violations.length > 0) {
    console.error('blocked by the Content-Security-Policy (D-364, D-366):');
    for (const line of result.violations) console.error(`  ${line}`);
  }
  if (result.error) console.error(result.error);
  if (!result.ok) process.exit(1);
  console.log('no requests left the allowed origins and nothing was blocked by the CSP');
}
