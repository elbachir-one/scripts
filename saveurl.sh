#!/usr/bin/env bash

#
# This script automatically cleans and saves URLs copied to the clipboard into a file.
#

FILE="$HOME/Downloads/list.txt"
LAST=""

while true; do
	CLIP=$(xclip -o -selection clipboard 2>/dev/null)

	CLEANED=$(echo "$CLIP" | grep -Eo 'https?://[^ ]+' | sed 's/[#&?].*//')

	if [[ -n "$CLEANED" && "$CLEANED" != "$LAST" ]]; then
		echo "$CLEANED" >> "$FILE"
		notify-send "URL Saved" "$CLEANED"
		LAST="$CLEANED"
	fi

	sleep 1
done
