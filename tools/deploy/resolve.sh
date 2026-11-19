#!/usr/bin/env bash
# Decides environment, commit and mode of a deploy-api or deploy-web run, and
# refuses runs that must not happen (plan 010, D-160, MRG-01; plan 080,
# D-359). Called by the resolve job of .github/workflows/deploy-api.yml and
# deploy-web.yml; writes environment, sha and mode to $GITHUB_OUTPUT.
#
# Guards:
#   - production only from a tag <prefix>* (deploy and rollback), so a
#     dispatch from a branch never reaches production even before the GitHub
#     environment has its own deployment rule;
#   - every deploy that does not come from a successful ci run on main needs
#     ci-passed on the commit AND the commit on main (a PR head can have a
#     green ci-passed too); with WIO_ALWAYS_CHECK_CI=true also the chained
#     staging deploy (deploy-web after deploy-api: a deploy-api run whose
#     jobs were skipped still completes as success);
#   - with WIO_CHAINED_RUN_ID (deploy-web after deploy-api), the staging
#     commit is the one that run's successful job "deploy (staging, <sha>)"
#     deployed, not the run's head_sha (which is the newest commit on main
#     when the run was created); no such job means mode=skip (plan 080 F1);
#   - with WIO_PUBSPEC, a production deploy's tag <prefix>X.Y.Z must equal the
#     version in that pubspec.yaml without its +build (D-360).
#
# Environment: EVENT, RUN_SHA, REF_SHA, GITHUB_REF, INPUT_ENVIRONMENT,
# INPUT_MODE, REPO, GITHUB_OUTPUT; optional WIO_TAG_PREFIX (default api-v),
# WIO_ALWAYS_CHECK_CI (default false), WIO_PUBSPEC, WIO_CHAINED_RUN_ID;
# gh needs GH_TOKEN (and actions: read for WIO_CHAINED_RUN_ID).
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

if [[ "$EVENT" == workflow_run && -n "${WIO_CHAINED_RUN_ID:-}" ]]; then
  [[ "$WIO_CHAINED_RUN_ID" =~ ^[0-9]+$ ]] || fail "unexpected run id $WIO_CHAINED_RUN_ID"
  names="$(gh api "repos/${REPO:?}/actions/runs/$WIO_CHAINED_RUN_ID/jobs" \
    --jq '.jobs[] | select(.conclusion == "success") | .name')"
  deployed="$(sed -n 's/^deploy (staging, \([0-9a-f]\{40\}\))$/\1/p' <<< "$names" | sort -u)"
  if [[ -z "$deployed" ]]; then
    echo "::notice::run $WIO_CHAINED_RUN_ID deployed nothing to staging: nothing to follow"
    {
      echo "environment=staging"
      echo "sha="
      echo "mode=skip"
    } >> "${GITHUB_OUTPUT:?}"
    exit 0
  fi
  [[ "$(wc -l <<< "$deployed")" == 1 ]] || fail "run $WIO_CHAINED_RUN_ID deployed more than one commit: $deployed"
  sha="$deployed"
fi
[[ "$mode" == deploy || "$mode" == rollback ]] || fail "unknown mode $mode"

prefix="${WIO_TAG_PREFIX:-api-v}"
[[ "$prefix" =~ ^[a-z]+-v$ ]] || fail "unexpected tag prefix $prefix"
if [[ "$environment" == production && "${GITHUB_REF:?}" != "refs/tags/$prefix"* ]]; then
  fail "production runs only from a tag $prefix*, not from $GITHUB_REF"
fi

if [[ "$environment" == production && "$mode" == deploy && -n "${WIO_PUBSPEC:-}" ]]; then
  tag_version="${GITHUB_REF#refs/tags/"$prefix"}"
  pubspec_version="$(sed -n 's/^version:[[:space:]]*\([^[:space:]#]*\).*/\1/p' "$WIO_PUBSPEC" | head -n 1)"
  pubspec_version="${pubspec_version%%+*}"
  [[ -n "$pubspec_version" ]] || fail "no version: line in $WIO_PUBSPEC"
  if [[ "$tag_version" != "$pubspec_version" ]]; then
    fail "tag $prefix$tag_version does not match version $pubspec_version in $WIO_PUBSPEC"
  fi
fi

if [[ ("$EVENT" != workflow_run || "${WIO_ALWAYS_CHECK_CI:-false}" == true) && "$mode" == deploy ]]; then
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
