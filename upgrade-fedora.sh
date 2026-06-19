#!/bin/bash

# 1. Update everything and refresh repos
sudo dnf upgrade --refresh -y

# 2. Download the next latest stable version
sudo dnf system-upgrade download --releasever=$(curl -s https://fedoraproject.org/releases.json | jq -r '[.[].version | select(test("^\\d+$"))] | map(tonumber) | max')

# 3. Trigger the reboot and install (Run this after the download finishes)
sudo dnf system-upgrade reboot
