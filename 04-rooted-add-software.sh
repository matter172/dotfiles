#!/bin/bash
# Installs system packages from repos added in 03-rooted-add-repo.sh.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

PACKAGES=(
  "proton-pass"
  "pipx"
  "zed"
  "steam-devices"
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
  "akmod-nvidia"
  "xorg-x11-drv-nvidia-cuda"
  "gnome-tweaks"
  "fuse"
  "fuse-libs"
)

for pkg in "${PACKAGES[@]}"; do
  checkbox "Install ${pkg}" dnf install -y "$pkg"
done
