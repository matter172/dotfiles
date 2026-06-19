#!/bin/bash
# Disables auto-sleep, screen dimming, and lid-close suspend while on AC power.
# Runs as the current user (gsettings is per-user, not system-wide).
# Only affects AC (charging) behavior; battery settings are left untouched.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

SCHEMA="org.gnome.settings-daemon.plugins.power"
AVAILABLE_KEYS=$(gsettings list-keys "$SCHEMA" 2>/dev/null)

# Each entry: candidate key names (space-separated, tried in order) | value | label
SETTINGS=(
  "sleep-inactive-ac-type|nothing|Disable auto-sleep on AC"
  "idle-dim|false|Disable screen dimming on AC"
  "lid-close-ac-action|nothing|Disable lid-close suspend on AC"
)

key_exists() {
  local key="$1"
  echo "$AVAILABLE_KEYS" | grep -qx "$key"
}

for entry in "${SETTINGS[@]}"; do
  IFS='|' read -r key value label <<< "$entry"
  if key_exists "$key"; then
    checkbox "$label" gsettings set "$SCHEMA" "$key" "$value"
  else
    printf "  \033[2m[skip]\033[0m %s (key '%s' not present on this system)\n" "$label" "$key"
    echo "===== ${label} =====" >> "$LOG_FILE"
    echo "Skipped: key '${key}' not found in ${SCHEMA}. Available keys:" >> "$LOG_FILE"
    echo "$AVAILABLE_KEYS" >> "$LOG_FILE"
  fi
done
