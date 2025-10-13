#!/bin/sh

# Bookmark manager script
# Stores URLs in ~/.bookmarks/bookmark and titles in ~/.bookmarks/bookmark_titles

BOOKMARKS="$HOME/.bookmarks"
BOOKMARK_FILE="$BOOKMARKS/bookmark"
TITLE_FILE="$BOOKMARKS/bookmark_titles"

mkdir -p "$BOOKMARKS"
touch "$BOOKMARK_FILE" "$TITLE_FILE"

# Function to add a bookmark
add_bookmark() {
	bookmark=$(xclip -o -selection clipboard)

	if ! echo "$bookmark" | grep -qE '^https?://'; then
		notify-send "Invalid URL in clipboard"
		exit 1
	fi

	title=$(wget -qO- "$bookmark" 2>/dev/null | grep -iPo '(?<=<title>).*?(?=</title>)' | head -n 1)
	[ -z "$title" ] && notify-send "Title not found for URL" && exit 1

	if grep -Fxq "$title" "$TITLE_FILE"; then
		notify-send "'$title' already in bookmarks"
	else
		request=$(printf "Yes\nNo" | rofi -dmenu -p "Add $bookmark to bookmarks?") || exit
		if [ "$request" = "Yes" ]; then
			echo "$bookmark" >> "$BOOKMARK_FILE"
			echo "$title" >> "$TITLE_FILE"
			notify-send "$title added to bookmarks"
		fi
	fi
}

# Function to remove a bookmark
remove_bookmark() {
	selected=$(cat "$TITLE_FILE" | rofi -dmenu -p "Remove bookmark" -i -l 30)
	[ -z "$selected" ] && exit

	idx=$(grep -nxF "$selected" "$TITLE_FILE" | cut -d: -f1)
	if [ -n "$idx" ]; then
		sed -i "${idx}d" "$TITLE_FILE"
		sed -i "${idx}d" "$BOOKMARK_FILE"
		notify-send "'$selected' bookmark removed"
	else
		notify-send "Bookmark not found"
	fi
}

# Prompt user for action
action=$(printf "Add\nRemove" | rofi -dmenu -p "Bookmark Manager")
case "$action" in
	Add) add_bookmark ;;
	Remove) remove_bookmark ;;
	*) exit ;;
esac

## Bookmark manager script
#
#BOOKMARKS="$HOME/.bookmarks"
#BOOKMARK_FILE="$BOOKMARKS/bookmark"
#TITLE_FILE="$BOOKMARKS/bookmark_titles"
#
#mkdir -p "$BOOKMARKS"
#touch "$BOOKMARK_FILE" "$TITLE_FILE"
#
## Function to add a bookmark
#add_bookmark() {
#	bookmark=$(xclip -o -selection clipboard)
#
#	if ! echo "$bookmark" | grep -qE '^https?://'; then
#		notify-send "Invalid URL in clipboard"
#		exit 1
#	fi
#
#	title=$(wget -qO- "$bookmark" 2>/dev/null | grep -iPo '(?<=<title>).*?(?=</title>)' | head -n 1)
#	[ -z "$title" ] && notify-send "Title not found for URL" && exit 1
#
#	if grep -Fxq "$title" "$TITLE_FILE"; then
#		notify-send "'$title' already in bookmarks"
#	else
#		request=$(printf "Yes\nNo" | dmenu -i -p "Add $bookmark to bookmarks?") || exit
#		if [ "$request" = "Yes" ]; then
#			echo "$bookmark" >> "$BOOKMARK_FILE"
#			echo "$title" >> "$TITLE_FILE"
#			notify-send "$title added to bookmarks"
#		fi
#	fi
#}
#
## Function to remove a bookmark
#remove_bookmark() {
#	selected=$(cat "$TITLE_FILE" | dmenu -p "Remove bookmark" -i -l 30)
#	[ -z "$selected" ] && exit
#
#	idx=$(grep -nxF "$selected" "$TITLE_FILE" | cut -d: -f1)
#	if [ -n "$idx" ]; then
#		sed -i "${idx}d" "$TITLE_FILE"
#		sed -i "${idx}d" "$BOOKMARK_FILE"
#		notify-send "'$selected' bookmark removed"
#	else
#		notify-send "Bookmark not found"
#	fi
#}
#
## Prompt user for action
#action=$(printf "Add\nRemove" | dmenu -i -p "Bookmark Manager")
#case "$action" in
#	Add) add_bookmark ;;
#	Remove) remove_bookmark ;;
#	*) exit ;;
#esac

## Old Bookmark script
#
#bookmark=$(xclip -o -selection clipboard)
#title=$(wget -qO- $bookmark | gawk -V IGNORECASE=1 -V RS='</title' 'RT{gsub(/.*<title[^>]*>/,"");print;exit}')
#
#[ -z "$title" ] && notify-send "url not found" && exit
#
#if grep -qx "$title" $BOOKMARKS/bookmark_titles; then
#	notify-send "'$title' already in bookmarks"
#else
#	request=$(printf "Yes\\nNo" | dmenu -i -p "Add $bookmark to bookmarks?") || exit
#	[ "$request" = "Yes" ] && echo "$bookmark" >> $BOOKMARKS/bookmark && echo "$title" >> $BOOKMARKS/bookmark_titles && notify-send "$title Added to bookmarks"
#fi

## Old Unbookmark script

#bookmark=$(cat $BOOKMARKS/bookmark_titles | dmenu -p "Remove bookmark" -i -l 30)
#[[ -n $bookmark ]] || exit
#idx=$(grep -nx "$bookmark" $BOOKMARKS/bookmark_titles | cut -f1 -d:)
#sed -i "$idx{d}" $BOOKMARKS/bookmarks && sed -i "$idx{d}" $BOOKMARKS/bookmark_titles && notify-send "$bookmark Bookmark Removed"
