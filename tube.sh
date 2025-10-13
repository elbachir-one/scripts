#!/usr/bin/env bash

# This is for downloading 1080p videos from youtube no 2k or 4k

if [ -z "$1" ]; then
	echo "Usage: $0 <URL or file_with_urls>"
	exit 1
fi

process_video() {
	local VIDEO_URL="$1"

	if echo "$VIDEO_URL" | grep -q "youtube.com\|youtu.be"; then
		yt-dlp -f "137+bestaudio[ext=m4a]/299+bestaudio[ext=m4a]/bestvideo+bestaudio" \
			-o "%(title)s.%(ext)s" --merge-output-format mp4 "$VIDEO_URL"
	else
		yt-dlp "$VIDEO_URL"
	fi
}

if [[ -f "$1" ]]; then
	while IFS= read -r VIDEO_URL; do
		[[ -n "$VIDEO_URL" ]] && process_video "$VIDEO_URL"
	done < "$1"
else
	process_video "$1"
fi
