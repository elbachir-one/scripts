#!/usr/bin/env bash

# Upload files to 0x0.st

if [ -z "$1" ]; then
	echo "Usage: up <file-path>"
	exit 1
fi

curl -s -F "file=@$1" https://0x0.st
