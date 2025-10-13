#!/bin/sh

INPUT=$(find . -type f -name "*.md" | head -n 1)

if [ -z "$INPUT" ]; then
	echo "No .md file found."
	exit 1
fi

OUTPUT="${INPUT%.md}.pdf"

pandoc "$INPUT" -t beamer -o "$OUTPUT"

if [ $? -eq 0 ]; then
	echo "Conversion successful: $OUTPUT"
else
	echo "Conversion failed"
	exit 1
fi
