#!/bin/bash

# Define the DuckDuckGo URL
ddg_url="https://duckduckgo.com/?q="

# Prompt the user to enter a search query
search_query=$(echo "" | dmenu -p "Search DuckDuckGo:")

# If the user cancels, exit the script
if [[ -z $search_query ]]; then
    exit 1
fi

# Construct the search URL and open it in the default browser
search_url="${ddg_url}$(echo $search_query | tr ' ' '+')"
xdg-open "$search_url"
