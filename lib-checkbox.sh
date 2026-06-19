#!/bin/bash
# checkbox-lib.sh — shared helpers for per-item checkbox output
# Sourced by 01/03/04 scripts. Not meant to be run directly.

GREEN=$'\033[32m'
RED=$'\033[31m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# checkbox <label> <command...>
# Runs the command, prints [x]/[ ] + label, logs full output to $LOG_FILE if set.
# On failure, also prints the last few lines of that item's own output inline.
checkbox() {
  local label="$1"; shift
  if [ -n "$LOG_FILE" ]; then
    echo "===== ${label} =====" >> "$LOG_FILE"
    if "$@" >> "$LOG_FILE" 2>&1; then
      printf "  ${GREEN}[x]${RESET} %s\n" "$label"
    else
      printf "  ${RED}[ ]${RESET} %s ${DIM}(failed)${RESET}\n" "$label"
      tail -n 5 "$LOG_FILE" | sed "s/^/      ${DIM}/;s/\$/${RESET}/"
    fi
  else
    if "$@" > /dev/null 2>&1; then
      printf "  ${GREEN}[x]${RESET} %s\n" "$label"
    else
      printf "  ${RED}[ ]${RESET} %s\n" "$label"
    fi
  fi
}
