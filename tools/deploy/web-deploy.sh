#!/usr/bin/env bash
# Deploys the web app to its own origin over SSH and smoke tests it (plan 080,
# D-357 to D-371). Called by .github/workflows/deploy-web.yml.
#
# Usage:
#   web-deploy.sh build APP_DIR SHA TARBALL   flutter build web for this
#                                             environment, packed (D-360)
#   web-deploy.sh deploy TARBALL SHA          upload, switch, smoke, switch back on failure
#   web-deploy.sh rollback [SHA]              switch back (default: previous), smoke
#
# Environment (from the GitHub environment, plan 080 section 4):
#   WIO_ENVIRONMENT        staging | production
#   WIO_SSH_HOST, WIO_SSH_USER, WIO_SSH_PORT (default 22)
#   WIO_SSH_KEY_FILE       private key file; WIO_SSH_KNOWN_HOSTS_FILE pinned host key
#   WIO_WEB_DEPLOY_PATH    folder wio-web-* that holds web/, htaccess/, incoming/
#   WIO_WEB_ORIGIN         https://… of the web app
#   WIO_API_URL            https://… of this environment's API
#   WIO_KEEP_RELEASES      releases to keep (default 3)
#   WIO_WEB_SMOKE          smoke command (default web-smoke.sh; the local test swaps it)
#   WIO_WEB_BROWSER_CHECKS true: after the smoke test also run the browser
#                          checks against the live URL (staging, D-368);
#                          needs tools/node_modules
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
mode="${1:?usage: web-deploy.sh build APP_DIR SHA TARBALL | deploy TARBALL SHA | rollback [SHA]}"
shift

# The origin (scheme://host[:port]) of a URL.
origin_of() {
  local url="$1" rest
  rest="${url#*://}"
  printf '%s://%s' "${url%%://*}" "${rest%%/*}"
}

# render SHA OUT: the .htaccess for release SHA (D-361, D-364).
render() {
  local api_origin
  api_origin="$(origin_of "${WIO_API_URL:?}")"
  [[ "$api_origin" =~ ^https?://[A-Za-z0-9.:-]+$ ]] || { echo "::error::WIO_API_URL is not a plain URL: $WIO_API_URL" >&2; return 1; }
  sed -e "s|@SHA@|$1|g" -e "s|@API_ORIGIN@| $api_origin|g" "$here/web/htaccess.template" > "$2"
}

if [[ "$mode" == build ]]; then
  app="${1:?app dir}"
  sha="${2:?sha}"
  out="${3:?tarball}"
  [[ "${WIO_API_URL:?}" == https://* ]] || { echo "::error::WIO_API_URL must be https" >&2; exit 1; }
  (
    cd "$app"
    flutter pub get --enforce-lockfile
    # The CI flags (D-40), plus this environment's API (D-133).
    flutter build web --wasm --no-web-resources-cdn --release \
      --dart-define=WIO_API_URL="$WIO_API_URL"
  )
  printf '%s\n' "$sha" > "$app/build/web/release.txt"
  # Nothing registers a service worker (flutter_bootstrap.js); none is served (D-363).
  rm -f -- "$app/build/web/flutter_service_worker.js"
  tar -C "$app/build/web" -czf "$out" .
  echo "built $sha for $WIO_API_URL"
  exit 0
fi

environment="${WIO_ENVIRONMENT:?}"
[[ "$environment" == staging || "$environment" == production ]] || { echo "unknown environment $environment" >&2; exit 1; }
root="${WIO_WEB_DEPLOY_PATH:?}"
web_origin="${WIO_WEB_ORIGIN:?}"
web_origin="${web_origin%/}"
smoke_command="${WIO_WEB_SMOKE:-$here/web-smoke.sh}"

ssh_opts=(
  -i "${WIO_SSH_KEY_FILE:?}"
  -p "${WIO_SSH_PORT:-22}"
  -o "UserKnownHostsFile=${WIO_SSH_KNOWN_HOSTS_FILE:?}"
  -o StrictHostKeyChecking=yes
  -o IdentitiesOnly=yes
  -o BatchMode=yes
  -o ConnectTimeout=20
  # One SSH connection for the whole run: the hosting locks an address
  # after many quick logins (plan 010 T3).
  -o ControlMaster=auto
  -o "ControlPath=${TMPDIR:-/tmp}/wio-web-deploy-%C"
  -o ControlPersist=120
  -o ServerAliveInterval=15
)
target="${WIO_SSH_USER:?}@${WIO_SSH_HOST:?}"

# host COMMAND [ARGS...]: runs web-host.sh on the hosting.
# shellcheck disable=SC2029 # the remote command line is built here on purpose
host() {
  ssh "${ssh_opts[@]}" "$target" \
    "bash -s -- $(printf '%q ' "$1" "$root" "${@:2}")" < "$here/web-host.sh"
}

# upload LOCAL_FILE NAME: copies a file to incoming/NAME.
# shellcheck disable=SC2029
upload() {
  ssh "${ssh_opts[@]}" "$target" "umask 077 && cat > $(printf %q "$root/incoming/$2")" < "$1"
}

close_ssh() {
  ssh "${ssh_opts[@]}" -O exit "$target" 2> /dev/null || true
}

work="$(mktemp -d)"
trap 'rm -rf -- "${work:?}"; close_ssh' EXIT

# smoke SHA HTACCESS PUBSPEC: HTTP checks, then on request the browser
# checks (D-367, D-368).
smoke() {
  local sha="$1"
  "$smoke_command" "$web_origin" "$sha" "$2" "$3" || return 1
  if [[ "${WIO_WEB_BROWSER_CHECKS:-false}" == true ]]; then
    local api_origin
    api_origin="$(origin_of "$WIO_API_URL")"
    node "$repo/tools/ci/web-network-check.mjs" --url "$web_origin/" --allow "$api_origin" || return 1
    node "$repo/tools/ci/web-db-check.mjs" --url "$web_origin/" || return 1
  fi
}

case "$mode" in
  deploy)
    tarball="${1:?tarball}"
    sha="${2:?sha}"
    echo "== prepare $root"
    host prepare
    echo "== upload $sha"
    render "$sha" "$work/htaccess"
    upload "$tarball" "$sha.tar.gz"
    upload "$work/htaccess" "htaccess-$sha"
    host unpack "$sha"
    live="$(host live)"
    before="$(host previous)"
    echo "== switch (live was: ${live:-none})"
    host switch "$sha"
    echo "== smoke test $web_origin"
    if ! smoke "$sha" "$work/htaccess" "$repo/app/pubspec.yaml"; then
      if [[ -n "$live" && "$live" != "$sha" ]]; then
        echo "::error::web smoke test failed: switching back to $live"
        host restore "$live" "$before"
      else
        echo "::error::web smoke test failed and there is no earlier release to switch back to"
      fi
      exit 1
    fi
    host prune "${WIO_KEEP_RELEASES:-3}"
    echo "deployed web $sha to $environment ($web_origin)"
    ;;

  rollback)
    sha="${1:-}"
    if [[ -z "$sha" ]]; then
      sha="$(host previous)"
      [[ -n "$sha" ]] || { echo "::error::no previous web release to roll back to" >&2; exit 1; }
    fi
    echo "== rollback web to $sha"
    host switch "$sha"
    # The checked-out commit is not the release being restored: the headers
    # come from that release's own .htaccess on the host, and W3 only checks
    # that version.json is well formed and never cached.
    host htaccess "$sha" > "$work/htaccess"
    smoke "$sha" "$work/htaccess" -
    echo "rolled back web $environment to $sha"
    ;;

  *)
    echo "unknown mode $mode" >&2
    exit 1
    ;;
esac
