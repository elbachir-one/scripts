#!/usr/bin/env bash

perc=$(cat /sys/class/power_supply/BAT1/capacity)

total=5

filled=$(( perc * total / 100 ))

bar=""
for ((i=0; i<total; i++)); do
	if [ $i -lt $filled ]; then
		bar+="█"
	else
		bar+="░"
	fi
done

if [ "$perc" -ge 50 ]; then color="\e[32m" # green
elif [ "$perc" -ge 20 ]; then color="\e[33m"
else color="\e[31m" # show red color (very low)
fi

echo -e "Battery: ${color}[$bar]\e[0m $perc%"
