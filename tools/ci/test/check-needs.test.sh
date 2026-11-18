#!/usr/bin/env bash
# Tests for check-needs.sh (D-34): each case must pass or fail as stated.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../check-needs.sh"
workflow="$here/fixtures/workflow.yml"
failures=0

needs() {
  # needs fast-a fast-b full-x  -> JSON of results; "-" leaves the job out
  local json='{}' name result
  local names=(fast-a fast-b full-x)
  local i=0
  for result in "$@"; do
    name="${names[$i]}"
    i=$((i + 1))
    [[ "$result" == "-" ]] && continue
    json="$(jq -c --arg n "$name" --arg r "$result" '. + {($n): {result: $r, outputs: {}}}' <<< "$json")"
  done
  echo "$json"
}

expect() {
  local want="$1" label="$2" full="$3" json="$4"
  local got
  if NEEDS_JSON="$json" FULL="$full" FULL_JOBS="full-x" "$script" "$workflow" > /dev/null 2>&1; then
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

expect pass "fast set green, full job skipped on a normal PR" false "$(needs success success skipped)"
expect pass "everything green on the full set"                true  "$(needs success success success)"
expect pass "full job ran and passed on a normal PR"          false "$(needs success success success)"
expect fail "full job skipped although the full set runs"     true  "$(needs success success skipped)"
expect fail "full job failed on a normal PR"                  false "$(needs success success failure)"
expect fail "a fast job failed"                               false "$(needs failure success skipped)"
expect fail "a fast job was cancelled"                        false "$(needs success cancelled skipped)"
expect fail "a fast job was skipped"                          false "$(needs skipped success skipped)"
expect fail "a job of the workflow is missing from needs"     false "$(needs success - skipped)"
expect fail "needs is empty"                                  false '{}'

if [[ "$failures" -gt 0 ]]; then
  echo "$failures case(s) failed"
  exit 1
fi
echo "all check-needs cases passed"
