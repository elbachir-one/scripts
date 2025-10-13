#!/usr/bin/env bash

# Set the colors for dwm using pywal

FOLDER="$HOME/wall"
WAL_FILE="$HOME/.cache/wal/colors-wal-dwm.h"
DWM_DIR="$HOME/suckless/dwm"

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

wal -i "$IMG"
feh --bg-fill "$IMG"

# Patch pywal dwm header
if [[ -f "$WAL_FILE" ]]; then
	sed -i '/SchemeUrg/d' "$WAL_FILE"
	sed -i '/^static const char urg_/d' "$WAL_FILE"
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
