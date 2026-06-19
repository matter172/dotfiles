#!/bin/bash
# Installs system packages from repos added in 03-rooted-add-repos.sh.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

PACKAGES=(
  "proton-pass"
  "pipx"
  "zed"
)

for pkg in "${PACKAGES[@]}"; do
  checkbox "Install ${pkg}" dnf install -y "$pkg"
done
