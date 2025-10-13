#!/usr/bin/env bash

# This script record the selected area using slop and ffmpeg

read -r X Y WIDTH HEIGHT < <(slop -f "%x %y %w %h")

# Checking if slop returned valid values
if [[ -z "$X" || -z "$Y" || -z "$WIDTH" || -z "$HEIGHT" ]]; then
	exit 1
fi

# Output with file name plus the date/time
OUTPUT="screenrecord_$(date +'%Y-%m-%d_%H-%M-%S').mp4"

ffmpeg -f x11grab -video_size "${WIDTH}x${HEIGHT}" -i ":0.0+${X},${Y}" \
	-c:v libx264 -preset ultrafast -crf 18 "$OUTPUT"
