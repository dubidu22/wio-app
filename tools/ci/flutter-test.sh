#!/usr/bin/env bash
# Runs `flutter test` with the given arguments and fails when no test passed
# (D-35): a step whose tag matches nothing, or whose tests were all skipped,
# must not turn green.
#
# Usage: flutter-test.sh [flutter test arguments...]
set -euo pipefail

report="$(mktemp)"
trap 'rm -f "$report"' EXIT

set +e
flutter test --file-reporter "json:$report" "$@"
code=$?
set -e

if [[ $code -ne 0 ]]; then
  exit "$code"
fi

passed="$(jq -s '[.[] | select(.type == "testDone" and .result == "success" and .skipped == false and .hidden == false)] | length' "$report")"
echo "tests passed: $passed"
if [[ "$passed" -eq 0 ]]; then
  echo "::error::flutter test $* passed no tests"
  exit 1
fi
