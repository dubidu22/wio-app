#!/usr/bin/env bash
# Decides environment, commit and mode of a deploy-api run, and refuses runs
# that must not happen (plan 010, D-160, MRG-01). Called by the resolve job of
# .github/workflows/deploy-api.yml; writes environment, sha and mode to
# $GITHUB_OUTPUT.
#
# Guards:
#   - production only from a tag api-v* (deploy and rollback), so a dispatch
#     from a branch never reaches production even before the GitHub
#     environment has its own deployment rule;
#   - every deploy that does not come from a successful ci run on main needs
#     ci-passed on the commit AND the commit on main (a PR head can have a
#     green ci-passed too).
#
# Environment: EVENT, RUN_SHA, REF_SHA, GITHUB_REF, INPUT_ENVIRONMENT,
# INPUT_MODE, REPO, GITHUB_OUTPUT; gh needs GH_TOKEN.
set -euo pipefail

fail() {
  echo "::error::$*"
  exit 1
}

case "${EVENT:?}" in
  workflow_run) environment=staging; sha="${RUN_SHA:?}"; mode=deploy ;;
  push) environment=production; sha="${REF_SHA:?}"; mode=deploy ;;
  workflow_dispatch) environment="${INPUT_ENVIRONMENT:?}"; sha="${REF_SHA:?}"; mode="${INPUT_MODE:?}" ;;
  *) fail "unexpected event $EVENT" ;;
esac
[[ "$environment" == staging || "$environment" == production ]] || fail "unknown environment $environment"
[[ "$mode" == deploy || "$mode" == rollback ]] || fail "unknown mode $mode"

if [[ "$environment" == production && "${GITHUB_REF:?}" != refs/tags/api-v* ]]; then
  fail "production runs only from a tag api-v*, not from $GITHUB_REF"
fi

if [[ "$EVENT" != workflow_run && "$mode" == deploy ]]; then
  conclusions="$(gh api "repos/${REPO:?}/commits/$sha/check-runs?check_name=ci-passed" \
    --jq '[.check_runs[].conclusion] | join(" ")')"
  if [[ " $conclusions " != *" success "* ]]; then
    fail "ci-passed has not succeeded on $sha (found: '${conclusions}')"
  fi
  # main is "ahead" of an older main commit, "identical" to its tip;
  # "behind" or "diverged" means the commit is not on main.
  on_main="$(gh api "repos/$REPO/compare/$sha...main" --jq .status)"
  if [[ "$on_main" != ahead && "$on_main" != identical ]]; then
    fail "$sha is not on main (compare: '${on_main}')"
  fi
fi

{
  echo "environment=$environment"
  echo "sha=$sha"
  echo "mode=$mode"
} >> "${GITHUB_OUTPUT:?}"
echo "$mode $sha to $environment"
