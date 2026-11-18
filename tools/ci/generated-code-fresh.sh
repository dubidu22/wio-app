#!/usr/bin/env bash
# Runs the code generators and fails when they change or add any file under
# <dir> (D-85): committed generated code and schema dumps must match what the
# pinned generators make from the sources (D-65, D-77).
#
# Usage: generated-code-fresh.sh <dir> -- <command...> [-- <command...>]...
# Each command runs in <dir>, in order; a failing command fails the check.
set -euo pipefail

usage() {
  echo "usage: $0 <dir> -- <command...> [-- <command...>]..." >&2
  exit 2
}

[[ $# -ge 3 && "$2" == "--" ]] || usage
dir="$1"
shift 2
cd "$dir"

changes() {
  git status --porcelain --untracked-files=all -- .
}

if [[ -n "$(changes)" ]]; then
  echo "::error::$dir has uncommitted changes before generating; commit or stash them first"
  changes
  exit 1
fi

commands=0
command=()
run() {
  [[ ${#command[@]} -gt 0 ]] || usage
  echo "+ ${command[*]}"
  "${command[@]}"
  commands=$((commands + 1))
  command=()
}
for arg in "$@"; do
  if [[ "$arg" == "--" ]]; then
    run
  else
    command+=("$arg")
  fi
done
run

stale="$(changes)"
if [[ -n "$stale" ]]; then
  echo "::error::Generated code is stale. Run the generators below in $dir and commit the result."
  echo "$stale"
  git --no-pager diff --stat -- .
  exit 1
fi
echo "generated code is fresh ($commands generator command(s), no file changed)"
