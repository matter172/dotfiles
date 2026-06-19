#!/bin/bash
# Full Fedora system update, shown as one checkbox per package.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

echo "  Checking for updates..."

# dnf check-update exits 100 if updates are available, 0 if none, 1+ on error.
# Output lines look like: <pkg>.<arch>  <new-version>  <repo>
UPDATE_OUTPUT=$(dnf check-update -q 2>>"$LOG_FILE")
status=$?

if [ "$status" -eq 0 ]; then
  echo "  Nothing to update."
  exit 0
elif [ "$status" -ne 100 ]; then
  echo "  dnf check-update failed (exit ${status}) — see log."
  echo "$UPDATE_OUTPUT" >> "$LOG_FILE"
  exit 1
fi

# Parse package names: lines with an arch suffix, first column, strip the arch.
PACKAGES=()
while IFS= read -r line; do
  [ -z "$line" ] && continue
  case "$line" in
    *.x86_64\ *|*.noarch\ *|*.i686\ *|*.aarch64\ *)
      pkg="${line%%.*}"
      PACKAGES+=("$pkg")
      ;;
  esac
done <<< "$UPDATE_OUTPUT"

if [ "${#PACKAGES[@]}" -eq 0 ]; then
  echo "  Nothing to update."
  exit 0
fi

echo "  ${#PACKAGES[@]} package(s) to update."

for pkg in "${PACKAGES[@]}"; do
  checkbox "Update ${pkg}" dnf update -y "$pkg"
done
