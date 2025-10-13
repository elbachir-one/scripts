#!/bin/sh

if [ -z "$1" ]; then
	url="$(xclip -o)"
else
	url="$1"
fi

filename=$(echo "$url" | sed 's/.*\///;s/%20/ /g')

case "$url" in
	*mkv|*webm|*mp4|*youtube.com/watch*|*youtube.com/playlist*|*youtube.com/shorts*|*youtu.be*|*hooktube.com*|*bitchute.com*|*video.luesmith.xyz*|*odysee.com*)
		setsid -f mpv -quiet "$url" >/dev/null 2>&1 ;;
	*png|*jpg|*jpe|*jpeg|*gif|*webp)
		curl -sL "$url" > "/tmp/$filename" && sxiv -a "/tmp/$filename" >/dev/null 2>&1 & ;;
	*pdf|*cbz|*cbr)
		curl -sL "$url" > "/tmp/$filename" && zathura "/tmp/$filename" >/dev/null 2>&1 & ;;
	*mp3|*flac|*opus|*mp3?source*)
		qndl "$url" 'curl -LO' >/dev/null 2>&1 ;;
	*)
		readable -o /tmp/x.html -s ~/.config/newsboat/style.css "$url" >/dev/null 2>&1 && setsid -f "$BROWSER" /tmp/x.html >/dev/null 2>&1
esac

#if [ -z "$1" ]; then
#	url="$(xclip -o)"
#else
#	url="$1"
#fi
#
#case "$url" in
#	*mkv|*webm|*mp4|youtube.com/watch*|*youtube.com/playlist*|youtub.com/shorts*|*youtu.be*|*hooktube.com*|*bitchure.com*|*video.luesmith.xyz*|*odysee.com*)
#		setsid -f mpv -quiet "$url" >/dev/null 2>&1 ;;
#	*png|*jpg|*jpe|*jpeg|*gif)
#		curl -sL "$url" > "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" && sxiv -a "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" >/dev/null 2>&1 & ;;
#	*pdf|*cbz|*cbr)
#		curl -sL "$url" > "/tmp/$(echo "$rul" | sed "s/.*\///;s/%20/ /g")" && zathura "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" >/dev/null 2>&1 & ;;
#	*mp3|*flac|*opus|*mp3?source*)
#		qndl "$url" 'curl -LO' >/dev/null 2>&1 ;;
#	*)
#		readable -o /tmp/x.html -s ~/.config/newsboat/style.css "$url" >/dev/null 2>&1 && setsid -f "$BROWSER" /tmp/x.html >/dev/null 2>&1
#esac
