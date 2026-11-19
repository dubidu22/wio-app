#!/usr/bin/env bash
# Tests for android-permissions-check.sh (D-315, D-316): a fake aapt2 prints
# the permission and badging dumps; each case must pass or fail as stated,
# and a failure must name the permission or feature.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../android-permissions-check.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

# Fake aapt2: "dump permissions" prints $work/perms.txt, "dump badging"
# prints $work/badging.txt, "fail" in $work/mode makes it exit 1.
cat > "$work/aapt2" <<'EOF'
#!/usr/bin/env bash
dir="$(dirname "$0")"
[[ "$(cat "$dir/mode" 2>/dev/null)" == fail ]] && { echo "aapt2: broken" >&2; exit 1; }
case "$1 $2" in
  "dump permissions") cat "$dir/perms.txt" ;;
  "dump badging") cat "$dir/badging.txt" ;;
  *) exit 2 ;;
esac
EOF
chmod +x "$work/aapt2"
touch "$work/app.apk"

# Today's APK after D-313 (main 5d34cec without READ_EXTERNAL_STORAGE), with
# WorkManager's WAKE_LOCK and RECEIVE_BOOT_COMPLETED (#52, D-379).
good_perms() {
  local package="${1:-de.wiederinordnung.app}"
  cat <<EOF
package: $package
uses-permission: name='android.permission.INTERNET'
uses-permission: name='android.permission.RECORD_AUDIO'
uses-permission: name='android.permission.CAMERA'
permission: $package.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
uses-permission: name='$package.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
uses-permission: name='android.permission.ACCESS_NETWORK_STATE'
uses-permission: name='android.permission.WAKE_LOCK'
uses-permission: name='android.permission.RECEIVE_BOOT_COMPLETED'
EOF
}
good_badging() {
  cat <<'EOF'
package: name='de.wiederinordnung.app' versionCode='1' versionName='0.1.0'
feature-group: label=''
  uses-feature-not-required: name='android.hardware.camera'
  uses-feature-not-required: name='android.hardware.camera.any'
  uses-feature-not-required: name='android.hardware.camera.autofocus'
  uses-feature-not-required: name='android.hardware.microphone'
  uses-feature: name='android.hardware.faketouch'
  uses-implied-feature: name='android.hardware.faketouch' reason='default feature for all apps'
EOF
}
cp "$here/../../../app/android/permissions.txt" "$work/allow.txt"
sed 's/\\t/\t/g' > "$work/report.txt" <<'EOF'
uses-permission#android.permission.READ_EXTERNAL_STORAGE
IMPLIED from /x/app/src/main/AndroidManifest.xml:1:1-60:12 reason: io.flutter.plugins.camerax has a targetSdkVersion < 16
uses-permission#android.permission.RECORD_AUDIO
ADDED from /x/app/src/main/AndroidManifest.xml:10:5-70
MERGED from [:camera_android_camerax] /x/camera_android_camerax/AndroidManifest.xml:10:5-71
MERGED from [:camera_android_camerax] /x/camera_android_camerax/AndroidManifest.xml:10:5-71
	android:name
		ADDED from /x/app/src/main/AndroidManifest.xml:10:22-68
uses-permission#android.permission.CAMERA
ADDED from [:camera_android_camerax] /x/camera_android_camerax/AndroidManifest.xml:4:3-62
	android:name
		ADDED from [:camera_android_camerax] /x/camera_android_camerax/AndroidManifest.xml:4:20-60
uses-permission#android.permission.ACCESS_NETWORK_STATE
ADDED from [androidx.media3:media3-common:1.9.0] /x/media3-common-1.9.0/AndroidManifest.xml:22:5-79
	android:name
		ADDED from [androidx.media3:media3-common:1.9.0] /x/media3-common-1.9.0/AndroidManifest.xml:22:22-76
meta-data#androidx.profileinstaller.ProfileInstallerInitializer
EOF

# expect pass|fail "label" [text that the output must contain]
expect() {
  local want="$1" label="$2" needle="${3:-}" got out
  if out="$(AAPT2="$work/aapt2" "$script" "$work/app.apk" "$work/allow.txt" "$work/report.txt" 2>&1)"; then
    got=pass
  else
    got=fail
  fi
  if [[ "$got" != "$want" ]]; then
    echo "FAIL $label: expected $want, got $got"
    printf '     | %s\n' "$out"
    failures=$((failures + 1))
  elif [[ -n "$needle" ]] && ! grep -qF -- "$needle" <<< "$out"; then
    echo "FAIL $label: output lacks: $needle"
    printf '     | %s\n' "$out"
    failures=$((failures + 1))
  else
    echo "ok   $label"
  fi
}

reset() {
  good_perms > "$work/perms.txt"
  good_badging > "$work/badging.txt"
  cp "$here/../../../app/android/permissions.txt" "$work/allow.txt"
  rm -f "$work/mode"
}

reset
expect pass "the committed allow-list matches today's APK" "match"

reset
echo "uses-permission: name='android.permission.READ_EXTERNAL_STORAGE'" >> "$work/perms.txt"
expect fail "an extra permission fails and is named" "has uses-permission android.permission.READ_EXTERNAL_STORAGE"
expect fail "an extra permission names the manifest that added it" "IMPLIED from /x/app/src/main/AndroidManifest.xml"

reset
sed -i "s/name='android.permission.CAMERA'/name='android.permission.CAMERA' maxSdkVersion='28'/" "$work/perms.txt"
expect pass "attributes after the name are ignored"

reset
sed -i "/RECORD_AUDIO/d" "$work/perms.txt"
expect fail "a missing permission fails and is named" "missing uses-permission android.permission.RECORD_AUDIO"

reset
sed -i "/^permission: /d" "$work/perms.txt"
expect fail "a missing declared permission fails" "missing permission de.wiederinordnung.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"

reset
good_perms de.wiederinordnung.app.handtest > "$work/perms.txt"
expect pass "\${applicationId} follows the hand-test package"

reset
printf '\n   # only a comment\n\n' >> "$work/allow.txt"
expect pass "blank and comment lines are ignored"

reset
echo "uses-permision android.permission.INTERNET" >> "$work/allow.txt"
expect fail "a malformed allow-list line fails" "uses-permision"

reset
echo "package: de.wiederinordnung.app" > "$work/perms.txt"
expect fail "an APK with no permissions read fails rather than passes" "no permissions read"

reset
echo fail > "$work/mode"
expect fail "an aapt2 failure fails the check"

reset
sed -i "/RECORD_AUDIO/d" "$work/allow.txt"
expect fail "blame keeps top-level lines once each" "(from: ADDED from /x/app/src/main/AndroidManifest.xml:10:5-70; MERGED from [:camera_android_camerax] /x/camera_android_camerax/AndroidManifest.xml:10:5-71)"

reset
sed -i "/ACCESS_NETWORK_STATE/d" "$work/allow.txt"
expect fail "a library permission names the library" "(from: ADDED from [androidx.media3:media3-common:1.9.0] /x/media3-common-1.9.0/AndroidManifest.xml:22:5-79)"

reset
sed -i "/'android.hardware.microphone'/d" "$work/badging.txt"
expect fail "a feature not declared as not required fails" "android.hardware.microphone"

reset
sed -i "/'android.hardware.camera'/d" "$work/badging.txt"
echo "  uses-feature-not-required: name='android.hardware.camera'" >> "$work/badging.txt"
echo "  uses-implied-feature: name='android.hardware.camera' reason='requested android.permission.CAMERA permission, and targetSdkVersion > 4'" >> "$work/badging.txt"
expect fail "an implied required camera fails" "requires android.hardware.camera to install"

reset
sed -i "/microphone/d" "$work/badging.txt"
echo "  uses-feature-not-required: name='android.hardware.microphone'" >> "$work/badging.txt"
echo "  uses-feature: name='android.hardware.microphone'" >> "$work/badging.txt"
expect fail "a required microphone fails" "requires android.hardware.microphone to install"

reset
echo "  uses-feature: name='android.hardware.camera.anything'" >> "$work/badging.txt"
expect pass "a required feature with a longer name is not mistaken for camera.any"

if [[ "$failures" -gt 0 ]]; then
  echo "$failures case(s) failed"
  exit 1
fi
echo "all android-permissions-check cases passed"
