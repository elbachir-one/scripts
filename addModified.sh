#!/usr/bin/env bash

# Add modified files

modified_files=$(git ls-files --modified)

if [ -z "$modified_files" ]; then
	echo "No modified to add."
	exit 0
fi

echo "$modified_files" | xargs git add
