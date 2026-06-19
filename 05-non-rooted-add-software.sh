#!/bin/bash
# Installs user-space apps: gnome-extensions-cli, Tiling Shell, Flatpaks.

LOG_FILE="${1:-/dev/null}"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_DIR}/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

checkbox "Install gnome-extensions-cli" pipx install gnome-extensions-cli --system-site-packages

EXTENSIONS=(
  "tilingshell@ferrarodomenico.com|Tiling Shell"
  "caffeine@patapon.info|Caffeine"
)

for entry in "${EXTENSIONS[@]}"; do
  IFS='|' read -r ext_uuid label <<< "$entry"
  checkbox "Install ${label} extension" gext install "$ext_uuid"
done

FLATPAKS=(
  "com.brave.Browser|Brave Browser"
  "com.github.tchx84.Flatseal|Flatseal"
  "com.valvesoftware.Steam|Steam"
  "com.vysp3r.ProtonPlus|ProtonPlus"
  "com.heroicgameslauncher.hgl|Heroic Games Launcher"
  "com.belmoussaoui.Decoder|Decoder"
  "io.github.nozwock.Packet|Packet"
  "com.discordapp.Discord|Discord"
  "gamescope|Gamescope"
)

for entry in "${FLATPAKS[@]}"; do
  IFS='|' read -r app_id label <<< "$entry"
  checkbox "Install ${label}" flatpak install -y --noninteractive flathub "$app_id"
done
