#!/usr/bin/env bash
# Tests for the crash-line pattern of android-launch-check.sh (D-395, review of
# PR 92 M1): lines of the app's own process match; other processes' deaths
# and signals do not.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

LAUNCH_CHECK_SOURCE_ONLY=1
# shellcheck source=../android-launch-check.sh
source "$here/../android-launch-check.sh"

pkg=de.wiederinordnung.app.handtest

check() { # <name> <expected: yes|no> <log line>
  local name="$1" expected="$2" line="$3" got=no
  printf '%s\n' "$line" > "$work/log.txt"
  [[ -n "$(crash_lines "$work/log.txt" "$pkg")" ]] && got=yes
  if [[ "$got" == "$expected" ]]; then
    echo "ok   $name"
  else
    echo "FAIL $name: expected $expected, got $got"
    failures=$((failures + 1))
  fi
}

# The real crash of run 44553441671 (Room constructor removed by R8).
check "java crash of the app" yes \
  "11-19 15:41:58.590  3570  3570 E AndroidRuntime: Process: $pkg, PID: 3570"
check "app process died" yes \
  "11-19 15:50:00.000   900   900 I ActivityManager: Process $pkg (pid 3570) has died: fg  TOP"
check "native crash tombstone" yes \
  "11-19 15:50:00.000   901   901 F DEBUG   : pid: 5, tid: 5, name: wio  >>> $pkg <<<"
check "another app dies" no \
  "11-19 15:50:00.000   900   900 I ActivityManager: Process com.google.android.gms (pid 999) has died: cch  CACH"
check "another process, fatal signal" no \
  "11-19 15:50:01.000   901   901 F libc    : Fatal signal 11 (SIGSEGV) in tid 5 (gms), pid 5"
check "another app, java crash" no \
  "11-19 15:50:01.000   901   901 E AndroidRuntime: Process: com.google.android.gms, PID: 77"
check "a similar package name" no \
  "11-19 15:50:01.000   901   901 E AndroidRuntime: Process: ${pkg}x, PID: 77"
check "empty log" no ""

((failures == 0)) || { echo "$failures failed"; exit 1; }
echo "all passed"
