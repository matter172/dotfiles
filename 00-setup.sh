#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/matter172/dotfiles/main"

sudo bash <(curl -fsSL "$BASE_URL/01-rooted-remove-software.sh")
sudo bash <(curl -fsSL "$BASE_URL/02-rooted-update-fedora.sh")
sudo bash <(curl -fsSL "$BASE_URL/03-rooted-add-software.sh")
bash <(curl -fsSL "$BASE_URL/04-non-rooted-add-software.sh")
