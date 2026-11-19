#!/usr/bin/env bash
# Smoke test of the deployed web app over HTTPS (plan 080, D-367).
#
# Usage: web-smoke.sh ORIGIN SHA HTACCESS PUBSPEC
#   ORIGIN    https://… of the web app (WIO_WEB_ORIGIN)
#   SHA       the release that must be live
#   HTACCESS  the rendered .htaccess of that release: its unindented
#             "Header always set" lines are the headers every answer must carry
#   PUBSPEC   app/pubspec.yaml of that release (the version.json check), or
#             - when it is not at hand (rollback): any well-formed version
#
#   W1 /release.txt is SHA (the switch took effect)
#   W2 / is the app's HTML with every header exactly once and as written
#   W3 /version.json has the pubspec version and is never cached
#   W4 wasm files are application/wasm, main.dart.js is JavaScript
#   W5 the release folders are not reachable directly
#   W6 http:// redirects to https://
#
# WIO_WEB_SMOKE_SKIP_HTTPS=1 (local test only): the test server speaks plain
# HTTP, so W6 cannot pass there. curl checks TLS certificates otherwise.
set -euo pipefail

origin="${1:?usage: web-smoke.sh ORIGIN SHA HTACCESS PUBSPEC}"
origin="${origin%/}"
sha="${2:?sha}"
htaccess="${3:?htaccess}"
pubspec="${4:?pubspec}"

work="$(mktemp -d)"
trap 'rm -rf -- "${work:?}"' EXIT
failures=0

pass() { echo "ok    $*"; }
fail() { echo "::error::web smoke: $*"; failures=$((failures + 1)); }

# get PATH [curl args...]: sets status; headers and body in files.
get() {
  local path="$1"
  shift
  : > "$work/headers"
  : > "$work/body"
  status="$(curl -sS --max-time 60 --compressed -D "$work/headers" -o "$work/body" \
    -w '%{http_code}' "$@" "$origin$path")" || status=curl-error
}

# values NAME: every value of header NAME in the last answer, one per line.
values() {
  { grep -i "^$1:" "$work/headers" || true; } | cut -d: -f2- | tr -d '\r' | sed 's/^ *//'
}
header() { values "$1" | tail -n 1; }

# expect_header LABEL NAME VALUE: NAME appears exactly once, with VALUE.
expect_header() {
  local label="$1" name="$2" want="$3" got count
  got="$(values "$name")"
  count="$(printf '%s' "$got" | grep -c '' || true)"
  if [[ "$count" != 1 ]]; then
    fail "$label: header $name appears $count times, expected once"
  elif [[ "$got" != "$want" ]]; then
    fail "$label: header $name is '$got', expected '$want'"
  else
    return 0
  fi
  return 1
}

# The global headers of the template, as NAME<TAB>VALUE lines.
expected="$work/expected"
sed -n 's/^Header always set \([A-Za-z-]*\) "\(.*\)"$/\1\t\2/p' "$htaccess" > "$expected"
[[ -s "$expected" ]] || { echo "::error::web smoke: no headers found in $htaccess" >&2; exit 1; }

# W1
get /release.txt
if [[ "$status" == 200 && "$(tr -d '\r\n' < "$work/body")" == "$sha" ]]; then
  pass "W1 release.txt is $sha"
else
  fail "W1 release.txt: status $status, body '$(head -c 80 "$work/body")', expected $sha"
fi

# W2
get /
if [[ "$status" != 200 ]]; then
  fail "W2 /: status $status, expected 200"
elif [[ "$(header content-type)" != text/html* ]]; then
  fail "W2 /: content type '$(header content-type)', expected text/html"
elif ! grep -q 'flutter_bootstrap.js' "$work/body"; then
  fail "W2 /: the page does not load flutter_bootstrap.js"
else
  ok=true
  while IFS=$'\t' read -r name value; do
    expect_header "W2 /" "$name" "$value" || ok=false
  done < "$expected"
  [[ "$ok" == true ]] && pass "W2 / is the app with $(wc -l < "$expected") headers as in the template"
fi

# W3
get /version.json
if [[ "$pubspec" == - ]]; then
  want_version="$(jq -r '.version // empty' "$work/body" 2> /dev/null || true)"
  want_build="$(jq -r '.build_number // empty' "$work/body" 2> /dev/null || true)"
  [[ "$want_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || want_version="(a version X.Y.Z)"
else
  want_version="$(sed -n 's/^version:[[:space:]]*\([^[:space:]#]*\).*/\1/p' "$pubspec" | head -n 1)"
  want_build=""
  if [[ "$want_version" == *+* ]]; then
    want_build="${want_version#*+}"
  fi
  want_version="${want_version%%+*}"
fi
if [[ "$status" != 200 ]]; then
  fail "W3 version.json: status $status, expected 200"
elif [[ "$(header content-type)" != application/json* ]]; then
  fail "W3 version.json: content type '$(header content-type)', expected application/json"
elif [[ "$(jq -r '.version // empty' "$work/body")" != "$want_version" ||
  "$(jq -r '.build_number // empty' "$work/body")" != "$want_build" ]]; then
  fail "W3 version.json: '$(tr -d '\n' < "$work/body" | head -c 200)', expected version $want_version build $want_build"
elif expect_header "W3 version.json" Cache-Control no-store; then
  pass "W3 version.json is $want_version+$want_build, never cached"
fi

# W4
for file in main.dart.wasm sqlite3.wasm main.dart.js; do
  get "/$file" -o /dev/null
  type="$(header content-type)"
  case "$file" in
    *.wasm) want=application/wasm ;;
    *) want=text/javascript ;;
  esac
  if [[ "$status" == 200 && "$type" == "$want"* ]]; then
    pass "W4 $file is $type"
  else
    fail "W4 $file: status $status, content type '$type', expected 200 $want"
  fi
done

# W5
get "/r/$sha/index.html"
if [[ "$status" == 404 ]]; then
  pass "W5 the release folder is not reachable directly"
else
  fail "W5 /r/$sha/index.html: status $status, expected 404"
fi

# W6
if [[ "${WIO_WEB_SMOKE_SKIP_HTTPS:-}" == 1 ]]; then
  echo "skip  W6 (local test: plain HTTP)"
elif [[ "$origin" != https://* ]]; then
  fail "W6 the origin $origin is not https"
else
  plain="http://${origin#https://}"
  : > "$work/headers"
  status="$(curl -sS --max-time 60 -D "$work/headers" -o /dev/null -w '%{http_code}' "$plain/")" || status=curl-error
  location="$(header location)"
  if [[ "$status" =~ ^30[1278]$ && "$location" == "$origin/"* ]]; then
    pass "W6 http redirects to $location"
  else
    fail "W6 $plain/: status $status, location '$location', expected a redirect to $origin/"
  fi
fi

if [[ "$failures" -gt 0 ]]; then
  echo "::error::web smoke test: $failures check(s) failed"
  exit 1
fi
echo "web smoke test passed"
