#!/usr/bin/env bash

# Download Instagram saved videos or images

set -euo pipefail

if [ "${1:-}" ]; then
	username="$1"
else
	read -r -p "Instagram username: " username
fi

if [ -z "$username" ]; then
	echo "No username provided. Exiting."
	exit 1
fi

if compgen -G "\:saved/*.json.xz" > /dev/null; then
	echo "Removing old iterator files..."
	rm -f :saved/*.json.xz
fi

python ~/Projects/615_import_firefox_session.py

sleep 1s

instaloader --login "$username" :saved --no-metadata-json --no-video-thumbnail
