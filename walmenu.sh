#!/usr/bin/env bash

# Lets you choose a wallpaper with nsxiv or dmenu, then applies it with pywal

FOLDER="$HOME/Wallpapers"
SCRIPT="$HOME/scripts/pywal16"

# --- Dependency checks ---
missing=()

for cmd in wal find; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		missing+=("$cmd")
	fi
done

if ! command -v nsxiv >/dev/null 2>&1 && ! command -v dmenu >/dev/null 2>&1; then
	missing+=("nsxiv or dmenu")
fi

if [ "${#missing[@]}" -ne 0 ]; then
	printf "Error: missing required command(s): %s\n" "${missing[*]}" >&2
	exit 1
fi

# --- Wallpaper selection menu ---
menu() {
	if command -v nsxiv >/dev/null; then
		CHOICE=$(find "$FOLDER" -type f | nsxiv -otb -)
	else
		CHOICE=$(echo -e "Random\n$(command ls -v "$FOLDER")" | dmenu -c -l 15 -i -p "Wallpaper: ")
	fi

	[ -z "$CHOICE" ] && exit 0

	case $CHOICE in
		Random) wal -i "$FOLDER" -o "$SCRIPT" ;;
		*.*) wal -i "$CHOICE" -o "$SCRIPT" ;;
		*) exit 0 ;;
	esac
}

# --- Main logic ---
case "$#" in
	0) menu ;;
	1) wal -i "$1" -o "$SCRIPT" ;;
	2) wal -i "$1" --theme "$2" -o "$SCRIPT" ;;
	*) exit 0 ;;
esac
