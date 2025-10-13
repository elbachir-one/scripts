#!/usr/bin/env bash

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASEDIR"

for file in .bashrc .vimrc; do
	TARGET="$HOME/$file"
	SOURCE="$PWD/$file"
	if [ -L "$TARGET" ] || [ -e "$TARGET" ]; then
		echo "$TARGET exists, skipping."
	else
		ln -s "$SOURCE" "$TARGET"
		echo "Linked $SOURCE -> $TARGET"
	fi
done
