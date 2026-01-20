#!/usr/bin/env bash

#
# Playing Videos based on duration or size with MPV
#

set -euo pipefail

usage() {
	echo "Usage: $0 [-d | -s] <directory>"
	echo "  -d  sort by duration (default)"
	echo "  -s  sort by file size"
	exit 1
}

mode=duration

while getopts ":ds" opt; do
	case $opt in
		d) mode=duration ;;
		s) mode=size ;;
		*) usage ;;
	esac
done
shift $((OPTIND - 1))

[[ $# -eq 1 ]] || usage

DIR=$1

shopt -s nullglob

exts=(mp4 mkv webm mov avi m4v ts)

mapfile -t files < <(
	for ext in "${exts[@]}"; do
		for f in "$DIR"/*."${ext}"; do
			case $mode in
				duration)
					if val=$(ffprobe -v error \
						-show_entries format=duration \
						-of default=noprint_wrappers=1:nokey=1 \
						"$f"); then
						echo "$val $f"
					fi
					;;
				size)
					if val=$(stat -c %s "$f" 2>/dev/null); then
						echo "$val $f"
					fi
					;;
			esac
		done
	done |
	sort -nr |
	awk '{for (i=2;i<=NF;i++) printf "%s%s", $i, (i==NF?RS:FS)}'
)

(( ${#files[@]} )) || {
	echo "No media files found"
	exit 0
}

mpv "${files[@]}"
