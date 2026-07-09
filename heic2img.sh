#!/usr/bin/env bash

# HEIC to JPG/PNG/JPEG Converter using macOS built-in sips
#
# Usage:
#   ./heic2img.sh jpg
#   ./heic2img.sh png
#   ./heic2img.sh jpg image.HEIC
#   ./heic2img.sh png image.heic

# Note: If you're using Linux, make sure you have ImageMagick and libheif installed.

set -euo pipefail

shopt -s nullglob

format="${1:-}"

case "$format" in
	jpg)  format="jpeg"; ext="jpg" ;;
	jpeg) format="jpeg"; ext="jpg" ;;
	png)  format="png";  ext="png" ;;
	*)
		echo "Usage: $0 <jpg|png> [file.heic]"
		exit 1
		;;
esac

converted=0

convert_file() {
	local file="$1"
	local output="${file%.*}.${ext}"

	if sips -s format "$format" "./$file" --out "$output" >/dev/null 2>&1; then
		echo "✓ Converted: $file -> $output"
		((converted++))
	else
		echo "✗ Failed: $file"
	fi
}

if [[ $# -ge 2 ]]; then
	if [[ -f "$2" ]]; then
		convert_file "$2"
	else
		echo "Error: '$2' does not exist."
		exit 1
	fi
else
	for file in *.HEIC *.heic; do
		convert_file "$file"
	done
fi

if (( converted == 0 )); then
	echo "No HEIC files were converted."
else
	echo "Done! Converted $converted file(s)."
fi
