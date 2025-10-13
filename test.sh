#!/usr/bin/env bash
# YouTube search script using yt-dlp
# Usage: ./yt-search.sh "SEARCH TERM" COUNT [oldest|newest]

query="$1"
count="${2:-20}"        # default 20 results
order="${3:-newest}"    # default newest
outfile="${query// /_}_videos.txt"

if [[ -z "$query" ]]; then
	echo "Usage: $0 \"SEARCH TERM\" COUNT [oldest|newest]"
	exit 1
fi

# Pick sort order
if [[ "$order" == "oldest" ]]; then
	search="ytsearchdate${count}:${query}:asc"
else
	search="ytsearchdate${count}:${query}"
fi

# Fetch results
urls=$(yt-dlp "$search" --get-id \
	--match-filter "live_status=not_live" \
	| sed 's#^#https://www.youtube.com/watch?v=#')

# Combine with old results if file exists, remove duplicates, keep order
if [[ -f "$outfile" ]]; then
	printf "%s\n%s\n" "$urls" "$(cat "$outfile")" \
		| awk '!seen[$0]++' > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
		else
			echo "$urls" > "$outfile"
fi

echo "✅ Saved results to $outfile (no duplicates)"
