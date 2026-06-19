#!/bin/bash
# Full Fedora system update.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

checkbox "Update Fedora packages" dnf update -y
