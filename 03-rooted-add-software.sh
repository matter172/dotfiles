#!/bin/bash
# Adds the Proton Pass repo + installs system packages, one at a time.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

checkbox "Add Proton Pass repository" bash -c \
  "curl -fsSL https://raw.githubusercontent.com/matter172/unofficial-proton-pass-rpm/refs/heads/main/setup.sh | bash"

PACKAGES=(
  "proton-pass"
  "pipx"
)

for pkg in "${PACKAGES[@]}"; do
  checkbox "Install ${pkg}" dnf install -y "$pkg"
done
