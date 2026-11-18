// Loads the built web app in headless Chromium and fails if the page requests
// anything from a host other than the local test server (D-40, INV-04).
// Usage: node tools/ci/web-network-check.mjs app/build/web
import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize, resolve } from 'node:path';
import { chromium } from 'playwright';

const root = resolve(process.argv[2] ?? 'app/build/web');
const types = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.wasm': 'application/wasm', '.json': 'application/json', '.png': 'image/png',
  '.otf': 'font/otf', '.ttf': 'font/ttf', '.frag': 'application/octet-stream',
  '.bin': 'application/octet-stream', '.symbols': 'text/plain',
};

const server = createServer(async (req, res) => {
  const path = normalize(decodeURIComponent(new URL(req.url, 'http://x').pathname));
  let file = join(root, path);
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
await new Promise((ok) => server.listen(0, '127.0.0.1', ok));
const origin = `http://127.0.0.1:${server.address().port}`;

const browser = await chromium.launch();
const page = await browser.newPage();
const local = [];
const foreign = [];
page.on('request', (request) => {
  const url = request.url();
  if (url.startsWith(origin) || url.startsWith('data:') || url.startsWith('blob:')) {
    local.push(url);
  } else {
    foreign.push(url);
  }
});

let failure = null;
try {
  await page.goto(origin, { waitUntil: 'load' });
  // The app has rendered once Flutter attaches its view to the page.
  await page.waitForSelector('flutter-view', { state: 'attached', timeout: 60_000 });
  // Give late requests (fonts, deferred engine parts) time to start.
  await page.waitForTimeout(5_000);
} catch (error) {
  failure = `the app did not start: ${error.message}`;
}
await browser.close();
server.close();

console.log(`local requests: ${local.length}`);
if (foreign.length > 0) {
  console.error('requests to other hosts (not allowed, D-40):');
  for (const url of foreign) console.error(`  ${url}`);
  process.exit(1);
}
if (failure) {
  console.error(failure);
  process.exit(1);
}
if (local.length === 0) {
  console.error('no requests at all: the check did not run');
  process.exit(1);
}
console.log('no requests left the local server');
