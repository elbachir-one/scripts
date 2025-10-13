#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 input_video"
	exit 1
fi

input="$1"
basename=$(basename "$input" | sed 's/\.[^.]*$//')
output="${basename}.gif"

ffmpeg -y -i "$input" \
	-vf "fps=15,scale=320:-1:flags=lanczos,split[s0][s1]; \
	[s0]palettegen=max_colors=128:stats_mode=diff[p]; \
	[s1][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
	"$output"
