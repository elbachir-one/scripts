#!/usr/bin/env bash

# This is a script that uses dmenu, wget, and yt-dlp to download media files and other links.

check_directory() {
	if [ ! -d "$1" ]; then
		echo "Directory $1 does not exist."
		return 1
	fi
	return 0
}

if ! check_directory ~/Videos/ || ! check_directory ~/Music/ || ! check_directory ~/Images/Thumbnails/ || ! check_directory ~/Downloads/; then
	echo "Creating necessary directories..."
	mkdir -p ~/Videos/
	mkdir -p ~/Music/
	mkdir -p ~/Images/Thumbnails/
	mkdir -p ~/Downloads/
fi

DOWNLOAD_OPTION=$(echo -e "Video\nAudio\nThumbnail\nOther Files" | dmenu -p "🌍")

case "$DOWNLOAD_OPTION" in
	"Video")
		DOWNLOAD_DIR=~/Videos
		DOWNLOAD_CMD="tube"
		;;
	"Audio")
		DOWNLOAD_DIR=~/Music
		DOWNLOAD_CMD="yt-dlp -f 140"
		;;
	"Thumbnail")
		DOWNLOAD_DIR=~/Images/Thumbnails
		DOWNLOAD_CMD="yt-dlp --skip-download --write-thumbnail"
		;;
	"Other Files")
		DOWNLOAD_DIR=~/Downloads
		DOWNLOAD_CMD="wget -c"
		;;
	*)
		echo "No valid option selected."
		exit 1
		;;
esac

VIDEO_URL=$(echo "" | dmenu -p "📡")
if [ -z "$VIDEO_URL" ]; then
	echo "No URL provided. Exiting."
	exit 1
fi

cd "$DOWNLOAD_DIR" || exit
$DOWNLOAD_CMD "$VIDEO_URL"
