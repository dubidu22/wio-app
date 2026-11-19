// Serves a built web app on 127.0.0.1, or points at a deployed one, and opens
// a headless Chromium context in which every request to another host is
// recorded and aborted, so a check never contacts a third party (D-40,
// INV-04). Shared by web-network-check.mjs and web-db-check.mjs.
//
// The local server sends the headers of the hosting's .htaccess template
// (tools/deploy/web/htaccess.template, D-366), so every check runs under the
// same Content-Security-Policy as the deployed app; CSP violations are
// collected and fail the checks.
import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { readFile, stat } from 'node:fs/promises';
import { basename, extname, join, normalize, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const types = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.wasm': 'application/wasm', '.json': 'application/json', '.png': 'image/png',
  '.otf': 'font/otf', '.ttf': 'font/ttf', '.css': 'text/css', '.txt': 'text/plain',
};

export const HTACCESS_TEMPLATE = fileURLToPath(new URL('../../deploy/web/htaccess.template', import.meta.url));

/**
 * The headers of the .htaccess template, rendered for `apiOrigin` ('' = none).
 * Unindented `Header always set` lines apply to every answer; indented ones
 * inside `<FilesMatch "re">` to files whose name matches.
 * @returns {{always: [string, string][], files: [RegExp, string, string][]}}
 */
export function templateHeaders(apiOrigin = '', file = HTACCESS_TEMPLATE) {
  const always = [];
  const files = [];
  let pattern = null;
  for (const line of readFileSync(file, 'utf8').split('\n')) {
    const open = line.trim().match(/^<FilesMatch "(.*)">$/);
    if (open) pattern = new RegExp(open[1]);
    else if (line.trim() === '</FilesMatch>') pattern = null;
    const header = line.match(/^(\s*)Header always set (\S+) "(.*)"$/);
    if (!header) continue;
    const value = header[3].replaceAll('@API_ORIGIN@', apiOrigin ? ` ${apiOrigin}` : '');
    if (pattern === null && header[1] === '') always.push([header[2], value]);
    else if (pattern !== null) files.push([pattern, header[2], value]);
  }
  if (always.length === 0) throw new Error(`no headers in ${file}`);
  return { always, files };
}

/** The headers for one file name. */
export function headersFor(name, { always, files }) {
  const result = new Map(always.map(([k, v]) => [k.toLowerCase(), [k, v]]));
  for (const [pattern, k, v] of files) {
    if (pattern.test(name)) result.set(k.toLowerCase(), [k, v]);
  }
  return Object.fromEntries([...result.values()]);
}

function serve(root, headers) {
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
      res.writeHead(200, {
        ...(headers ? headersFor(basename(file), headers) : {}),
        'content-type': types[extname(file)] ?? 'application/octet-stream',
      });
      res.end(body);
    } catch {
      res.writeHead(404);
      res.end();
    }
  });
}

/**
 * Serves `dir` (with the template's headers unless `headers: false`) and
 * opens a browser context on it.
 */
export async function openLocalApp(dir, { headers = true } = {}) {
  const root = resolve(dir);
  const server = serve(root, headers ? templateHeaders() : null);
  await new Promise((ok) => server.listen(0, '127.0.0.1', ok));
  const origin = `http://127.0.0.1:${server.address().port}`;
  const app = await openApp(origin, []);
  return { ...app, close: async () => { await app.close(); server.close(); } };
}

/**
 * Opens a browser context on a deployed app at `url` (D-368). Requests to
 * its own origin and to the `allow` origins (the API) go through; every
 * other request is recorded as foreign and aborted.
 */
export async function openRemoteApp(url, { allow = [] } = {}) {
  return openApp(new URL(url).origin, allow.map((u) => new URL(u).origin), url);
}

/**
 * @returns {Promise<{context: import('playwright').BrowserContext, origin: string, url: string,
 *   local: string[], foreign: string[], violations: string[], close: () => Promise<void>}>}
 */
async function openApp(origin, allowed, url = origin) {
  const browser = await chromium.launch();
  // Requests are watched on the context, so service-worker requests count too.
  const context = await browser.newContext();
  const local = [];
  const foreign = [];
  const violations = [];
  const isLocal = (u) => {
    if (u.startsWith('data:') || u.startsWith('blob:')) return true;
    try {
      const o = new URL(u).origin;
      return o === origin || allowed.includes(o);
    } catch {
      return false;
    }
  };
  context.on('request', (request) => {
    const u = request.url();
    (isLocal(u) ? local : foreign).push(u);
  });
  await context.route('**/*', (route) =>
    isLocal(route.request().url()) ? route.continue() : route.abort('blockedbyclient'),
  );
  // D-366: anything the Content-Security-Policy blocks fails the check.
  await context.exposeBinding('__wioCspViolation', (_source, text) => violations.push(text));
  await context.addInitScript(() => {
    document.addEventListener('securitypolicyviolation', (e) => {
      window.__wioCspViolation(`CSP blocked ${e.blockedURI || 'inline'} (${e.violatedDirective})`);
    });
  });
  context.on('console', (message) => {
    if (/Content Security Policy/i.test(message.text())) violations.push(`console: ${message.text()}`);
  });

  const close = async () => {
    await browser.close();
  };
  return { context, origin, url, local, foreign, violations, close };
}

/** A local build folder or, for `http(s)://…`, a deployed app. */
export function openTarget(target, { allow = [], headers = true } = {}) {
  return /^https?:\/\//.test(target) ? openRemoteApp(target, { allow }) : openLocalApp(target, { headers });
}

/**
 * Command line of the checks: `DIR` or `--url URL [--allow ORIGIN]...`.
 * @returns {{target: string, allow: string[], rest: string[]}}
 */
export function parseArgs(argv, defaultDir) {
  const allow = [];
  const rest = [];
  let target = null;
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--url') target = argv[++i];
    else if (argv[i] === '--allow') allow.push(argv[++i]);
    else if (target === null) target = argv[i];
    else rest.push(argv[i]);
  }
  return { target: target ?? defaultDir, allow, rest };
}

/** Waits until Flutter has attached its view to the page. */
export async function waitForFlutter(page, timeout) {
  await page.waitForSelector('flutter-view', { state: 'attached', timeout });
}
