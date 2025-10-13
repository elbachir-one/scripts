#!/bin/bash

output_file="screen_record_$(date +%Y-%m-%d_%H-%M-%S).mkv"

geometry=$(slop -f "%x %y %w %h")
read -r x y width height <<< "$geometry"

framerate=29

audio_device="default"

ffmpeg -f x11grab -s "${width}x${height}" -r "$framerate" -i "$DISPLAY+$x,$y" -f pulse -i "$audio_device" -c:v libx264 -preset ultrafast -crf 18 -c:a aac "$output_file"
