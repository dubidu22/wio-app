#!/usr/bin/env bash
# Tests of the web deploy (plan 080, D-369): web-host.sh, web-deploy.sh and
# web-smoke.sh against a local stand-in of the hosting. Runs in CI's tools job.
#
# Stand-ins: a fake `ssh` that runs the remote command locally (OpenSSH
# itself is proven by the API deploy), and a small Python server that serves
# the document root the way the .htaccess asks for: every request into
# r/<live>/, /r/ and folder paths 404, the template's headers on every
# answer. Apache itself is proven on staging (T3, D-371).
#
# Usage: web-deploy.test.sh     (KEEP_WORK=1 keeps the work directory)
#
# The checks read "CONDITION && ok … || bad …": ok and bad always succeed, so
# the || part runs only when the condition fails (SC2015). Release folders
# are sha names (SC2012). Single-quoted patterns are grep regexes (SC2016).
# shellcheck disable=SC2015,SC2012,SC2016
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
deploy="$repo/tools/deploy"
work="$(mktemp -d)"
server_pid=""

cleanup() {
  if [[ -n "$server_pid" ]]; then kill "$server_pid" 2> /dev/null || true; fi
  if [[ "${KEEP_WORK:-}" == 1 ]]; then echo "kept $work"; else rm -rf -- "${work:?}"; fi
}
trap cleanup EXIT

failures=0
ok() { echo "ok   $*"; }
bad() { echo "FAIL $*"; failures=$((failures + 1)); }

htdocs="$work/www/htdocs/w0000000"
root="$htdocs/wio-web-staging"
mkdir -p "$work/bin" "$htdocs"

cat > "$work/bin/ssh" << 'SSH'
#!/usr/bin/env bash
# Fake ssh: drops options, runs the remote command with bash locally.
while [[ $# -gt 0 ]]; do
  case "$1" in
    -O) exit 0 ;;
    -i | -p | -o) shift 2 ;;
    -*) shift ;;
    *) break ;;
  esac
done
shift # user@host
exec bash -c "$*"
SSH
chmod +x "$work/bin/ssh"
export PATH="$work/bin:$PATH"

# The hosting stand-in: serves $root/web as the .htaccess there describes.
cat > "$work/server.py" << 'PY'
import http.server, os, re, sys

docroot = sys.argv[1]
types = {'.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.wasm': 'application/wasm',
         '.json': 'application/json', '.txt': 'text/plain; charset=utf-8'}

def rules():
    try:
        text = open(os.path.join(docroot, '.htaccess')).read()
    except FileNotFoundError:
        return None, [], []
    live = re.search(r'^RewriteRule \^\$ r/([0-9a-f]+)/index\.html', text, re.M).group(1)
    always, files, pattern = [], [], None
    for line in text.splitlines():
        m = re.match(r'<FilesMatch "(.*)">', line.strip())
        if m:
            pattern = re.compile(m.group(1))
        elif line.strip() == '</FilesMatch>':
            pattern = None
        m = re.match(r'^(\s*)Header always set (\S+) "(.*)"$', line)
        if m and pattern is None and m.group(1) == '':
            always.append((m.group(2), m.group(3)))
        elif m and pattern is not None:
            files.append((pattern, m.group(2), m.group(3)))
    return live, always, files

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_GET(self):
        live, always, files = rules()
        path = self.path.split('?')[0].lstrip('/')
        body, status, ctype = b'', 404, 'text/plain'
        if live and not re.match(r'^r(/|$)', path) and not re.match(r'^.+/$', path):
            name = path or 'index.html'
            file = os.path.join(docroot, 'r', live, name)
            if os.path.isfile(file):
                body, status = open(file, 'rb').read(), 200
                ctype = types.get(os.path.splitext(name)[1], 'application/octet-stream')
        headers = dict((k.lower(), (k, v)) for k, v in always)
        base = os.path.basename(path or 'index.html')
        for pattern, k, v in files:
            if pattern.search(base):
                headers[k.lower()] = (k, v)
        self.send_response(status)
        self.send_header('Content-Type', ctype)
        for k, v in headers.values():
            self.send_header(k, v)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Handler)
open(sys.argv[2], 'w').write(str(server.server_address[1]))
server.serve_forever()
PY
python3 "$work/server.py" "$root/web" "$work/port" &
server_pid=$!
for _ in $(seq 50); do [[ -s "$work/port" ]] && break; sleep 0.1; done
port="$(cat "$work/port")"

# release SHA VERSION BUILD: a fake web build tarball for SHA.
release() {
  local sha="$1" version="$2" build="$3" dir="$work/build-$1"
  mkdir -p "$dir/canvaskit"
  printf '<!DOCTYPE html><title>wio</title><script src="flutter_bootstrap.js" async></script>\n' > "$dir/index.html"
  printf 'console.log(1)\n' > "$dir/main.dart.js"
  printf '\0asm' > "$dir/main.dart.wasm"
  printf '\0asm' > "$dir/sqlite3.wasm"
  printf '{"app_name":"wio","version":"%s","build_number":"%s","package_name":"wio"}\n' "$version" "$build" > "$dir/version.json"
  printf '%s\n' "$sha" > "$dir/release.txt"
  tar -C "$dir" -czf "$work/$sha.tar.gz" .
}

export WIO_ENVIRONMENT=staging
export WIO_SSH_HOST=localhost WIO_SSH_USER=deploy
export WIO_SSH_KEY_FILE=/dev/null WIO_SSH_KNOWN_HOSTS_FILE=/dev/null
export WIO_WEB_DEPLOY_PATH="$root"
export WIO_WEB_ORIGIN="http://127.0.0.1:$port"
export WIO_API_URL="https://api-staging.example.org/"
export WIO_KEEP_RELEASES=3
export WIO_WEB_SMOKE_SKIP_HTTPS=1

# web-deploy.sh's smoke reads app/pubspec.yaml of the repo; the fake builds
# carry that version so the real smoke test runs.
repo_version="$(sed -n 's/^version:[[:space:]]*\([0-9.]*\).*/\1/p' "$repo/app/pubspec.yaml")"
repo_build="$(sed -n 's/^version:[[:space:]]*[0-9.]*+\([0-9]*\).*/\1/p' "$repo/app/pubspec.yaml")"

run() { "$deploy/web-deploy.sh" "$@" > "$work/last.log" 2>&1; }
state() { cat "$root/$1" 2> /dev/null || true; }
host() { bash "$deploy/web-host.sh" "$@" > "$work/host.log" 2>&1; }

# --- D-362: the folder guard -------------------------------------------------

printf '<html>business website</html>\n' > "$htdocs/index.html"
mkdir -p "$htdocs/wio-staging/web" "$htdocs/wio-staging/releases"
printf 'x\n' > "$htdocs/wio-staging/web/index.php"
mkdir -p "$htdocs/wio-web-foreign"
printf 'someone else\n' > "$htdocs/wio-web-foreign/index.html"
mkdir -p "$htdocs/wio-web-target"
ln -s "$htdocs/wio-web-target" "$htdocs/wio-web-link"
# F3: a missing parent is never created, and a symlinked parent is refused.
mkdir -p "$htdocs/shop"
ln -s "$htdocs/shop" "$htdocs/shop-link"

for path in "$htdocs" "$htdocs/" "$htdocs/wio-staging" "$htdocs/wio-web-foreign" \
  "$htdocs/wio-web-link" "$htdocs/wio-web-staging/../wio-staging" "wio-web-relative" \
  "$htdocs/no-such-folder/wio-web-staging" "$htdocs/shop/missing/wio-web-staging" \
  "$htdocs/shop-link/wio-web-staging"; do
  before="$(find "$htdocs" | sort | md5sum)"
  if host prepare "$path"; then
    bad "guard: prepare accepted $path"
  elif [[ "$(find "$htdocs" | sort | md5sum)" != "$before" ]]; then
    bad "guard: prepare refused $path but changed files"
  else
    ok "guard: refuses $path ($(head -n 1 "$work/host.log"))"
  fi
done
WIO_WEB_DEPLOY_PATH="$htdocs" run deploy "$work/none.tar.gz" aaaaaaa && bad "guard: web-deploy.sh deployed into the business website folder" ||
  { grep -q "wio-web-" "$work/last.log" && ok "guard: web-deploy.sh stops before touching the business website folder" || bad "guard: unexpected error $(tail -n 2 "$work/last.log")"; }
[[ "$(cat "$htdocs/index.html")" == "<html>business website</html>" ]] && ok "guard: the business website's index.html is unchanged" || bad "guard: business website changed"

mkdir -p "$htdocs/wio-web-empty-web/web"
if host prepare "$htdocs/wio-web-empty-web" && [[ -f "$htdocs/wio-web-empty-web/.wio-web-deploy" ]]; then
  ok "guard: accepts a folder with only the empty web/ that KAS needs"
else
  bad "guard: refused a folder with only an empty web/: $(cat "$work/host.log")"
fi
host unpack "$htdocs/wio-web-unprepared" abcdef1 && bad "guard: unpack ran without the marker" || ok "guard: commands other than prepare need the marker"

# --- render (D-361, D-364) ---------------------------------------------------

release 1111111 "$repo_version" "$repo_build"
if run deploy "$work/1111111.tar.gz" 1111111; then
  ok "first deploy: smoke test passed"
else
  bad "first deploy failed: $(tail -n 5 "$work/last.log")"
fi
htaccess="$root/web/.htaccess"
grep -q '^RewriteRule \^(\.+)\$ r/1111111/\$1 \[END\]$' "$htaccess" && ok "render: requests map into r/1111111/" || bad "render: rewrite rule"
grep -q "connect-src 'self' https://api-staging.example.org;" "$htaccess" && ok "render: CSP allows exactly the API origin" || bad "render: connect-src $(grep -o 'connect-src[^;]*' "$htaccess")"
grep -q '@' "$htaccess" && bad "render: a placeholder is left" || ok "render: no placeholder left"
grep '^Header always set Strict-Transport-Security' "$htaccess" | grep -q 'includeSubDomains' && bad "render: HSTS includes subdomains" || ok "render: HSTS leaves other subdomains alone"
[[ "$(state live)" == 1111111 && -z "$(state previous)" ]] && ok "first deploy: live 1111111, no previous" || bad "first deploy: live '$(state live)' previous '$(state previous)'"
[[ ! -e "$root/web/r/1111111/flutter_service_worker.js" ]] || bad "service worker present"

# --- switch, smoke, switch back (D-361, D-367) -------------------------------

release 2222222 "$repo_version" "$repo_build"
run deploy "$work/2222222.tar.gz" 2222222 && ok "second deploy passed" || bad "second deploy failed: $(tail -n 5 "$work/last.log")"
[[ "$(state live)" == 2222222 && "$(state previous)" == 1111111 ]] && ok "second deploy: live 2222222, previous 1111111" || bad "second deploy: live '$(state live)' previous '$(state previous)'"
[[ "$(curl -sS "$WIO_WEB_ORIGIN/release.txt")" == 2222222 ]] && ok "the server answers from the new release" || bad "server still on the old release"

release 3333333 0.0.1 "$repo_build"
if run deploy "$work/3333333.tar.gz" 3333333; then
  bad "a release with the wrong version.json passed the smoke test"
else
  grep -q 'W3 version.json' "$work/last.log" && ok "smoke W3 fails on a version that is not pubspec's" || bad "W3 not the failure: $(grep error "$work/last.log" | head -n 3)"
  [[ "$(state live)" == 2222222 && "$(state previous)" == 1111111 ]] && ok "failed smoke switched back to 2222222 (previous stays 1111111)" || bad "after failed smoke: live '$(state live)' previous '$(state previous)'"
  [[ "$(curl -sS "$WIO_WEB_ORIGIN/release.txt")" == 2222222 ]] && ok "the server answers from 2222222 again" || bad "server not switched back"
fi

# W2: a header missing on the host, and a header sent twice, both fail.
cp "$htaccess" "$work/good.htaccess"
grep -v 'X-Content-Type-Options' "$work/good.htaccess" > "$htaccess"
"$deploy/web-smoke.sh" "$WIO_WEB_ORIGIN" 2222222 "$work/good.htaccess" "$repo/app/pubspec.yaml" > "$work/smoke.log" 2>&1 &&
  bad "smoke passed with a missing header" ||
  { grep -q 'X-Content-Type-Options appears 0 times' "$work/smoke.log" && ok "smoke W2 fails on a missing header" || bad "W2 missing header: $(grep error "$work/smoke.log" | head -n 2)"; }
{ cat "$work/good.htaccess"; echo 'Header always set Strict-Transport-Security "max-age=31536000"'; } > "$htaccess"
sed -i 's/^\(Header always set Strict-Transport-Security\) "max-age=31536000"$/\1 "max-age=1"/' "$htaccess"
"$deploy/web-smoke.sh" "$WIO_WEB_ORIGIN" 2222222 "$work/good.htaccess" "$repo/app/pubspec.yaml" > "$work/smoke.log" 2>&1 &&
  bad "smoke passed with a changed header" ||
  { grep -q "Strict-Transport-Security is 'max-age=1'" "$work/smoke.log" && ok "smoke W2 fails on a header that differs from the template" || bad "W2 changed header: $(grep error "$work/smoke.log" | head -n 2)"; }
cp "$work/good.htaccess" "$htaccess"
"$deploy/web-smoke.sh" "$WIO_WEB_ORIGIN" 1111111 "$work/good.htaccess" "$repo/app/pubspec.yaml" > "$work/smoke.log" 2>&1 &&
  bad "smoke passed for a release that is not live" ||
  { grep -q 'W1 release.txt' "$work/smoke.log" && ok "smoke W1 fails when the expected release is not live" || bad "W1: $(grep error "$work/smoke.log" | head -n 2)"; }
grep -q '^ok    W5' <("$deploy/web-smoke.sh" "$WIO_WEB_ORIGIN" 2222222 "$work/good.htaccess" "$repo/app/pubspec.yaml" 2>&1) &&
  ok "smoke W5: release folders are not reachable directly" || bad "W5 did not pass"
# F2: release.txt must be no-store too.
sed 's/version\\.json|release\\.txt/version\\.json/' "$work/good.htaccess" > "$htaccess"
grep -q 'FilesMatch "^(version\\.json)\$"' "$htaccess" || bad "F2 fixture: FilesMatch not narrowed"
"$deploy/web-smoke.sh" "$WIO_WEB_ORIGIN" 2222222 "$work/good.htaccess" "$repo/app/pubspec.yaml" > "$work/smoke.log" 2>&1 &&
  bad "smoke passed with a cacheable release.txt" ||
  { grep -q "W1 release.txt: header Cache-Control is 'no-cache'" "$work/smoke.log" && ok "smoke W1 fails when release.txt may be cached" || bad "W1 no-store: $(grep error "$work/smoke.log" | head -n 2)"; }
cp "$work/good.htaccess" "$htaccess"

# First deploy with a failing smoke: nothing to switch back to, run fails.
first="$htdocs/wio-web-first"
WIO_WEB_DEPLOY_PATH="$first" WIO_WEB_SMOKE=false run deploy "$work/1111111.tar.gz" 1111111 &&
  bad "first deploy with failing smoke passed" ||
  { grep -q 'no earlier release' "$work/last.log" && ok "first deploy with failing smoke fails and says nothing was switched back" || bad "first failing deploy: $(tail -n 3 "$work/last.log")"; }

# --- rollback ----------------------------------------------------------------

run rollback && ok "rollback to previous passed its smoke test" || bad "rollback failed: $(tail -n 5 "$work/last.log")"
[[ "$(state live)" == 1111111 && "$(curl -sS "$WIO_WEB_ORIGIN/release.txt")" == 1111111 ]] && ok "rollback: 1111111 is live and served" || bad "rollback: live '$(state live)'"

# --- prune -------------------------------------------------------------------

for sha in 4444444 5555555 6666666 7777777; do
  release "$sha" "$repo_version" "$repo_build"
  sleep 1 # ls -t needs distinct times
  run deploy "$work/$sha.tar.gz" "$sha" || bad "deploy $sha failed: $(tail -n 3 "$work/last.log")"
done
kept="$(ls "$root/web/r" | sort | paste -sd ' ')"
[[ "$kept" == "5555555 6666666 7777777" ]] && ok "prune keeps the 3 newest releases (live and previous among them)" || bad "prune kept: $kept"
[[ "$(ls "$root/htaccess" | sort | paste -sd ' ')" == "$kept" ]] && ok "prune removes the .htaccess of removed releases" || bad "htaccess left: $(ls "$root/htaccess")"
[[ -z "$(ls -A "$root/incoming")" ]] && ok "no upload is left in incoming/" || bad "incoming: $(ls -A "$root/incoming")"
[[ "$(stat -c %a "$root/web/.htaccess")" == 644 ]] && ok ".htaccess is readable by the web server" || bad ".htaccess mode $(stat -c %a "$root/web/.htaccess")"

if [[ "$failures" -gt 0 ]]; then
  echo "$failures check(s) failed"
  exit 1
fi
echo "all checks pass"
