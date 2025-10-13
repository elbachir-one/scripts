#!/bin/bash

# Function to get the active network interface
get_active_interface() {
	# Check for active network interfaces
	for iface in $(ls /sys/class/net/); do
		# Skip loopback interface
		if [[ "$iface" == "lo" ]]; then
			continue
		fi

	# Check if the interface is up
	if ip link show "$iface" | grep -q "state UP"; then
		echo "$iface"
		return
	fi
done

  # Return empty if no interface is active
  echo ""
}

# Detect the active network interface
INTERFACE=$(get_active_interface)

# Notify if no active interface is found
if [[ -z "$INTERFACE" ]]; then
	notify-send "Bandwidth Monitor" "No active network interface detected."
	exit 1
fi

# Check if vnStat is installed
if ! command -v vnstat &> /dev/null; then
	notify-send "Bandwidth Monitor" "vnStat is not installed. Please install it and try again."
	exit 1
fi

# Get the current hour
CURRENT_HOUR=$(date +"%H")

# Fetch usage for the last 2 hours
USAGE=$(vnstat -i "$INTERFACE" -h | awk -v hour="$CURRENT_HOUR" '
/:/ {
sub(":", "", $1);
if ($1 == hour || $1 == (hour - 1 < 0 ? 23 : hour - 1)) {
	print $0;
}
}')

# Format the output for the notification
if [ -n "$USAGE" ]; then
	MESSAGE=$(echo "$USAGE" | awk '{printf "%s: %s received, %s sent\n", $1, $2, $5}')
else
	MESSAGE="No data available for the last two hours."
fi

# Send notification
notify-send "Bandwidth Usage (Last 2 Hours)" "Interface: $INTERFACE\n$MESSAGE"
