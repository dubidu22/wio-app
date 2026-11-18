// Serves a built web app on 127.0.0.1 and opens a headless Chromium context
// in which every request to another host is recorded and aborted, so a check
// never contacts a third party (D-40, INV-04). Shared by web-network-check.mjs
// and web-db-check.mjs.
import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize, resolve, sep } from 'node:path';
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
 * Serves `dir` and opens a browser context on it.
 * @returns {Promise<{context: import('playwright').BrowserContext, origin: string,
 *   local: string[], foreign: string[], close: () => Promise<void>}>}
 */
export async function openLocalApp(dir) {
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

  const close = async () => {
    await browser.close();
    server.close();
  };
  return { context, origin, local, foreign, close };
}

/** Waits until Flutter has attached its view to the page. */
export async function waitForFlutter(page, timeout) {
  await page.waitForSelector('flutter-view', { state: 'attached', timeout });
}
