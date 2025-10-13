#!/bin/bash

geometry=$(slop -f "%x,%y,%w,%h")

if [ -z "$geometry" ]; then
	notify-send "Screenshot" "Selection canceled."
	exit 1
fi

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')

filename="$HOME/Pictures/screenshot_$timestamp.png"

scrot -a "$geometry" -q 100 "$filename"

if [ -f "$filename" ]; then
	notify-send "Screenshot" "Screenshot saved to $filename."
else
	notify-send "Screenshot" "Failed to save the screenshot."
fi
