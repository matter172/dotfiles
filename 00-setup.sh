#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/matter172/dotfiles/main"
BUST="?$(date +%s)"

curl -fsSL "${BASE_URL}/01-rooted-remove-software.sh${BUST}" -o /tmp/01.sh
curl -fsSL "${BASE_URL}/02-rooted-update-fedora.sh${BUST}"   -o /tmp/02.sh
curl -fsSL "${BASE_URL}/03-rooted-add-software.sh${BUST}"    -o /tmp/03.sh
curl -fsSL "${BASE_URL}/04-non-rooted-add-software.sh${BUST}" -o /tmp/04.sh
