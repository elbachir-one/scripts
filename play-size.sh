#!/usr/bin/env bash

DIR="$HOME/Desktop/p2/"

mapfile -t files < <(
	for f in "$DIR"/*.{mp4,ts}; do
		size=$(stat -c %s "$f")
		echo "$size $f"
	done | sort -nr | awk '{for(i=2;i<=NF;i++) printf "%s%s",$i,(i==NF?RS:FS)}'
)

mpv "${files[@]}"
