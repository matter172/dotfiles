#!/bin/bash
set -e

BASE_URL="https://raw.githubusercontent.com/matter172/dotfiles/main"
BUST="?$(date +%s)"
TMP_DIR=$(mktemp -d)
LOG_FILE="${TMP_DIR}/setup.log"

# Colors
BOLD=$'\033[1m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'

STEPS=(
  "01-rooted-remove-software.sh|Removing default GNOME software|sudo"
  "02-rooted-update-fedora.sh|Updating Fedora|sudo"
  "03-rooted-add-software.sh|Installing system packages|sudo"
  "04-non-rooted-add-software.sh|Installing user apps and Flatpaks|user"
)

TOTAL=${#STEPS[@]}

echo "${BOLD}dotfiles setup${RESET}"
echo "${DIM}Logging full output to ${LOG_FILE}${RESET}"
echo

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

spinner() {
  local pid=$1
  local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i + 1) % ${#frames} ))
    printf "\r  %s" "${frames:$i:1}"
    sleep 0.1
  done
}

run_step() {
  local index="$1" script="$2" title="$3" mode="$4"
  local path="${TMP_DIR}/${script}"
  local prefix="[${index}/${TOTAL}]"

  printf "%s %s" "$prefix" "$title"

  {
    if [ "$mode" = "sudo" ]; then
      sudo bash "$path"
    else
      bash "$path"
    fi
  } >> "$LOG_FILE" 2>&1 &

  local pid=$!
  spinner "$pid"

  if wait "$pid"; then
    printf "\r${GREEN}✓${RESET} %s %s\n" "$prefix" "$title"
  else
    printf "\r${RED}✗${RESET} %s %s\n" "$prefix" "$title"
    echo "${RED}Failed — see ${LOG_FILE} for details${RESET}"
    exit 1
  fi
}

echo "==> Downloading scripts..."
for entry in "${STEPS[@]}"; do
  IFS='|' read -r script _ _ <<< "$entry"
  curl -fsSL "${BASE_URL}/${script}${BUST}" -o "${TMP_DIR}/${script}"
done
echo

# Ask for sudo once up front so it doesn't interrupt the spinner later
sudo -v

index=1
for entry in "${STEPS[@]}"; do
  IFS='|' read -r script title mode <<< "$entry"
  run_step "$index" "$script" "$title" "$mode"
  index=$((index + 1))
done

echo
echo "${GREEN}${BOLD}All done.${RESET}"
