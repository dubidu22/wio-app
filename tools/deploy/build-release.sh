#!/usr/bin/env bash
# Builds the API release tarball (plan 010, D-159): server/ without tests and
# dev tools, with vendor/ from the lock file (--no-dev, authoritative class
# map) and a REVISION file. Works in a temporary copy, so the checkout's own
# vendor/ is never touched.
#
# Usage: build-release.sh REPO_ROOT SHA OUT_TARBALL
set -euo pipefail

repo="${1:?usage: build-release.sh REPO_ROOT SHA OUT_TARBALL}"
sha="${2:?usage: build-release.sh REPO_ROOT SHA OUT_TARBALL}"
out="${3:?usage: build-release.sh REPO_ROOT SHA OUT_TARBALL}"
[[ "$sha" =~ ^[0-9a-f]{7,40}$ ]] || { echo "not a commit sha: $sha" >&2; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf -- "${work:?}"' EXIT

for item in bin migrations public src composer.json composer.lock; do
  cp -R "$repo/server/$item" "$work/"
done
# The invented demo data for bin/seed-demo, which runs on staging only (D-407).
mkdir "$work/demo"
cp "$repo/tools/demo/demo-workspace.json" "$work/demo/"
cp -R "$repo/tools/demo/media" "$work/demo/"
# Never ship a host config from a working copy.
rm -f -- "$work/config.php"

(
  cd "$work"
  composer install --no-dev --classmap-authoritative --no-interaction --no-progress --prefer-dist --quiet
)
echo "$sha" > "$work/REVISION"

tar -czf "$out" -C "$work" .
echo "built $out ($(du -h "$out" | cut -f1))"
