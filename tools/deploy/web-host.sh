#!/usr/bin/env bash
# Host side of the web deploy (plan 080, D-361, D-362). web-deploy.sh pipes
# this script over its one SSH connection: `bash -s -- COMMAND ROOT [ARGS...]`.
#
# Layout under ROOT (= WIO_WEB_DEPLOY_PATH, for example
# /www/htdocs/w0000000/wio-web-staging):
#   .wio-web-deploy        marker: this folder belongs to the web deploy
#   web/                   the subdomain's document root
#     .htaccess            maps every request into r/<live>/ (one rename to switch)
#     r/<sha>/             the releases
#   htaccess/<sha>         the rendered .htaccess of each release
#   incoming/              uploads
#   live, previous         the live and the previous release
#
# Commands:
#   prepare                guard, create the layout and the marker
#   unpack SHA             incoming/SHA.tar.gz -> web/r/SHA, and its .htaccess
#   live | previous        print the sha (empty if none)
#   htaccess SHA           print the release's .htaccess (rollback smoke test)
#   switch SHA             make SHA live; the old live release becomes previous
#   restore SHA PREVIOUS   make SHA live again and set previous back (failed smoke)
#   prune KEEP             keep live, previous and the KEEP newest releases
set -euo pipefail
umask 022

command="${1:?command}"
root="${2:?root}"
root="${root%/}"
shift 2

fail() {
  echo "web-host: $*" >&2
  exit 1
}

marker="$root/.wio-web-deploy"

# D-362: the deploy key reaches the whole web space, including the business
# website and the API folders. Only a folder named wio-web-* that is new,
# empty (apart from an empty web/ that KAS may need) or already marked as
# ours is ever written.
guard() {
  [[ "$root" == /* ]] || fail "deploy path must be absolute: $root"
  [[ "$root" != *"/../"* && "$root" != *"/.." && "$root" != *"/./"* && "$root" != *"//"* ]] ||
    fail "deploy path must be plain: $root"
  local name="${root%/}"
  name="${name##*/}"
  [[ "$name" == wio-web-* ]] || fail "deploy path must end in a folder named wio-web-*: $root"
  [[ -L "$root" ]] && fail "deploy path must not be a symlink: $root"
  if [[ -e "$root" && ! -f "$marker" ]]; then
    [[ -d "$root" ]] || fail "deploy path is not a folder: $root"
    local entry
    for entry in "$root"/* "$root"/.[!.]* "$root"/..?*; do
      [[ -e "$entry" || -L "$entry" ]] || continue
      if [[ "$entry" == "$root/web" && -d "$entry" && ! -L "$entry" && -z "$(ls -A "$entry")" ]]; then
        continue
      fi
      fail "refusing to write into $root: it holds files that are not the web deploy's (${entry##*/}) and no marker .wio-web-deploy"
    done
  fi
}

ours() {
  guard
  [[ -f "$marker" ]] || fail "$root is not prepared (no marker .wio-web-deploy)"
}

check_sha() {
  [[ "$1" =~ ^[0-9a-f]{7,40}$ ]] || fail "not a commit sha: $1"
}

# write FILE CONTENT: replaces FILE with one rename.
write() {
  printf '%s\n' "$2" > "$1.tmp"
  mv -f -- "$1.tmp" "$1"
}

read_state() {
  if [[ -f "$root/$1" ]]; then cat -- "$root/$1"; fi
}

switch_to() {
  local sha="$1"
  [[ -f "$root/web/r/$sha/index.html" ]] || fail "release $sha is not on the host"
  [[ -f "$root/htaccess/$sha" ]] || fail "release $sha has no .htaccess"
  cp -- "$root/htaccess/$sha" "$root/web/.htaccess.new"
  chmod 644 "$root/web/.htaccess.new"
  mv -f -- "$root/web/.htaccess.new" "$root/web/.htaccess"
  write "$root/live" "$sha"
}

case "$command" in
  prepare)
    guard
    mkdir -p -- "$root"
    [[ -f "$marker" ]] || printf 'This folder is written by the wio web deploy (plan 080). Do not put other files here.\n' > "$marker"
    mkdir -p -- "$root/web/r" "$root/htaccess" "$root/incoming"
    chmod 700 "$root/incoming"
    ;;

  unpack)
    ours
    sha="${1:?sha}"
    check_sha "$sha"
    tarball="$root/incoming/$sha.tar.gz"
    [[ -f "$tarball" ]] || fail "missing upload $tarball"
    [[ -f "$root/incoming/htaccess-$sha" ]] || fail "missing upload incoming/htaccess-$sha"
    target="$root/web/r/$sha"
    if [[ -d "$target" ]]; then
      echo "release $sha is already on the host; keeping it"
    else
      tmp="$root/web/r/.$sha.tmp"
      rm -rf -- "$tmp"
      mkdir -p -- "$tmp"
      tar -xzf "$tarball" -C "$tmp" --no-same-owner --no-same-permissions
      [[ -f "$tmp/index.html" ]] || { rm -rf -- "$tmp"; fail "release $sha has no index.html"; }
      [[ "$(cat -- "$tmp/release.txt" 2> /dev/null)" == "$sha" ]] || { rm -rf -- "$tmp"; fail "release $sha has no matching release.txt"; }
      chmod -R u=rwX,go=rX "$tmp"
      mv -- "$tmp" "$target"
    fi
    mv -f -- "$root/incoming/htaccess-$sha" "$root/htaccess/$sha"
    chmod 644 "$root/htaccess/$sha"
    rm -f -- "$tarball"
    ;;

  live | previous)
    ours
    read_state "$command"
    ;;

  htaccess)
    ours
    sha="${1:?sha}"
    check_sha "$sha"
    cat -- "$root/htaccess/$sha"
    ;;

  switch)
    ours
    sha="${1:?sha}"
    check_sha "$sha"
    old="$(read_state live)"
    switch_to "$sha"
    if [[ -n "$old" && "$old" != "$sha" ]]; then
      write "$root/previous" "$old"
    fi
    echo "live: $sha"
    ;;

  restore)
    ours
    sha="${1:?sha}"
    before="${2:-}"
    check_sha "$sha"
    switch_to "$sha"
    if [[ -n "$before" ]]; then
      check_sha "$before"
      write "$root/previous" "$before"
    else
      rm -f -- "$root/previous"
    fi
    echo "live again: $sha"
    ;;

  prune)
    ours
    keep="${1:?keep}"
    [[ "$keep" =~ ^[1-9][0-9]*$ ]] || fail "keep must be a number: $keep"
    live="$(read_state live)"
    previous="$(read_state previous)"
    count=0
    # Newest first. No process substitution: the hosting's SSH shell has no
    # /dev/fd (plan 010 T3).
    listing="$(ls -t -- "$root/web/r")"
    while IFS= read -r sha; do
      [[ "$sha" =~ ^[0-9a-f]{7,40}$ ]] || continue
      count=$((count + 1))
      if [[ "$sha" == "$live" || "$sha" == "$previous" || "$count" -le "$keep" ]]; then
        continue
      fi
      rm -rf -- "${root:?}/web/r/$sha" "$root/htaccess/$sha"
      echo "removed release $sha"
    done <<< "$listing"
    find "$root/web/r" -mindepth 1 -maxdepth 1 -name '.*.tmp' -exec rm -rf -- {} +
    find "$root/incoming" -mindepth 1 -maxdepth 1 -mmin +60 -exec rm -f -- {} +
    ;;

  *)
    fail "unknown command $command"
    ;;
esac
