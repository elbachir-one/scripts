#!/bin/bash
cd ~/Videos/
DOWNLOAD_CMD="yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4"

# Get the video URL using dmenu
VIDEO_URL=$(echo "" | dmenu -p "Enter video URL:")

# Download the video using youtube-dl
eval "$DOWNLOAD_CMD $VIDEO_URL"
