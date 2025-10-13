#!/usr/bin/env bash

MOUNTPOINT="$HOME/Phone"

# Create mountpoint if it doesn't exist
[ -d "$MOUNTPOINT" ] || mkdir -p "$MOUNTPOINT"

# Check if already mounted
if mount | grep -q "on $MOUNTPOINT type fuse.simple-mtpfs"; then
	CHOICE=$(printf "Yes\nNo" | dmenu -p "Unmount device from $MOUNTPOINT?")
	if [ "$CHOICE" = "Yes" ]; then
		fusermount -u "$MOUNTPOINT" && notify-send "Phone unmounted"
	fi
	exit 0
fi

DEVICES=$(simple-mtpfs -l 2>/dev/null)

if [ -z "$DEVICES" ]; then
	notify-send "MTP Mount" "No devices found"
	exit 1
fi

# Show devices in dmenu
CHOICE=$(echo "$DEVICES" | dmenu -p "Select Phone:")

# Extract device index (the first number before ':')
INDEX=$(echo "$CHOICE" | awk -F: '{print $1}')

# If user canceled
[ -z "$INDEX" ] && exit 1

if simple-mtpfs --device "$INDEX" "$MOUNTPOINT"; then
	notify-send "Mounted at $MOUNTPOINT"
else
	notify-send "Failed to mount device"
	exit 1
fi
