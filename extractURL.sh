#!/usr/bin/env bash

# Extract URLs from playlists

if [ -z "$1" ]; then
	echo "Usage: $0 <playlist_url>"
	exit 1
fi

PLAYLIST_URL="$1"
OUTPUT_FILE="$HOME/Downloads/links.txt"

echo "Extracting video links from playlist: $PLAYLIST_URL"

if yt-dlp --flat-playlist -j "$PLAYLIST_URL" | jq -r '.url' >"$OUTPUT_FILE"; then
	echo "Video links saved to $OUTPUT_FILE."
else
	echo "Error occurred while extracting video links."
	exit 1
fi
