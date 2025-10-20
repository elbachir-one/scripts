#!/usr/bin/env bash

# Search and open man pages with dmenu and zathura

man_pages=$(man -k . | awk '{print $1}' | grep -v '^[[:space:]]*$' | sort -u | sed 's/[,(].*//g')

man_page=$(echo "$man_pages" | dmenu -p "Find a man page:")

if [ -n "$man_page" ]; then
	temp_man_file=$(mktemp /tmp/manpage.XXXXXX.pdf)

	if man -Tpdf "$man_page" > "$temp_man_file"; then

		zathura "$temp_man_file" &

		wait $!

		rm -f "$temp_man_file"
	else
		rm -f "$temp_man_file"
	fi
fi
