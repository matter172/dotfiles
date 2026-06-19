#!/bin/bash

# 1. Update everything and refresh repos
sudo dnf upgrade --refresh -y

# 2. Download the next version up
sudo dnf system-upgrade download --releasever=$(( $(rpm -E %fedora) + 1 )) -y

# 3. Trigger the reboot and install (Run this after the download finishes)
sudo dnf system-upgrade reboot
