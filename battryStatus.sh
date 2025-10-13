#!/usr/bin/env bash

# Print the battery status and display the percentage next to an icon

battery="/sys/class/power_supply/BAT1/capacity"

if [[ ! -f "$battery" ]]; then
	echo " N/A"
	exit 1
fi

perc=$(<"$battery")

if   (( perc >= 90 )); then icon=""
elif (( perc >= 70 )); then icon=""
elif (( perc >= 50 )); then icon=""
elif (( perc >= 20 )); then icon=""
else icon=""
fi

echo "$icon ${perc}%"
