#!/bin/bash

GREEN=$'\033[32m'
RED=$'\033[31m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# checkbox <label> <command...>
# Runs the command, prints [x]/[ ] + label, logs full output to $LOG_FILE if set.
checkbox() {
  local label="$1"; shift
  local out
  if [ -n "$LOG_FILE" ]; then
    if "$@" >> "$LOG_FILE" 2>&1; then
      printf "  ${GREEN}[x]${RESET} %s\n" "$label"
    else
      printf "  ${RED}[ ]${RESET} %s ${DIM}(failed — see log)${RESET}\n" "$label"
    fi
  else
    if "$@" > /dev/null 2>&1; then
      printf "  ${GREEN}[x]${RESET} %s\n" "$label"
    else
      printf "  ${RED}[ ]${RESET} %s\n" "$label"
    fi
  fi
}
