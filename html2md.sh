#!/usr/bin/env bash

# Convert html file to markdown fils

if ! command -v pandoc &> /dev/null
then
	echo "Error: pandoc is not installed. Please install it and try again."
	exit 1
fi

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <input.html> [output.md]"
	exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE=${2:-output.md}

if pandoc "$INPUT_FILE" -f html -t markdown -o "$OUTPUT_FILE"; then
	echo "Conversion successful: $OUTPUT_FILE created."
else
	echo "Error: Conversion failed."
	exit 1
fi
