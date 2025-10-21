#!/usr/bin/env bash

# This script alow you to search and open man pages using dmenu and open
# them in the terminal

man_pages=$(man -k . | awk '{print $1}' | grep -v '^[[:space:]]*$' | sort -u | sed 's/[,(].*//g')

man_page=$(echo "$man_pages" | dmenu -p "Find a man page:")

if [ -n "$man_page" ]; then
	alacritty -e man "$man_page" &
fi
