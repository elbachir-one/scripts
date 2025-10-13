#!/usr/bin/env bash

FOLDER="$HOME/wall"                     # Wallpapers path
WAL_FILE="$HOME/.cache/wal/colors-wal-dwm.h"  # Colors path
DWM_DIR="$HOME/suckless/dwm"           # Path to dwm directory

# Build menu with wallpapers
CHOICE=$(printf "Random\n%s" "$(ls -1 "$FOLDER")" | dmenu -l 15 -i -p "Wallpaper: ")

case "$CHOICE" in
	Random)
		IMG=$(find "$FOLDER" -type f | shuf -n 1)
		;;
	*.*)
		IMG="$FOLDER/$CHOICE"
		;;
	*)
		exit 0
		;;
esac

# Apply wallpaper with pywal and feh
wal -i "$IMG"
feh --bg-fill "$IMG"

# Patch pywal dwm header
if [[ -f "$WAL_FILE" ]]; then
	# Remove SchemeUrg entries
	sed -i '/SchemeUrg/d' "$WAL_FILE"
	# Remove urg_* declarations
	sed -i '/^static const char urg_/d' "$WAL_FILE"
	# Remove 'const' from all static char declarations
	sed -i 's/static const char/static char/g' "$WAL_FILE"
	echo "Patched $WAL_FILE for dwm"
fi

# Rebuild dwm
if [[ -d "$DWM_DIR" ]]; then
	cd "$DWM_DIR" || exit
	make clean && make && sudo make install
	echo "dwm rebuilt"
fi

# Restart dwm safely using SIGHUP (works with your current patch)
kill -HUP $(pgrep dwm)
