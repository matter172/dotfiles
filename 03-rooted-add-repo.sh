#!/bin/bash
# Adds third-party DNF repositories needed by later steps.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

checkbox "Add Proton Pass repository" bash -c \
  "curl -fsSL https://raw.githubusercontent.com/matter172/unofficial-proton-pass-rpm/refs/heads/main/setup.sh | bash"

checkbox "Add Terra repository" dnf install -y --nogpgcheck \
  --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
  --setopt="terra.gpgkey=https://repos.fyralabs.com/terra\$releasever/key.asc" \
  terra-release
