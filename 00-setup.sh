#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/matter172/dotfiles/refs/heads/main"

curl -fsSL "$BASE_URL/01-rooted-remove-software.sh" -o /tmp/01.sh
curl -fsSL "$BASE_URL/02-rooted-update-fedora.sh"   -o /tmp/02.sh
curl -fsSL "$BASE_URL/03-rooted-add-software.sh"    -o /tmp/03.sh
curl -fsSL "$BASE_URL/04-non-rooted-add-software.sh" -o /tmp/04.sh

sudo bash /tmp/01.sh
sudo bash /tmp/02.sh
sudo bash /tmp/03.sh
bash /tmp/04.sh

rm /tmp/01.sh /tmp/02.sh /tmp/03.sh /tmp/04.sh
