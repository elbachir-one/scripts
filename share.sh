#!/bin/bash

# Share files

FILE_NAME=$1
DESTINATION="0x0.st"

if [ -z "$FILE_NAME" ]; then
	echo "Usage: $0 <file-to-upload>"
	exit 1
fi

upload_file() {
	curl -F "file=@$FILE_NAME" $DESTINATION
}

upload_file
