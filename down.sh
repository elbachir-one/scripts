#!/bin/bash
# Get the download option using dmenu
DOWNLOAD_OPTION=$(echo -e "Video\nAudio\nVideo_Thumbnail" | dmenu -p "Download Video or Audio or Thumbnails:")

if [ "$DOWNLOAD_OPTION" == "Video" ]; then
    DOWNLOAD_CMD="cd ~/Videos/ && yt-dlp -f \"bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best\" --merge-output-format mp4"
elif [ "$DOWNLOAD_OPTION" == "Audio" ]; then
    DOWNLOAD_CMD="cd ~/Music/ && yt-dlp -f 140"
elif [ "$DOWNLOAD_OPTION" == "Video_Thumbnail" ]; then
    DOWNLOAD_CMD="cd ~/Images/Thumbnails/ && yt-dlp --skip-download --write-thumbnail"
fi

# Get the video URL using dmenu
VIDEO_URL=$(echo "" | dmenu -p "Enter URL:")

# Download the video using youtube-dl
eval "$DOWNLOAD_CMD $VIDEO_URL"
