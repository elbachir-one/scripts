#!/usr/bin/env bash

DIR="$HOME/Desktop/p2/"

mapfile -t files < <(for f in "$DIR"/*.{mp4,ts}; do
dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f")
echo "$dur $f"
done | sort -nr | awk '{for(i=2;i<=NF;i++){printf "%s%s",$i,(i==NF?RS:FS)}}')

mpv "${files[@]}"
