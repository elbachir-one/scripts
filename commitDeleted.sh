#!/usr/bin/env bash

# Commit only deleted files

message="${1:-Remove deleted files}"

deleted_files=$(git ls-files --deleted)

if [ -z "$deleted_files" ]; then
	echo "No deleted files to commit."
	exit 0
fi

echo "$deleted_files" | xargs git add
git commit -m "$message"
