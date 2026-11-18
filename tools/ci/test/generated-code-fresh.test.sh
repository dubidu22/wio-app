#!/usr/bin/env bash
# Tests for generated-code-fresh.sh (D-85, D-86) with fake generators in a
# throw-away git repository.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../generated-code-fresh.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

repo="$work/repo"
mkdir -p "$repo/app/lib" "$repo/other"
git -C "$repo" init -q
git -C "$repo" config user.email ci@example.org
git -C "$repo" config user.name ci
echo "generated" > "$repo/app/lib/data.g.dart"
echo "x" > "$repo/other/file.txt"
git -C "$repo" add -A
git -C "$repo" commit -q -m init

reset_repo() {
  git -C "$repo" reset -q --hard
  git -C "$repo" clean -q -fd
}

expect() {
  local want="$1" label="$2"
  shift 2
  local got
  reset_repo
  if "$script" "$@" > /dev/null 2>&1; then
    got=pass
  else
    got=fail
  fi
  if [[ "$got" == "$want" ]]; then
    echo "ok   $label"
  else
    echo "FAIL $label: expected $want, got $got"
    failures=$((failures + 1))
  fi
}

app="$repo/app"
expect pass "generators change nothing"     "$app" -- true -- true
expect fail "a generated file changed"      "$app" -- sh -c 'echo new > lib/data.g.dart'
expect fail "a new file appeared"           "$app" -- sh -c 'echo v2 > lib/schema_v2.json'
expect fail "a generated file was deleted"  "$app" -- rm lib/data.g.dart
expect fail "the second generator changed"  "$app" -- true -- sh -c 'echo new > lib/data.g.dart'
expect fail "a generator failed"            "$app" -- false
expect pass "a change outside the dir is ignored" "$app" -- sh -c 'echo y > ../other/file.txt'
expect fail "no generator given"            "$app" --
expect fail "no separator"                  "$app" true

reset_repo
echo dirty > "$app/lib/data.g.dart"
if "$script" "$app" -- true > /dev/null 2>&1; then
  echo "FAIL a dirty tree before generating: expected fail, got pass"
  failures=$((failures + 1))
else
  echo "ok   a dirty tree before generating"
fi

if [[ "$failures" -gt 0 ]]; then
  echo "$failures case(s) failed"
  exit 1
fi
echo "all generated-code-fresh cases passed"
