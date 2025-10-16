#!/bin/sh

VERSION="0.0.2"
VIEWER=${VIEWER:-sxiv}
WALLDIR="$HOME/Images/Wallhaven/"
CACHEDIR="$HOME/.cache/wallhaven"
SXIV_OPTS="-tfpo -z 200"
MAX_PAGES=4
SORTING=relevance
QUALITY=large
ATLEAST=1920x1080
API_KEY="Lz5WsR22C0xz6sGlXckaNN8AKKJSvdx0"

sh_menu () {
	: | dmenu -p "Search Wallhaven:"
}

dep_ck () {
	for pr; do
		command -v $pr >/dev/null 2>&1 || exit 1
	done
}
dep_ck "$VIEWER" "curl" "jq"

clean_up () {
	rm -rf "$DATAFILE" "$CACHEDIR"
}

show_notification () {
	notify-send "Wallhaven" "$1"
}

trap "exit" INT TERM
trap "clean_up" EXIT

DATAFILE="/tmp/wald.$$"

get_results () {
	show_notification "Searching for $1..."
	for purity in "sfw" "nsfw"; do
		for page_no in $(seq $MAX_PAGES); do
			api_url="https://wallhaven.cc/api/v1/search?q=$1&page=$page_no&atleast=$ATLEAST&sorting=$SORTING&sfw=$purity&apikey=$API_KEY"
			json=$(curl -s "$api_url")
			printf "%s\n" "$json" >> "$DATAFILE"
		done
	done
	wait
}

get_results "${*:-$(sh_menu)}"
[ -s "$DATAFILE" ] || {
	show_notification "No images found."
	exit 1
}

THUMBNAILS=$(jq -r '.data[]?|.thumbs.'"$QUALITY" < "$DATAFILE")
[ -z "$THUMBNAILS" ] && {
	show_notification "No thumbnails found."
	exit 1
}

mkdir -p "$CACHEDIR"
for url in $THUMBNAILS; do
	printf "url = %s\n" "$url"
	printf "output = %s\n" "$CACHEDIR/${url##*/}"
done | curl -Z -K -

IMAGE_IDS="$($VIEWER $SXIV_OPTS "$CACHEDIR")"
[ -z "$IMAGE_IDS" ] && {
	show_notification "No images selected."
	exit 1
}

cd "$WALLDIR"
for ids in $IMAGE_IDS; do
	ids="${ids##*/}"
	ids="${ids%.*}"
	url=$(jq -r '.data[]?|select( .id == "'$ids'" )|.path' < "$DATAFILE")
	printf "url = %s\n" "$url"
	printf -- "-O\n"
done | curl -K -

show_notification "Wallpapers downloaded in $WALLDIR"
$VIEWER $(ls -c)
