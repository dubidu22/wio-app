#!/usr/bin/env bash
# Tests for flutter-test.sh (D-35) with a fake `flutter` that writes a JSON
# report like the real one.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../flutter-test.sh"
fake_bin="$(mktemp -d)"
trap 'rm -rf "$fake_bin"' EXIT
failures=0

# The fake reads FAKE_EVENTS (JSON lines) and FAKE_EXIT from the environment.
cat > "$fake_bin/flutter" <<'FAKE'
#!/usr/bin/env bash
report=""
while [[ $# -gt 0 ]]; do
  if [[ "$1" == "--file-reporter" ]]; then report="${2#json:}"; shift; fi
  shift
done
printf '%s\n' "$FAKE_EVENTS" > "$report"
exit "${FAKE_EXIT:-0}"
FAKE
chmod +x "$fake_bin/flutter"

passed='{"type":"testDone","testID":1,"result":"success","skipped":false,"hidden":false}'
skipped='{"type":"testDone","testID":2,"result":"success","skipped":true,"hidden":false}'
hidden='{"type":"testDone","testID":3,"result":"success","skipped":false,"hidden":true}'
done_event='{"type":"done","success":true}'

expect() {
  local want="$1" label="$2" events="$3" exit_code="$4"
  local got
  if PATH="$fake_bin:$PATH" FAKE_EVENTS="$events" FAKE_EXIT="$exit_code" "$script" --tags x > /dev/null 2>&1; then
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

expect pass "one test passed"                    "$passed"$'\n'"$done_event" 0
expect fail "no test ran"                        "$done_event" 0
expect fail "every test was skipped"             "$skipped"$'\n'"$done_event" 0
expect fail "only hidden setup tests ran"        "$hidden"$'\n'"$done_event" 0
expect fail "flutter test itself failed"         "$passed"$'\n'"$done_event" 1
expect fail "flutter reported no matching tests" "" 79

if [[ "$failures" -gt 0 ]]; then
  echo "$failures case(s) failed"
  exit 1
fi
echo "all flutter-test cases passed"
