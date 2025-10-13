#!/bin/bash

# Getting a name for the gif
name=$(uuidgen | cut -d'-' -f1)

# Ensure that startTime, endTime, and theUrl are passed as arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 <startTime> <endTime> <theUrl>"
    exit 1
fi

# Assign arguments to variables
startTime="$1"
endTime="$2"
theUrl="$3"

# Create the output directory if it doesn't exist
output_dir=~/Images/Gif
mkdir -p "$output_dir"

# Download and trim the video
ffmpeg -ss "$startTime" -to "$endTime" -i "$(yt-dlp -f bestvideo --get-url "$theUrl")" -f mp4 /tmp/out-1.mp4

# Slow down the video
ffmpeg -i /tmp/out-1.mp4 -vf 'setpts=2.0*PTS' -f mp4 /tmp/out-2.mp4

# Apply brightness and saturation filter, then convert to GIF
ffmpeg -i /tmp/out-2.mp4 -vf 'eq=brightness=0.6:saturation=2' -f gif "$output_dir/$name.gif"
