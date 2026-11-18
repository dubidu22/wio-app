#!/usr/bin/env bash
# Local end-to-end test of tools/deploy (plan 010 T2). Not run in CI: it
# needs a MariaDB and builds a real release with Composer.
#
# Stand-ins: a fake `ssh` that runs the remote command locally with
# SSH_CLIENT set (OpenSSH's transport itself is proved on staging, T3), and
# PHP's built-in web server with web/ as the document root, which keeps its
# realpath cache like PHP-FPM does. Apache specifics (.htaccess, Authorization header) are T3 too.
#
# Usage: local-deploy.test.sh
# KEEP_WORK=1 keeps the work directory (logs, host tree) for inspection.
# Environment: WIO_TEST_DB_NAME, WIO_TEST_DB_USER, WIO_TEST_DB_PASSWORD,
#   WIO_TEST_DB_HOST (default 127.0.0.1) - an empty database for the test.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
deploy="$repo/tools/deploy"
work="$(mktemp -d)"
port=18080
server_pid=""

cleanup() {
  if [[ -n "$server_pid" ]]; then
    kill "$server_pid" 2> /dev/null || true
  fi
  if [[ "${KEEP_WORK:-}" == 1 ]]; then
    echo "kept $work"
  else
    rm -rf -- "${work:?}"
  fi
}
trap cleanup EXIT

root="$work/host/wio-api-staging"
mkdir -p "$work/bin" "$root"

# Fake ssh: drops options, runs the remote command with bash locally.
cat > "$work/bin/ssh" << 'SSH'
#!/usr/bin/env bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i | -p | -o) shift 2 ;;
    -*) shift ;;
    *) break ;;
  esac
done
shift # user@host
SSH_CLIENT="${FAKE_SSH_CLIENT:-127.0.0.1} 50000 22" exec bash -c "$*"
SSH
chmod +x "$work/bin/ssh"
export PATH="$work/bin:$PATH"

cat > "$work/router.php" << PHP
<?php
// The document root is web/, as on the hosting (plan 010 section 4.1).
\$web = '$root/web';
if (is_file(\$web . '/index.php')) {
    require \$web . '/index.php';
} else {
    http_response_code(503);
}
PHP
php -S "127.0.0.1:$port" "$work/router.php" > "$work/server.log" 2>&1 &
server_pid=$!

export WIO_ENVIRONMENT=staging
export WIO_SSH_HOST=localhost WIO_SSH_USER=deploy
export WIO_SSH_KEY_FILE=/dev/null WIO_SSH_KNOWN_HOSTS_FILE=/dev/null
export WIO_DEPLOY_PATH="$root"
export WIO_API_URL="http://127.0.0.1:$port"
export WIO_DB_HOST="${WIO_TEST_DB_HOST:-127.0.0.1}"
export WIO_DB_NAME="${WIO_TEST_DB_NAME:?}" WIO_DB_USER="${WIO_TEST_DB_USER:?}" WIO_DB_PASSWORD="${WIO_TEST_DB_PASSWORD:?}"
export WIO_SMOKE_PASSWORD="local-test-password-$RANDOM$RANDOM"
export WIO_KEEP_RELEASES=3
# The test's PHP server answers from 127.0.0.1.
unset WIO_WEB_ORIGIN

failures=0
check() {
  # check LABEL EXPECTED ACTUAL
  if [[ "$2" == "$3" ]]; then
    echo "PASS  $1"
  else
    echo "FAIL  $1: expected '$2', got '$3'"
    failures=$((failures + 1))
  fi
}
log_has() {
  # log_has LABEL PATTERN LOG
  if grep -q -- "$2" "$3"; then
    echo "PASS  $1"
  else
    echo "FAIL  $1: '$2' not in $(basename "$3")"
    failures=$((failures + 1))
  fi
}
live() { basename "$(readlink "$root/current")"; }
run_deploy() {
  # run_deploy SHA TARBALL [env...]: returns the deploy's exit code
  local sha="$1" tarball="$2"
  shift 2
  local status=0
  env "$@" "$deploy/deploy.sh" deploy "$tarball" "$sha" > "$work/deploy-$sha.log" 2>&1 || status=$?
  return "$status"
}

echo "== build"
"$deploy/build-release.sh" "$repo" aaaaaaa "$work/good.tar.gz"
# A broken release: every request fails with 500.
mkdir "$work/broken"
tar -xzf "$work/good.tar.gz" -C "$work/broken"
printf '<?php\nhttp_response_code(500);\n' > "$work/broken/public/index.php"
tar -czf "$work/broken.tar.gz" -C "$work/broken" .

echo "== 1 first deploy creates the layout, migrates, creates the smoke owner, smoke passes"
status=0; run_deploy aaaaaaa "$work/good.tar.gz" WIO_CREATE_SMOKE_OWNER=true || status=$?
check "first deploy exit" 0 "$status"
check "current is aaaaaaa" aaaaaaa "$(live)"
check "config.php is 0600" 600 "$(stat -c %a "$root/shared/config.php")"
check "config linked into the release" "../../shared/config.php" "$(readlink "$root/releases/aaaaaaa/config.php")"
check "tarball removed after unpack" 0 "$(find "$root/incoming" -type f | wc -l)"
log_has "H2 printed" "H2 argon2id hash" "$work/deploy-aaaaaaa.log"
log_has "S3 sign-in and getMe" "S3 GET /auth/me with the token: 200 owner" "$work/deploy-aaaaaaa.log"
log_has "S4" "S4 REMOTE_ADDR is the client address" "$work/deploy-aaaaaaa.log"

echo "== 2 second deploy switches and remembers the previous release"
status=0; run_deploy bbbbbbb "$work/good.tar.gz" || status=$?
check "second deploy exit" 0 "$status"
check "current is bbbbbbb" bbbbbbb "$(live)"
check "previous is aaaaaaa" aaaaaaa "$(cat "$root/previous")"
log_has "no migration to apply twice" "Applied 0 migration" "$work/deploy-bbbbbbb.log"

echo "== 3 a broken release fails the smoke test and the live one comes back"
status=0; run_deploy ccccccc "$work/broken.tar.gz" || status=$?
check "broken deploy fails" 1 "$status"
check "current is bbbbbbb again" bbbbbbb "$(live)"
check "previous is still aaaaaaa" aaaaaaa "$(cat "$root/previous")"

echo "== 4 a proxy in front of PHP (SSH address differs) fails S4 and switches back"
status=0; run_deploy ddddddd "$work/good.tar.gz" FAKE_SSH_CLIENT=10.9.9.9 || status=$?
check "S4 mismatch fails" 1 "$status"
log_has "S4 names the problem" "S4 FAIL: REMOTE_ADDR is not the client address" "$work/deploy-ddddddd.log"
check "current is bbbbbbb after S4 failure" bbbbbbb "$(live)"

echo "== 5 the live release cannot be deployed over itself"
status=0; run_deploy bbbbbbb "$work/good.tar.gz" || status=$?
check "redeploy of the live sha refused" 1 "$status"
check "current still bbbbbbb" bbbbbbb "$(live)"

echo "== 6 rollback to the previous release"
status=0; "$deploy/deploy.sh" rollback > "$work/rollback.log" 2>&1 || status=$?
check "rollback exit" 0 "$status"
check "current is aaaaaaa" aaaaaaa "$(live)"

echo "== 7 more deploys prune to three releases, never current or previous"
for sha in eeeeeee fffffff 1111111; do
  run_deploy "$sha" "$work/good.tar.gz" || { echo "FAIL  deploy $sha"; failures=$((failures + 1)); }
done
check "current is 1111111" 1111111 "$(live)"
check "three releases kept" "1111111 eeeeeee fffffff" "$(find "$root/releases" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort | tr '\n' ' ' | sed 's/ $//')"

echo "== 8 a second create_smoke_owner run sets the password instead of making a second workspace"
status=0; run_deploy 2222222 "$work/good.tar.gz" WIO_CREATE_SMOKE_OWNER=true WIO_SMOKE_PASSWORD="rotated-$WIO_SMOKE_PASSWORD" || status=$?
check "second smoke owner run with a rotated password passes" 0 "$status"
check "current is 2222222" 2222222 "$(live)"

if [[ "$failures" -gt 0 ]]; then
  echo "$failures check(s) failed; logs in $work are removed on exit"
  for f in "$work"/deploy-*.log; do echo "--- $f"; tail -n 15 "$f"; done
  exit 1
fi
echo "all local deploy checks passed"
