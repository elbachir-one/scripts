#!/usr/bin/env bash

# Download images from reddit
# How to use it ./reddit.sh subreddit 10

SUB="$1"
NUM="$2"

DEST="$HOME/Pictures/reddit/$SUB"
mkdir -p "$DEST"

curl -s -A "Mozilla/5.0" "https://www.reddit.com/r/$SUB/new.json?limit=$NUM&raw_json=1&over18=1" \
	| jq -r '.data.children[].data.url_overridden_by_dest' \
	| grep -E '\.jpg$|\.png$|\.jpeg$|\.webp$' \
	| while read -r IMG; do
	wget -nc -P "$DEST" "$IMG"
done
