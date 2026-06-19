#!/bin/bash
# Sets the GNOME Dash (Activities overview) favorites, in order.
# Runs as the current user (gsettings is per-user, not system-wide).

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

# Desired apps, in order. Each entry is a list of candidate .desktop names
# (without the .desktop suffix) to try, since exact filenames vary by
# distro/packaging. The first one found on the system is used.
declare -A CANDIDATES=(
  ["Files"]="org.gnome.Nautilus"
  ["Brave"]="com.brave.Browser"
  ["Discord"]="com.discordapp.Discord"
  ["Steam"]="com.valvesoftware.Steam"
  ["Heroic"]="com.heroicgameslauncher.hgl"
  ["Zed"]="dev.zed.Zed zed zeditor"
  ["Terminal"]="app.devsuite.Ptyxis org.gnome.Ptyxis org.gnome.Console org.gnome.Terminal"
)

ORDER=("Files" "Brave" "Discord" "Steam" "Heroic" "Zed" "Terminal")

SEARCH_DIRS=(
  "/usr/share/applications"
  "/var/lib/flatpak/exports/share/applications"
  "${HOME}/.local/share/flatpak/exports/share/applications"
  "${HOME}/.local/share/applications"
)

find_desktop_file() {
  local candidates="$1"
  for name in $candidates; do
    for dir in "${SEARCH_DIRS[@]}"; do
      if [ -f "${dir}/${name}.desktop" ]; then
        echo "${name}.desktop"
        return 0
      fi
    done
  done
  return 1
}

FAVORITES=()
MISSING=()

for app in "${ORDER[@]}"; do
  desktop_file=$(find_desktop_file "${CANDIDATES[$app]}")
  if [ -n "$desktop_file" ]; then
    FAVORITES+=("$desktop_file")
    echo "  Found ${app} -> ${desktop_file}" >> "$LOG_FILE"
  else
    MISSING+=("$app")
    echo "  Could not find a .desktop file for ${app} (tried: ${CANDIDATES[$app]})" >> "$LOG_FILE"
  fi
done

# Build the gsettings array literal: ['a.desktop', 'b.desktop', ...]
GSETTINGS_VALUE="["
for i in "${!FAVORITES[@]}"; do
  [ "$i" -gt 0 ] && GSETTINGS_VALUE+=", "
  GSETTINGS_VALUE+="'${FAVORITES[$i]}'"
done
GSETTINGS_VALUE+="]"

checkbox "Set Dash favorites (${#FAVORITES[@]}/${#ORDER[@]} found)" \
  gsettings set org.gnome.shell favorite-apps "$GSETTINGS_VALUE"

if [ "${#MISSING[@]}" -gt 0 ]; then
  echo "  Note: could not find .desktop files for: ${MISSING[*]}"
  echo "  These were skipped. See log for details."
fi
