#!/usr/bin/env bash
# Tests for resolve.sh (plan 010, plan 080): which runs go where, and which
# are refused, for deploy-api and for deploy-web.
# A fake gh answers the ci-passed and compare calls.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../resolve.sh"
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/bin"
cat > "$work/bin/gh" << 'EOF'
#!/usr/bin/env bash
# Fake gh: FAKE_CI is the ci-passed conclusion list, FAKE_COMPARE the status.
case "$2" in
  */check-runs*) echo "$FAKE_CI" ;;
  */compare/*) echo "$FAKE_COMPARE" ;;
  */actions/runs/77/jobs) printf '%b' "$FAKE_JOBS" ;;
  *) echo "unexpected gh call: $*" >&2; exit 2 ;;
esac
EOF
chmod +x "$work/bin/gh"
failures=0

# expect WANT LABEL EVENT REF ENVIRONMENT MODE CI COMPARE
# WANT is "fail" or the expected "environment sha mode" output.
expect() {
  local want="$1" label="$2" event="$3" ref="$4" env="$5" mode="$6" ci="$7" compare="$8"
  local out="$work/output" got
  : > "$out"
  if PATH="$work/bin:$PATH" WIO_TAG_PREFIX="${PREFIX:-}" WIO_ALWAYS_CHECK_CI="${ALWAYS:-}" \
    WIO_PUBSPEC="${PUBSPEC:-}" WIO_CHAINED_RUN_ID="${RUN_ID:-}" FAKE_JOBS="${JOBS:-}" EVENT="$event" RUN_SHA=run1 REF_SHA=ref1 GITHUB_REF="$ref" \
    INPUT_ENVIRONMENT="$env" INPUT_MODE="$mode" REPO=o/r GITHUB_OUTPUT="$out" \
    FAKE_CI="$ci" FAKE_COMPARE="$compare" "$script" > /dev/null 2>&1; then
    got="$(sed 's/^[a-z]*=//' "$out" | paste -sd ' ')"
  else
    got=fail
  fi
  if [[ "$got" == "$want" ]]; then
    echo "ok   $label"
  else
    echo "FAIL $label: expected '$want', got '$got'"
    failures=$((failures + 1))
  fi
}

expect "staging run1 deploy" "ci run on main deploys staging without extra checks" \
  workflow_run refs/heads/main "" "" "" ""
expect "production ref1 deploy" "tag push on main deploys production" \
  push refs/tags/api-v0.1.0 "" "" "success" ahead
expect fail "tag push without ci-passed is refused" \
  push refs/tags/api-v0.1.0 "" "" "failure" ahead
expect fail "tag on a commit that is not on main is refused (M2)" \
  push refs/tags/api-v0.1.0 "" "" "success" diverged
expect fail "PR head with green ci-passed is refused (M2)" \
  workflow_dispatch refs/heads/feature staging deploy "success" behind
expect "staging ref1 deploy" "dispatch on the tip of main deploys staging" \
  workflow_dispatch refs/heads/main staging deploy "success" identical
expect fail "production dispatch from main is refused (M1)" \
  workflow_dispatch refs/heads/main production deploy "success" identical
expect fail "production rollback from a branch is refused (M1)" \
  workflow_dispatch refs/heads/main production rollback "" ""
expect "production ref1 rollback" "production rollback from a tag runs without ci checks" \
  workflow_dispatch refs/tags/api-v0.1.0 production rollback "" ""
expect "staging ref1 rollback" "staging rollback from any branch" \
  workflow_dispatch refs/heads/feature staging rollback "" ""
expect fail "unknown mode is refused" \
  workflow_dispatch refs/heads/main staging restart "" ""

# deploy-web (plan 080, D-359, D-360): tag prefix app-v, ci-passed always
# checked, the tag must match pubspec.yaml's version.
printf 'name: wio\nversion: 1.2.3+45 # comment\n' > "$work/pubspec.yaml"
web() { PREFIX=app-v ALWAYS=true PUBSPEC="$work/pubspec.yaml" expect "$@"; }
web "staging run1 deploy" "web: chained run after deploy-api deploys staging when ci-passed is green" \
  workflow_run refs/heads/main "" "" "success" identical
web fail "web: chained run whose commit has no green ci-passed is refused" \
  workflow_run refs/heads/main "" "" "failure" identical
web fail "web: chained run without any ci-passed is refused" \
  workflow_run refs/heads/main "" "" "" identical
web "production ref1 deploy" "web: tag app-v1.2.3 matching pubspec deploys production" \
  push refs/tags/app-v1.2.3 "" "" "success" ahead
web fail "web: tag app-v1.2.4 not matching pubspec 1.2.3 is refused" \
  push refs/tags/app-v1.2.4 "" "" "success" ahead
web fail "web: tag api-v1.2.3 cannot deploy the web app to production" \
  push refs/tags/api-v1.2.3 "" "" "success" ahead
expect fail "api: tag app-v1.2.3 cannot deploy the API to production" \
  push refs/tags/app-v1.2.3 "" "" "success" ahead
web "production ref1 rollback" "web: production rollback from an app-v tag skips the version check" \
  workflow_dispatch refs/tags/app-v1.0.0 production rollback "" ""
# Plan 080 F1: the chained run deploys the commit deploy-api deployed, not
# the run's head_sha (run1 here).
x=1111111111111111111111111111111111111111
y=2222222222222222222222222222222222222222
RUN_ID=77 JOBS="resolve\ndeploy (staging, $x)\n" web "staging $x deploy" \
  "web: chained run deploys the commit deploy-api deployed, not the run's head_sha" \
  workflow_run refs/heads/main "" "" "success" ahead
RUN_ID=77 JOBS="resolve\n" web "staging  skip" \
  "web: chained run whose deploy-api deployed nothing (skipped or failed job) skips" \
  workflow_run refs/heads/main "" "" "" ""
RUN_ID=77 JOBS="resolve\ndeploy (production, $x)\n" web "staging  skip" \
  "web: a production deploy job is never followed into staging" \
  workflow_run refs/heads/main "" "" "" ""
RUN_ID=77 JOBS="deploy (staging, $x)\ndeploy (staging, $y)\n" web fail \
  "web: two deployed commits in one run are refused" \
  workflow_run refs/heads/main "" "" "success" ahead
RUN_ID=77 JOBS="deploy (staging, $x)\n" web fail \
  "web: the followed commit still needs green ci-passed" \
  workflow_run refs/heads/main "" "" "failure" ahead
RUN_ID='77;x' JOBS="" web fail "web: a malformed run id is refused" \
  workflow_run refs/heads/main "" "" "success" ahead
PREFIX='x/../' expect fail "a malformed tag prefix is refused" \
  push refs/tags/api-v0.1.0 "" "" "success" ahead

if [[ "$failures" -gt 0 ]]; then
  echo "$failures case(s) failed"
  exit 1
fi
echo "all cases pass"
