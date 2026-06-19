#!/bin/bash
# Disables auto-sleep, screen dimming, and lid-close suspend while on AC power.
# Runs as the current user (gsettings is per-user, not system-wide).
# Only affects AC (charging) behavior; battery settings are left untouched.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

SETTINGS=(
  "sleep-inactive-ac-type|nothing|Disable auto-sleep on AC"
  "idle-dim|false|Disable screen dimming on AC"
  "lid-close-ac-action|nothing|Disable lid-close suspend on AC"
)

for entry in "${SETTINGS[@]}"; do
  IFS='|' read -r key value label <<< "$entry"
  checkbox "$label" gsettings set org.gnome.settings-daemon.plugins.power "$key" "$value"
done
