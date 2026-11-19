#!/usr/bin/env bash
# Tests for resolve.sh (plan 010): which runs go where, and which are refused.
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
  if PATH="$work/bin:$PATH" EVENT="$event" RUN_SHA=run1 REF_SHA=ref1 GITHUB_REF="$ref" \
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

if [[ "$failures" -gt 0 ]]; then
  echo "$failures case(s) failed"
  exit 1
fi
echo "all cases pass"
