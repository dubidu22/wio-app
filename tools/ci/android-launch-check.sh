#!/usr/bin/env bash
# Starts a built APK on an Android 14 emulator and fails when the app dies at
# launch (#91, plan 091, D-393..D-396). Used by the android-launch-smoke and
# android-handtest workflows, so a release build that crashes at start never
# reaches a person's phone.
#
# Usage: android-launch-check.sh <apk> <package> <logcat-out>
#
# The emulator boots with plain SDK tools from $ANDROID_HOME (no third-party
# action). The app is installed, launched like a tap on its icon, and left
# alone for 20 s. It fails when the process is gone or when logcat names this
# app's process in a crash line. The full logcat is written to <logcat-out>
# even on failure; it is the diagnosis.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$here/lib/android-crash-lines.sh"

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <apk> <package> <logcat-out>" >&2
  exit 2
fi
apk="$1"
package="$2"
logcat_out="$3"
[[ -f "$apk" ]] || { echo "::error::APK not found: $apk"; exit 1; }

sdk="${ANDROID_HOME:?ANDROID_HOME is not set}"
adb="$sdk/platform-tools/adb"
image="system-images;android-34;google_apis;x86_64"
work="$(mktemp -d)"
emulator_log="$work/emulator.log"

# The runner has KVM; the rule lets the emulator use it.
echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' \
  | sudo tee /etc/udev/rules.d/99-kvm4all.rules > /dev/null
sudo udevadm control --reload-rules
sudo udevadm trigger --name-match=kvm

sdkm="$sdk/cmdline-tools/latest/bin/sdkmanager"
yes | "$sdkm" --licenses > /dev/null || true
"$sdkm" "emulator" "platform-tools" "$image" > /dev/null
export ANDROID_AVD_HOME="$HOME/.android/avd"
mkdir -p "$ANDROID_AVD_HOME"
echo no | "$sdk/cmdline-tools/latest/bin/avdmanager" create avd -n wio -k "$image" -d pixel_6 --force
"$adb" start-server
setsid nohup "$sdk/emulator/emulator" -avd wio -no-window -no-audio -no-boot-anim -no-snapshot \
  -gpu swiftshader_indirect < /dev/null > "$emulator_log" 2>&1 &

booted=0
for _ in $(seq 1 60); do
  if [[ "$(timeout 10 "$adb" shell getprop sys.boot_completed 2> /dev/null | tr -d '\r')" == 1 ]]; then
    booted=1
    break
  fi
  sleep 5
done
if [[ "$booted" != 1 ]]; then
  echo "::error::the emulator did not boot in time"
  "$adb" devices || true
  tail -n 60 "$emulator_log" || true
  exit 1
fi
"$adb" shell input keyevent 82 || true

"$adb" install -r "$apk"
"$adb" logcat -c
"$adb" shell monkey -p "$package" -c android.intent.category.LAUNCHER 1
sleep 20
"$adb" logcat -d > "$logcat_out"

failed=0
pid="$("$adb" shell pidof "$package" | tr -d '\r' || true)"
echo "pid=${pid:-none}"
if [[ -z "$pid" ]]; then
  echo "::error::the app is not running 20 s after launch"
  failed=1
fi
if [[ -n "$(crash_lines "$logcat_out" "$package")" ]]; then
  echo "::error::crash lines for $package in logcat, see the log artifact"
  failed=1
fi
if ((failed)); then
  echo "---- crash lines ----"
  grep -n -B2 -A40 -m1 'FATAL EXCEPTION' "$logcat_out" | head -n 120 || true
  grep -n -B5 -A30 -m1 'Fatal signal' "$logcat_out" | head -n 80 || true
fi
exit "$failed"
