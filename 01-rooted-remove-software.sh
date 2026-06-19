#!/bin/bash
# Removes default GNOME bloat, one package at a time, with checkbox output.

LOG_FILE="${1:-/dev/null}"
source "$(dirname "${BASH_SOURCE[0]}")/lib-checkbox.sh" || { echo "lib-checkbox.sh not found"; exit 1; }

PACKAGES=(
  "libreoffice-core.x86_64"
  "gnome-tour.x86_64"
  "firefox.x86_64"
  "gnome-calendar.x86_64"
  "gnome-boxes.x86_64"
  "gnome-contacts.x86_64"
  "mediawriter.x86_64"
  "gnome-weather.noarch"
  "gnome-maps.x86_64"
  "simple-scan.x86_64"
  "yelp.x86_64"
  "gnome-connections.x86_64"
  "malcontent-control.x86_64"
  "gnome-abrt.x86_64"
  "gnome-font-viewer.x86_64"
  "papers.x86_64"
  "gnome-calculator.x86_64"
  "gnome-clocks.x86_64"
  "showtime.noarch"
  "gnome-characters.x86_64"
  "loupe.x86_64"
  "decibels.noarch"
  "gnome-system-monitor.x86_64"
)

for pkg in "${PACKAGES[@]}"; do
  checkbox "Remove ${pkg}" dnf remove -y "$pkg"
done
