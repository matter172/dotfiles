#!/bin/bash
set -e

BASE_URL="https://github.com/matter172/dotfiles/raw/main"
BUST="?$(date +%s)"
TMP_DIR=$(mktemp -d)
LOG_DIR="${HOME}/.local/state/dotfiles-setup"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/setup-$(date +%Y%m%d-%H%M%S).log"

BOLD=$'\033[1m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'

FILES=(
  "lib-checkbox.sh"
  "01-rooted-remove-software.sh"
  "02-rooted-update-fedora.sh"
  "03-rooted-add-repo.sh"
  "04-rooted-add-software.sh"
  "05-non-rooted-add-software.sh"
  "06-non-rooted-update-dash.sh"
  "07-non-root-update-power.sh"
)

STEPS=(
  "01-rooted-remove-software.sh|Removing default GNOME software|sudo"
  "02-rooted-update-fedora.sh|Updating Fedora|sudo"
  "03-rooted-add-repo.sh|Adding repositories|sudo"
  "04-rooted-add-software.sh|Installing system packages|sudo"
  "05-non-rooted-add-software.sh|Installing user apps and Flatpaks|user"
  "06-non-rooted-update-dash.sh|Setting Dash favorites|user"
  "07-non-root-update-power.sh|Configuring power settings|user"
)

echo "${BOLD}dotfiles setup${RESET}"
echo "${DIM}Logging full output to ${LOG_FILE}${RESET}"
echo

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Enforce .sh-only filenames so a renamed/typo'd file fails loudly here
# instead of silently 404ing on download or being skipped by a glob.
for f in "${FILES[@]}"; do
  case "$f" in
    *.sh) ;;
    *)
      echo "${RED}Error: '${f}' in FILES does not end in .sh. Only .sh files are run.${RESET}"
      exit 1
      ;;
  esac
done
for entry in "${STEPS[@]}"; do
  IFS='|' read -r script _ _ <<< "$entry"
  case "$script" in
    *.sh) ;;
    *)
      echo "${RED}Error: '${script}' in STEPS does not end in .sh. Only .sh files are run.${RESET}"
      exit 1
      ;;
  esac
done

echo "==> Downloading scripts..."
for f in "${FILES[@]}"; do
  curl -fsSL "${BASE_URL}/${f}${BUST}" -o "${TMP_DIR}/${f}"
done
chmod +x "${TMP_DIR}"/*.sh
echo

# Create the log file as the current user first, then open it up so
# later sudo-run steps can append to it without permission errors.
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"

# Cache sudo credentials once up front
sudo -v

index=1
TOTAL=${#STEPS[@]}
for entry in "${STEPS[@]}"; do
  IFS='|' read -r script title mode <<< "$entry"
  echo "${BOLD}[${index}/${TOTAL}] ${title}${RESET}"
  if [ "$mode" = "sudo" ]; then
    sudo bash "${TMP_DIR}/${script}" "$LOG_FILE"
  else
    bash "${TMP_DIR}/${script}" "$LOG_FILE"
  fi
  echo
  index=$((index + 1))
done

echo "${GREEN}${BOLD}All done.${RESET}"
echo "${DIM}Full log: ${LOG_FILE}${RESET}"
