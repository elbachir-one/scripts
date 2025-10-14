#!/usr/bin/env bash

# Monitors your recent network bandwidth usage and shows it as a desktop notification

get_active_interface() {
	ip -o link show | awk -F': ' '$2 != "lo" && /state UP/ {print $2; exit}'
}

INTERFACE=$(get_active_interface)

if [[ -z "$INTERFACE" ]]; then
	notify-send "Bandwidth Monitor" "No active network interface detected."
	exit 1
fi

if ! command -v vnstat &> /dev/null; then
	notify-send "Bandwidth Monitor" "vnStat is not installed. Please install it and try again."
	exit 1
fi

CURRENT_HOUR=$(date +"%H")

USAGE=$(vnstat -i "$INTERFACE" -h | awk -v hour="$CURRENT_HOUR" '
/:/ {
	sub(":", "", $1)
	if ($1 == hour || $1 == (hour - 1 < 0 ? 23 : hour - 1))
		print $0
}')

if [ -n "$USAGE" ]; then
	MESSAGE=$(echo "$USAGE" | awk '{printf "%s: %s received, %s sent\n", $1, $2, $5}')
else
	MESSAGE="No data available for the last two hours."
fi

notify-send "Bandwidth Usage (Last 2 Hours)" "Interface: $INTERFACE\n$MESSAGE"
