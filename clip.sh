#!/usr/bin/env bash

# Cut videos that are not downloaded

name=$(uuidgen | cut -d'-' -f1)

if [ $# -ne 3 ]; then
	echo "Usage: $0 <startTime> <endTime> <theUrl>"
	exit 1
fi

startTime="$1"
endTime="$2"
theUrl="$3"

output_dir=~/Images/Gif
mkdir -p "$output_dir"

ffmpeg -ss "$startTime" -to "$endTime" -i "$(yt-dlp -f bestvideo --get-url "$theUrl")" -f mp4 /tmp/out-1.mp4

ffmpeg -i /tmp/out-1.mp4 -vf 'setpts=2.0*PTS' -f mp4 /tmp/out-2.mp4

ffmpeg -i /tmp/out-2.mp4 -vf 'eq=brightness=0.6:saturation=2' -f gif "$output_dir/$name.gif"
