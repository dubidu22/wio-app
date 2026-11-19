#!/usr/bin/env bash
# Deploys the API to the hosting over SSH and smoke tests it (plan 010,
# D-158 to D-163). Called by .github/workflows/deploy-api.yml.
#
# Usage:
#   deploy.sh deploy TARBALL SHA     upload, check, migrate, switch, smoke
#   deploy.sh rollback [SHA]         switch back (default: the previous release), smoke
#
# Environment (from the GitHub environment, see plan 010 section 7):
#   WIO_ENVIRONMENT      staging | production
#   WIO_SSH_HOST, WIO_SSH_USER, WIO_SSH_PORT (default 22)
#   WIO_SSH_KEY_FILE     private key file; WIO_SSH_KNOWN_HOSTS_FILE pinned host key
#   WIO_DEPLOY_PATH      directory that holds releases/, current, shared/
#   WIO_API_URL          https://… of the deployed API
#   WIO_DB_NAME, WIO_DB_USER, WIO_DB_PASSWORD, WIO_DB_HOST (default localhost)
#   WIO_PHP_CLI          PHP 8.3 CLI on the host (default php)
#   WIO_WEB_ORIGIN       web build origin for the CORS check (optional, D-163)
#   WIO_SMOKE_PASSWORD   staging smoke owner's password (staging only, D-162)
#   WIO_CREATE_SMOKE_OWNER  "true" creates the smoke owner first (once)
#   WIO_KEEP_RELEASES    releases to keep (default 3)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode="${1:?usage: deploy.sh deploy TARBALL SHA | rollback [SHA]}"
shift

environment="${WIO_ENVIRONMENT:?}"
[[ "$environment" == staging || "$environment" == production ]] || { echo "unknown environment $environment" >&2; exit 1; }
root="${WIO_DEPLOY_PATH:?}"
smoke_email="rauchtest@example.org"

ssh_opts=(
  -i "${WIO_SSH_KEY_FILE:?}"
  -p "${WIO_SSH_PORT:-22}"
  -o "UserKnownHostsFile=${WIO_SSH_KNOWN_HOSTS_FILE:?}"
  -o StrictHostKeyChecking=yes
  -o IdentitiesOnly=yes
  -o BatchMode=yes
  -o ConnectTimeout=20
  # One SSH connection for the whole deploy: shared hosting may refuse many
  # quick logins from one address (T3, second run: connection timed out).
  -o ControlMaster=auto
  -o "ControlPath=${TMPDIR:-/tmp}/wio-deploy-%C"
  -o ControlPersist=120
  -o ServerAliveInterval=15
)
target="${WIO_SSH_USER:?}@${WIO_SSH_HOST:?}"

# host COMMAND [ARGS...]: runs host.sh on the hosting.
# The remote command line is built here on purpose, with every word quoted.
# shellcheck disable=SC2029
host() {
  local command="$1"
  shift
  ssh "${ssh_opts[@]}" "$target" \
    "WIO_PHP_CLI=$(printf %q "${WIO_PHP_CLI:-php}") bash -s -- $(printf '%q ' "$command" "$root" "$@")" \
    < "$here/host.sh"
}

# upload LOCAL_FILE NAME: copies a file to incoming/NAME (mode 0600).
# shellcheck disable=SC2029
upload() {
  ssh "${ssh_opts[@]}" "$target" \
    "umask 077 && cat > $(printf %q "$root/incoming/$2")" < "$1"
}

# PHP code in single quotes, expanded by PHP.
# shellcheck disable=SC2016
config_file() {
  WIO_DB_DSN="mysql:host=${WIO_DB_HOST:-localhost};dbname=${WIO_DB_NAME:?};charset=utf8mb4" \
  WIO_DB_USER="${WIO_DB_USER:?}" \
  WIO_DB_PASSWORD="${WIO_DB_PASSWORD:?}" \
  WIO_FILES_DIR="$root/shared/files" \
  WIO_CORS_ORIGINS="${WIO_WEB_ORIGIN:-}" \
  WIO_ENVIRONMENT="$environment" \
    php -r '
      $c = [];
      // Uploaded files survive releases, outside the web root (D-207).
      // The CORS allow-list is the web origin, when one is set (D-163).
      // WIO_ENVIRONMENT lets staging-only tools refuse production (D-406).
      foreach (["WIO_DB_DSN", "WIO_DB_USER", "WIO_DB_PASSWORD", "WIO_FILES_DIR", "WIO_CORS_ORIGINS", "WIO_ENVIRONMENT"] as $n) {
          $v = (string) getenv($n);
          if ($v !== "") { $c[$n] = $v; }
      }
      echo "<?php\n\n// Written by the deploy (D-161). Do not edit: the next deploy overwrites it.\nreturn ", var_export($c, true), ";\n";
    '
}

smoke() {
  local args=("$WIO_API_URL" "$environment")
  # Called as `if ! smoke`, where set -e does not apply: every step returns.
  local report status=0
  report="$(mktemp)"
  WIO_WEB_ORIGIN="${WIO_WEB_ORIGIN:-}" WIO_SMOKE_EMAIL="$smoke_email" WIO_SMOKE_PASSWORD="${WIO_SMOKE_PASSWORD:-}" \
    WIO_SMOKE_REPORT="$report" "$here/smoke.sh" "${args[@]}" || status=$?
  # The S7 test file never stays in the store.
  if [[ -s "$report" ]]; then
    # shellcheck disable=SC2046 # two words: workspace id and sha256
    host remove-file $(cat "$report") || status=1
  fi
  rm -f -- "$report"
  [[ "$status" == 0 ]] || return 1
  if [[ "$environment" == staging ]]; then
    local probe
    probe="rauchtest-$(date +%s)-$RANDOM@example.org"
    "$here/smoke.sh" "$WIO_API_URL" failed-sign-in "$probe" || return 1
    host ip-check "$probe" || return 1
  fi
}

close_ssh() {
  ssh "${ssh_opts[@]}" -O exit "$target" 2> /dev/null || true
}
trap close_ssh EXIT

case "$mode" in
  deploy)
    tarball="${1:?tarball}"
    sha="${2:?sha}"
    echo "== prepare"
    host prepare
    echo "== upload $sha"
    upload "$tarball" "$sha.tar.gz"
    host unpack "$sha"
    tmp="$(mktemp)"
    trap 'rm -f -- "${tmp:?}"; close_ssh' EXIT
    config_file > "$tmp"
    upload "$tmp" config.php
    host config
    echo "== host checks (H1 to H3)"
    host check "$sha"
    echo "== migrate (D-158)"
    host migrate "$sha"
    echo "== switch (D-159)"
    live="$(host live)"
    before="$(host previous)"
    host switch "$sha"
    if [[ "$environment" == staging && "${WIO_CREATE_SMOKE_OWNER:-false}" == true ]]; then
      echo "== smoke owner (D-162)"
      printf '%s\n' "${WIO_SMOKE_PASSWORD:?}" > "$tmp"
      upload "$tmp" smoke-password
      host smoke-owner "$smoke_email"
    fi
    echo "== smoke test"
    if ! smoke; then
      if [[ -n "$live" && "$live" != "$sha" ]]; then
        echo "::error::smoke test failed: switching back to $live (migrations stay, D-159)"
        host restore "$live" "$before"
      else
        echo "::error::smoke test failed and there is no earlier release to switch back to"
      fi
      exit 1
    fi
    host prune "${WIO_KEEP_RELEASES:-3}"
    echo "deployed $sha to $environment"
    ;;

  rollback)
    sha="${1:-}"
    if [[ -z "$sha" ]]; then
      sha="$(host previous)"
      [[ -n "$sha" ]] || { echo "::error::no previous release to roll back to" >&2; exit 1; }
    fi
    echo "== rollback to $sha (no migrations run)"
    host switch "$sha"
    smoke
    echo "rolled back $environment to $sha"
    ;;

  *)
    echo "unknown mode $mode" >&2
    exit 1
    ;;
esac
