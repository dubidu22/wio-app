#!/usr/bin/env bash
# Decides the ci-passed summary check (D-34).
#
# Usage: check-needs.sh WORKFLOW_FILE
# Environment:
#   NEEDS_JSON  the job results, from ${{ toJSON(needs) }}
#   FULL        "true" when the full set runs (push to main, dispatch, full-ci label)
#   FULL_JOBS   space-separated jobs that belong to the full set only
#
# Passes only when:
#   - every job of the workflow except ci-passed is listed in needs;
#   - every fast job succeeded;
#   - every full-set job succeeded, or, when FULL is not "true", was skipped.
# Anything else (failure, cancelled, an unexpected skip) fails.
set -euo pipefail

workflow="${1:?usage: check-needs.sh WORKFLOW_FILE}"
needs_json="${NEEDS_JSON:?NEEDS_JSON is not set}"
full="${FULL:-false}"
read -r -a full_jobs <<< "${FULL_JOBS:-}"

# Top-level job ids: two-space indented keys inside the jobs: block.
mapfile -t workflow_jobs < <(awk '
  /^jobs:[[:space:]]*$/ { in_jobs = 1; next }
  in_jobs && /^[^[:space:]#]/ { in_jobs = 0 }
  in_jobs && /^  [A-Za-z0-9_-]+:[[:space:]]*$/ { sub(/^  /, ""); sub(/:.*/, ""); print }
' "$workflow")

if [[ ${#workflow_jobs[@]} -eq 0 ]]; then
  echo "::error::no jobs found in $workflow"
  exit 1
fi

mapfile -t needed < <(jq -r 'keys[]' <<< "$needs_json")
if [[ ${#needed[@]} -eq 0 ]]; then
  echo "::error::needs is empty: ci-passed would pass with no checks"
  exit 1
fi

is_in() {
  local item="$1"
  shift
  local candidate
  for candidate in "$@"; do
    [[ "$candidate" == "$item" ]] && return 0
  done
  return 1
}

status=0

for job in "${workflow_jobs[@]}"; do
  [[ "$job" == "ci-passed" ]] && continue
  if ! is_in "$job" "${needed[@]}"; then
    echo "::error::job '$job' is not in ci-passed's needs, so it guards nothing"
    status=1
  fi
done

for job in "${full_jobs[@]}"; do
  if ! is_in "$job" "${needed[@]}"; then
    echo "::error::full-set job '$job' is not in needs"
    status=1
  fi
done

for job in "${needed[@]}"; do
  result="$(jq -r --arg job "$job" '.[$job].result' <<< "$needs_json")"
  allowed=(success)
  if [[ "$full" != "true" ]] && is_in "$job" "${full_jobs[@]}"; then
    allowed+=(skipped)
  fi
  if is_in "$result" "${allowed[@]}"; then
    echo "ok    $job: $result"
  else
    echo "::error::$job: $result (allowed: ${allowed[*]})"
    status=1
  fi
done

exit "$status"
