#!/bin/bash

export DISPLAY=:0

# Ask the user what to capture
choice=$(printf "fullscreen\narea\nwindow" | dmenu -p "Take screenshot:")

# Cancel if no choice was made
[ -z "$choice" ] && exit 0

# Prepare file path
mkdir -p "${HOME}/Pictures/Screenshots"
current="${HOME}/Pictures/Screenshots/$(date +%H-%M-%S-%d-%m-%Y).png"

# Take the screenshot based on choice
case "$choice" in
	fullscreen)
		import -window root "$current" ;;
	area)
		import "$current" ;;
	window)
		import "$(xwininfo | grep 'Window id' | awk '{print $4}')" "$current" ;;
	*)
		notify-send "Screenshot" "Unknown option: $choice"
		exit 1
		;;
esac

# Notify the user
if [ $? -eq 0 ]; then
	notify-send "Screenshot saved" "$current"
else
	notify-send "Screenshot failed"
fi
