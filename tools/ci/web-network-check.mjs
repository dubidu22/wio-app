// Loads a built web app in headless Chromium and fails if the page requests
// anything from a host other than the local test server (D-40, INV-04).
// Requests to other hosts are recorded and aborted, so the check itself
// never contacts a third party.
//
// Usage: node tools/ci/web-network-check.mjs app/build/web
import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const types = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.wasm': 'application/wasm', '.json': 'application/json', '.png': 'image/png',
  '.otf': 'font/otf', '.ttf': 'font/ttf', '.css': 'text/css',
};

function serve(root) {
  return createServer(async (req, res) => {
    const path = normalize(decodeURIComponent(new URL(req.url, 'http://x').pathname));
    let file = join(root, path);
    if (!file.startsWith(root + sep) && file !== root) {
      res.writeHead(403);
      res.end();
      return;
    }
    try {
      if ((await stat(file)).isDirectory()) file = join(file, 'index.html');
      const body = await readFile(file);
      res.writeHead(200, { 'content-type': types[extname(file)] ?? 'application/octet-stream' });
      res.end(body);
    } catch {
      res.writeHead(404);
      res.end();
    }
  });
}

/**
 * Serves `dir`, opens it in Chromium and returns what the page requested.
 * @returns {Promise<{ok: boolean, local: string[], foreign: string[], error: string | null}>}
 */
export async function checkWebBuild(dir, { startTimeoutMs = 60_000, settleMs = 5_000 } = {}) {
  const root = resolve(dir);
  const server = serve(root);
  await new Promise((ok) => server.listen(0, '127.0.0.1', ok));
  const origin = `http://127.0.0.1:${server.address().port}`;

  const browser = await chromium.launch();
  // Requests are watched on the context, so service-worker requests count too.
  const context = await browser.newContext();
  const local = [];
  const foreign = [];
  const isLocal = (url) => {
    if (url.startsWith('data:') || url.startsWith('blob:')) return true;
    try {
      return new URL(url).origin === origin;
    } catch {
      return false;
    }
  };
  context.on('request', (request) => {
    const url = request.url();
    (isLocal(url) ? local : foreign).push(url);
  });
  await context.route('**/*', (route) =>
    isLocal(route.request().url()) ? route.continue() : route.abort('blockedbyclient'),
  );

  let error = null;
  try {
    const page = await context.newPage();
    await page.goto(origin, { waitUntil: 'load' });
    // The app has started once Flutter attaches its view to the page.
    await page.waitForSelector('flutter-view', { state: 'attached', timeout: startTimeoutMs });
    // Give late requests (fonts, deferred engine parts) time to start.
    await page.waitForTimeout(settleMs);
  } catch (e) {
    error = `the app did not start: ${e.message.split('\n')[0]}`;
  } finally {
    await browser.close();
    server.close();
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
