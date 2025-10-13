#!/usr/bin/env bash

# Converts a video to a high-quality GIF with optimized palette and scaling
# Usage: ./video2gif.sh input_video.mp4

set -e

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <input_video>"
	exit 1
fi

input="$1"
base="${input%.*}"
output="${base}.gif"

# --- Convert video to GIF ---
ffmpeg -y -i "$input" \
	-vf "fps=15,scale=480:-1:flags=lanczos,split[s0][s1]; \
	[s0]palettegen=max_colors=128:stats_mode=diff[p]; \
	[s1][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
	"$output"

echo "✅ GIF saved as: $output"
