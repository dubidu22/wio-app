#!/usr/bin/env bash
# Smoke test of a deployed API over HTTP(S) (plan 010 section 5).
#
# Usage:
#   smoke.sh API_URL staging|production    S1, S2, S5, S6; staging adds S3
#   smoke.sh API_URL failed-sign-in EMAIL  one failed sign-in (S4 first half)
#
# Environment: WIO_SMOKE_EMAIL and WIO_SMOKE_PASSWORD (staging, D-162);
# WIO_WEB_ORIGIN (optional, D-163): when set, its preflight must be allowed.
# WIO_SMOKE_REPORT (optional): file that gets "<workspace id> <sha256>" of the
# test file S7 stored, so deploy.sh can delete it on the host.
# WIO_SMOKE_SKIP_BODY_CAP=1 (local test only): PHP's built-in server has no
# request body limit, so S5b cannot pass there.
# curl checks TLS certificates; no check passes on an invalid certificate.
set -euo pipefail

api="${1:?usage: smoke.sh API_URL MODE [ARGS]}"
api="${api%/}"
mode="${2:?usage: smoke.sh API_URL MODE [ARGS]}"

work="$(mktemp -d)"
trap 'rm -rf -- "${work:?}"' EXIT
failures=0

# request METHOD PATH [curl args...]: sets status, body (file), headers (file).
request() {
  local method="$1" path="$2"
  shift 2
  : > "$work/headers"
  : > "$work/body"
  local out
  out="$(curl -sS --max-time 60 -X "$method" -D "$work/headers" -o "$work/body" \
    -w '%{http_code} %{time_total}' "$@" "$api$path")" || out="curl-error 0"
  status="${out%% *}"
  echo "${out#* }" > "$work/time"
}

curl_time() { cat "$work/time"; }

header() {
  # header NAME: the value of the last NAME header (case-insensitive).
  grep -i "^$1:" "$work/headers" | tail -n 1 | cut -d: -f2- | tr -d '\r' | sed 's/^ *//' || true
}

pass() { echo "ok    $*"; }
fail() { echo "::error::$*"; failures=$((failures + 1)); }

expect_problem() {
  # expect_problem LABEL STATUS CODE
  local label="$1" want="$2" code="$3"
  if [[ "$status" != "$want" ]]; then
    fail "$label: status $status, expected $want"
  elif [[ "$(header content-type)" != application/problem+json* ]]; then
    fail "$label: content type '$(header content-type)', expected application/problem+json (did PHP answer?)"
  elif [[ "$(jq -r '.code // empty' "$work/body")" != "$code" ]]; then
    fail "$label: code '$(jq -r '.code // empty' "$work/body")', expected $code"
  else
    pass "$label: $status $code"
  fi
}

sign_in() {
  # sign_in EMAIL PASSWORD
  jq -n --arg e "$1" --arg p "$2" '{email: $e, password: $p, device_name: "Rauchtest deploy"}' > "$work/sign-in.json"
  request POST /auth/sign-in -H 'Content-Type: application/json' --data-binary "@$work/sign-in.json"
}

# S7 (staging, D-186, D-207): a file of 4 MiB + 4 KiB in two chunks: 202
# after the first, the state shows it, 200 and complete after the second.
upload_two_chunks() {
  local token="$1" workspace="$2" total=4198400 first=4194304 sha
  head -c "$total" /dev/urandom > "$work/file"
  sha="$(sha256sum "$work/file" | cut -d' ' -f1)"
  head -c "$first" "$work/file" > "$work/chunk1"
  tail -c "+$((first + 1))" "$work/file" > "$work/chunk2"
  if [[ -n "${WIO_SMOKE_REPORT:-}" && -n "$workspace" ]]; then
    echo "$workspace $sha" > "$WIO_SMOKE_REPORT"
  fi
  request PUT "/files/$sha" -H "Authorization: Bearer $token" -H 'Content-Type: application/octet-stream' \
    -H "Content-Range: bytes 0-$((first - 1))/$total" --data-binary "@$work/chunk1"
  if [[ "$status" != 202 || "$(jq -r '.received_bytes' "$work/body" 2> /dev/null)" != "$first" ]]; then
    fail "S7 first chunk: status $status $(head -c 200 "$work/body")"
    return
  fi
  request GET "/files/$sha/state" -H "Authorization: Bearer $token"
  if [[ "$status" != 200 || "$(jq -r '.received_bytes' "$work/body" 2> /dev/null)" != "$first" ]]; then
    fail "S7 state after the first chunk: status $status $(head -c 200 "$work/body")"
    return
  fi
  request PUT "/files/$sha" -H "Authorization: Bearer $token" -H 'Content-Type: application/octet-stream' \
    -H "Content-Range: bytes $first-$((total - 1))/$total" --data-binary "@$work/chunk2"
  if [[ "$status" == 200 && "$(jq -r '.complete' "$work/body" 2> /dev/null)" == true ]]; then
    pass "S7 two-chunk upload: 202, state $first, 200 complete"
  else
    fail "S7 second chunk: status $status $(head -c 200 "$work/body")"
  fi
}

case "$mode" in
  failed-sign-in)
    email="${3:?email}"
    sign_in "$email" "not-the-password-$RANDOM"
    if [[ "$status" != 401 ]]; then
      echo "::error::S4 failed sign-in: status $status, expected 401"
      exit 1
    fi
    pass "S4 failed sign-in: 401"
    exit 0
    ;;
  staging | production) ;;
  *)
    echo "unknown mode $mode" >&2
    exit 1
    ;;
esac

# S1: health, TLS, rewrite to index.php.
request GET /health
if [[ "$status" == 200 && "$(jq -r '.status // empty' "$work/body" 2> /dev/null)" == ok ]]; then
  pass "S1 GET /health: 200 ok"
else
  fail "S1 GET /health: status $status, body $(head -c 200 "$work/body")"
fi

# S2: the auth middleware runs and answers in problem+json.
request GET /auth/me -H 'Authorization: Bearer wio_smoke_invalid'
expect_problem "S2 GET /auth/me with an invalid token" 401 token_invalid

# S3 (staging): sign in, getMe, sign out. Proves the Authorization header
# reaches PHP (D-112) and Argon2id verifies under the web server (D-108).
if [[ "$mode" == staging ]]; then
  if [[ -z "${WIO_SMOKE_PASSWORD:-}" ]]; then
    fail "S3: WIO_SMOKE_PASSWORD is not set"
  else
    sign_in "${WIO_SMOKE_EMAIL:?}" "$WIO_SMOKE_PASSWORD"
    seconds="$(curl_time)"
    token="$(jq -r '.token // empty' "$work/body" 2> /dev/null || true)"
    if [[ "$status" != 200 || -z "$token" ]]; then
      fail "S3 sign-in as the smoke owner: status $status $(jq -c '{code, title}' "$work/body" 2> /dev/null || true)"
    else
      pass "S3 sign-in: 200 in ${seconds} s"
      request GET /auth/me -H "Authorization: Bearer $token"
      if [[ "$status" == 200 && "$(jq -r '.user.role // empty' "$work/body")" == owner ]]; then
        pass "S3 GET /auth/me with the token: 200 owner (Authorization reaches PHP)"
      else
        fail "S3 GET /auth/me with the token: status $status (Authorization header lost?)"
      fi
      workspace="$(jq -r '.workspace.id // empty' "$work/body" 2> /dev/null || true)"
      upload_two_chunks "$token" "$workspace"
      request POST /auth/sign-out -H "Authorization: Bearer $token"
      if [[ "$status" == 204 ]]; then
        pass "S3 sign-out: 204"
      else
        fail "S3 sign-out: status $status"
      fi
    fi
  fi
fi

# S5: a 4 MiB PUT body with Content-Range reaches PHP (Slim's 404, not an
# Apache 413 page).
head -c 4194304 /dev/zero > "$work/chunk"
request PUT /smoke/chunk -H 'Content-Type: application/octet-stream' \
  -H 'Content-Range: bytes 0-4194303/4194304' --data-binary "@$work/chunk"
expect_problem "S5 PUT 4 MiB with Content-Range" 404 not_found

# S5b: a body above the 5 MiB cap ends with 413 (.htaccess LimitRequestBody).
if [[ "${WIO_SMOKE_SKIP_BODY_CAP:-}" == 1 ]]; then
  echo "skip  S5b body cap (local test: no Apache)"
else
  head -c 6291456 /dev/zero > "$work/big"
  request PUT /smoke/chunk -H 'Content-Type: application/octet-stream' --data-binary "@$work/big"
  if [[ "$status" == 413 ]]; then
    pass "S5b PUT 6 MiB: 413"
  else
    fail "S5b PUT 6 MiB: status $status, expected 413 (body cap missing)"
  fi
fi

# S6: CORS (D-163). A foreign origin never gets CORS headers; the web
# origin, when configured, gets Wio-App-Version in the allowed headers.
preflight() {
  request OPTIONS /auth/me -H "Origin: $1" -H 'Access-Control-Request-Method: GET' \
    -H 'Access-Control-Request-Headers: authorization,wio-app-version'
}
preflight https://example.org
if [[ -z "$(header access-control-allow-origin)" ]]; then
  pass "S6 a foreign origin gets no Access-Control-Allow-Origin"
else
  fail "S6 a foreign origin got Access-Control-Allow-Origin: $(header access-control-allow-origin)"
fi
if [[ -n "${WIO_WEB_ORIGIN:-}" ]]; then
  preflight "$WIO_WEB_ORIGIN"
  allowed="$(header access-control-allow-headers | tr '[:upper:]' '[:lower:]')"
  if [[ "$(header access-control-allow-origin)" == "$WIO_WEB_ORIGIN" && ",${allowed// /}," == *",wio-app-version,"* ]]; then
    pass "S6 $WIO_WEB_ORIGIN may send Wio-App-Version"
  else
    fail "S6 preflight from $WIO_WEB_ORIGIN: status $status, allow-origin '$(header access-control-allow-origin)', allow-headers '$allowed'"
  fi
else
  echo "skip  S6 web origin: WIO_WEB_ORIGIN is not set (CORS middleware pending, D-163)"
fi

if [[ "$failures" -gt 0 ]]; then
  echo "smoke test: $failures check(s) failed"
  exit 1
fi
echo "smoke test passed"
