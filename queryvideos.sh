#!/usr/bin/env bash

# Usage: queryvideos <search_term> <limit>
# Example: queryvideos wrc 2000

set -euo pipefail

if [ $# -lt 2 ]; then
	echo "Usage: $0 <search_term> <limit>"
	exit 1
fi

search_term="$1"
limit="$2"
output_file="$HOME/Videos/${search_term}_videos.txt"

echo "Searching YouTube for \"$search_term\" (limit: $limit)..."
yt-dlp "ytsearch${limit}:${search_term}" --get-id \
	| sed 's#^#https://www.youtube.com/watch?v=#' \
	> "$output_file"

echo "✅ Saved results to: $output_file"
