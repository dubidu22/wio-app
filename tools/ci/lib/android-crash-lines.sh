#!/usr/bin/env bash
# Sourced by android-launch-check.sh and its test (#91, D-395).
#
# crash_lines <logcat> <package> prints the lines that name THIS app's process
# in a crash. Other processes on the emulator may die or print "Fatal signal"
# without being our crash. A native crash shows as the tombstone header
# (">>> package <<<") and as a dead pid (review of PR 92, M1).
crash_lines() {
  local logcat="$1" package="$2"
  grep -E "Process: ${package}, PID|Process ${package} \(pid [0-9]+\) has died|>>> ${package} <<<" "$logcat" || true
}
