#!/usr/bin/env bash

# Set a Wallpaper

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

if [ ! -d "$WALLPAPER_DIR" ]; then
	echo "Wallpaper directory does not exist: $WALLPAPER_DIR" >&2
	exit 1
fi

selected_wallpaper=$(find "$WALLPAPER_DIR" -type f | sort | dmenu -p "Select a wallpaper:")

if [ -z "$selected_wallpaper" ]; then
	echo "No wallpaper selected." >&2
	exit 1
fi

feh --bg-scale "$selected_wallpaper"
