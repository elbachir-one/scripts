#!/usr/bin/env bash

# Open links from newsboat

BROWSER="qutebrowser"

if [ -z "$1" ]; then
	url="$(xclip -o)"
else
	url="$1"
fi

if [ -f "$url" ]; then
	case "$url" in
		*.pdf|*.cbz|*.cbr)
			zathura "$url" & ;;
		*.png|*.jpg|*.jpe|*.jpeg|*.gif|*.webp)
			sxiv -a "$url" & ;;
		*)
			"$BROWSER" "$url" &
			;;
	esac
	exit
fi

filename=$(basename "$(echo "$url" | sed 's/[?#].*//;s/%20/ /g')")
[ -z "$filename" ] && filename="downloaded_file"
tmpfile="/tmp/$filename"

case "$url" in
	*.mkv|*.webm|*.mp4|*youtube.com/watch*|*youtube.com/playlist*|*youtube.com/shorts*|*youtu.be*|*hooktube.com*|*bitchute.com*|*video.luesmith.xyz*|*odysee.com*)
		setsid -f mpv -quiet "$url" >/dev/null 2>&1 ;;

	*.png|*.jpg|*.jpe|*.jpeg|*.gif|*.webp)
		curl -sL "$url" -o "$tmpfile" && [ -s "$tmpfile" ] && sxiv -a "$tmpfile" & ;;

	*.pdf|*.cbz|*.cbr)
		curl -sL "$url" -o "$tmpfile" && [ -s "$tmpfile" ] && zathura "$tmpfile" & ;;

	*.mp3|*.flac|*.opus|*.mp3?source*)
		curl -LO "$url" >/dev/null 2>&1 ;;

	*)
		setsid -f "$BROWSER" "$url" >/dev/null 2>&1
		;;
esac
