#!/bin/bash

# Check for dependencies
if ! command -v yt-dlp &> /dev/null; then
	echo "Error: yt-dlp is not installed. Install it with 'pip install -U yt-dlp'."
	exit 1
fi

if ! command -v jq &> /dev/null; then
	echo "Error: jq is not installed. Install it with your package manager (e.g., 'sudo apt install jq')."
	exit 1
fi

# Check if a playlist URL is provided
if [ -z "$1" ]; then
	echo "Usage: $0 <playlist_url>"
	exit 1
fi

# Playlist URL from argument
PLAYLIST_URL="$1"

# Output file
OUTPUT_FILE="video_links.txt"

# Extract video links
echo "Extracting video links from playlist: $PLAYLIST_URL"
yt-dlp --flat-playlist -j "$PLAYLIST_URL" | jq -r '.url' > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
	echo "Video links saved to $OUTPUT_FILE."
else
	echo "Error occurred while extracting video links."
fi
