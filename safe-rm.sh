#!/usr/bin/env bash

# To remove things safely

for arg in "$@"; do
	if [[ "$arg" == "*" || "$arg" == *\** || "$arg" == *\?* ]]; then
		echo "Wildcard detected: $arg"
		read -r -p "Are you sure you want to delete all matching files? [y/N]: " confirm
		if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
			echo "Aborted."
			exit 1
		fi
		break
	fi
done

rm "$@"
