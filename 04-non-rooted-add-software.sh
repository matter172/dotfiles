#!/bin/bash
# Installs user-space apps: Zed, gnome-extensions-cli, Tiling Shell, Flatpaks.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

checkbox "Install Zed editor" bash -c "curl -f https://zed.dev/install.sh | sh"

checkbox "Add ~/.local/bin to PATH" bash -c \
  "echo 'export PATH=\$HOME/.local/bin:\$PATH' >> ~/.bashrc"

export PATH="$HOME/.local/bin:$PATH"

checkbox "Install gnome-extensions-cli" pipx install gnome-extensions-cli --system-site-packages

checkbox "Install Tiling Shell extension" gext install tilingshell@ferrarodomenico.com

FLATPAKS=(
  "com.brave.Browser|Brave Browser"
  "com.github.tchx84.Flatseal|Flatseal"
  "com.valvesoftware.Steam|Steam"
  "com.vysp3r.ProtonPlus|ProtonPlus"
  "com.heroicgameslauncher.hgl|Heroic Games Launcher"
  "com.belmoussaoui.Decoder|Decoder"
  "io.github.nozwock.Packet|Packet"
  "com.discordapp.Discord|Discord"
)

for entry in "${FLATPAKS[@]}"; do
  IFS='|' read -r app_id label <<< "$entry"
  checkbox "Install ${label}" flatpak install -y "$app_id"
done
