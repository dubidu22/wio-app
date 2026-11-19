#!/usr/bin/env bash
# Checks that a built APK asks for exactly the permissions in the allow-list,
# and that no camera or microphone is required to install it (#70,
# D-310..D-319).
#
# Usage: android-permissions-check.sh <apk> <allow-list> [<merger-report>]
#
# The allow-list has one entry per line, "uses-permission <name>" or
# "permission <name>"; "#" starts a comment; "${applicationId}" stands for the
# APK's package name. The merger report (build/app/outputs/logs/
# manifest-merger-<variant>-report.txt) is optional and only used to name the
# library that added a permission. AAPT2 overrides the aapt2 binary; by
# default the newest one under $ANDROID_HOME/build-tools is used.
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "usage: $0 <apk> <allow-list> [<merger-report>]" >&2
  exit 2
fi
apk="$1"
allow_list="$2"
report="${3:-}"

aapt2="${AAPT2:-}"
if [[ -z "$aapt2" ]]; then
  build_tools="$(find "${ANDROID_HOME:?ANDROID_HOME is not set}/build-tools" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -1)"
  aapt2="$build_tools/aapt2"
fi
[[ -f "$apk" ]] || { echo "::error::APK not found: $apk"; exit 1; }
[[ -f "$allow_list" ]] || { echo "::error::allow-list not found: $allow_list"; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

"$aapt2" dump permissions "$apk" > "$tmp/dump.txt"
"$aapt2" dump badging "$apk" > "$tmp/badging.txt"
echo "--- aapt2 dump permissions"
cat "$tmp/dump.txt"

package="$(sed -n "s/^package: \([A-Za-z0-9_.]*\).*/\1/p" "$tmp/dump.txt" | head -1)"
if [[ -z "$package" ]]; then
  echo "::error::aapt2 printed no package name for $apk"
  exit 1
fi

# "uses-permission: name='X' maxSdkVersion='28'" -> "uses-permission X"
# "permission: X"                                -> "permission X"
sed -n \
  -e "s/^uses-permission: name='\([^']*\)'.*/uses-permission \1/p" \
  -e "s/^permission: \([^ ]*\).*/permission \1/p" \
  "$tmp/dump.txt" | sort -u > "$tmp/actual.txt"
if [[ ! -s "$tmp/actual.txt" ]]; then
  echo "::error::no permissions read from $apk; did the aapt2 output format change?"
  exit 1
fi

sed -e 's/#.*//' -e 's/[[:space:]]\+/ /g' -e 's/^ //' -e 's/ $//' "$allow_list" \
  | grep -v '^$' \
  | sed "s/\${applicationId}/$package/g" \
  | sort -u > "$tmp/allowed.txt"
bad_lines="$(grep -Ev '^(uses-permission|permission) [A-Za-z0-9_.]+$' "$tmp/allowed.txt" || true)"
if [[ -n "$bad_lines" ]]; then
  echo "::error::allow-list $allow_list has lines that are not 'uses-permission <name>' or 'permission <name>': $bad_lines"
  exit 1
fi

blame() {
  # The merger report lists "uses-permission#<name>" followed by indented
  # ADDED/MERGED/IMPLIED/REJECTED lines naming the source manifest.
  local name="$1"
  [[ -n "$report" && -f "$report" ]] || return 0
  awk -v key="uses-permission#$name" '
    $0 == key { on = 1; next }
    on && /^[^ \t]/ && $0 !~ /^(ADDED|MERGED|IMPLIED|REJECTED|INJECTED)/ { exit }
    on { sub(/^[ \t]+/, ""); printf "%s%s", (n++ ? "; " : ""), $0 }
  ' "$report"
}

failed=0
while read -r kind name; do
  from="$(blame "$name")"
  echo "::error::The APK has $kind $name, which is not in $allow_list${from:+ (from: $from)}. Remove it in app/android/app/src/main/AndroidManifest.xml with tools:node=\"remove\", or add it to the allow-list with a reason."
  failed=1
done < <(comm -23 "$tmp/actual.txt" "$tmp/allowed.txt")
while read -r kind name; do
  echo "::error::The APK is missing $kind $name, which $allow_list lists. Remove it from the allow-list or declare it again."
  failed=1
done < <(comm -13 "$tmp/actual.txt" "$tmp/allowed.txt")

# Hardware: a phone without a camera or microphone may install the app
# (D-272). aapt2 prints a required feature as "uses-feature: name='X'" and
# one implied by a permission as "uses-implied-feature: name='X' reason=…";
# a declared not-required feature is "uses-feature-not-required: name='X'".
echo "--- features (aapt2 dump badging)"
grep -E "^(uses-feature|uses-feature-not-required|uses-implied-feature):" "$tmp/badging.txt" || true
echo "--- TEMP PROOF: badging feature lines"; grep -in "feature" "$tmp/badging.txt" || true
echo "--- TEMP PROOF: badging head"; head -40 "$tmp/badging.txt"
echo "--- TEMP PROOF: blame"; for n in android.permission.ACCESS_NETWORK_STATE android.permission.READ_EXTERNAL_STORAGE android.permission.CAMERA; do echo "$n: $(blame "$n")"; done
[[ -n "$report" ]] && { ls -la "$(dirname "$report")" || true; grep -n -A4 "ACCESS_NETWORK_STATE" "$report" || true; }
for feature in android.hardware.camera android.hardware.camera.any android.hardware.camera.autofocus android.hardware.microphone; do
  if grep -E "^(uses-feature|uses-implied-feature): name='${feature//./\\.}'" "$tmp/badging.txt" | grep -qv "required='false'"; then
    echo "::error::The APK requires $feature to install. Declare <uses-feature android:name=\"$feature\" android:required=\"false\"/> in the app manifest (D-272)."
    failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi
echo "The APK's permissions match $allow_list ($(wc -l < "$tmp/actual.txt") entries) and no camera or microphone is required."
