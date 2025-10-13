#!/usr/bin/env bash


# This script provides a dmenu-driven interface for mounting and unmounting
# removable drives or partitions. It uses lsblk to detect available devices
# and presents them in a user-friendly menu. Notifications are sent through
# dunst (if running).

# Ask user whether to mount or unmount
action=$(printf "Mount\nUnmount" | dmenu -i -p "Choose action:")
[[ -z "$action" ]] && exit 0

# --- Mount logic ---
if [[ "$action" == "Mount" ]]; then
	# List unmounted partitions
	mountable=$(lsblk -lpno NAME,TYPE,SIZE,MOUNTPOINT | awk '$2=="part" && $4=="" {print $1, "(" $3 ")"}')
	[[ -z "$mountable" ]] && exit 1

	chosen=$(echo "$mountable" | dmenu -i -p "Select drive/partition to mount:" | awk '{print $1}')
	[[ -z "$chosen" ]] && exit 1

	if sudo mount "$chosen" 2>/dev/null; then
		pgrep -x dunst >/dev/null && notify-send "$chosen mounted (default)"
		exit 0
	fi

	dirs=$(find "$HOME/Usb" "$HOME/Data" /media -maxdepth 3 -type d 2>/dev/null)
	mountpoint=$(echo "$dirs" | dmenu -i -p "Choose mount point:")
	[[ -z "$mountpoint" ]] && exit 1

	if [[ ! -d "$mountpoint" ]]; then
		mkdiryn=$(printf "No\nYes" | dmenu -i -p "$mountpoint does not exist. Create it?")
		[[ "$mkdiryn" == "Yes" ]] && sudo mkdir -p "$mountpoint"
	fi

	if sudo mount "$chosen" "$mountpoint"; then
		pgrep -x dunst >/dev/null && notify-send "$chosen mounted to $mountpoint"
	else
		pgrep -x dunst >/dev/null && notify-send "Failed to mount $chosen"
	fi

# --- Unmount logic ---
elif [[ "$action" == "Unmount" ]]; then
	drives=$(lsblk -lpno NAME,SIZE,MOUNTPOINT | awk '$3!="" && $3!~/^(\/boot|\/home|\/)$/ {print $1, "(" $2 ")", "on", $3}')
	[[ -z "$drives" ]] && exit 0

	chosen=$(echo "$drives" | dmenu -i -p "Select drive to unmount:" | awk '{print $1}')
	[[ -z "$chosen" ]] && exit 0

	mountpoint=$(lsblk -lpno NAME,MOUNTPOINT | awk -v dev="$chosen" '$1==dev {print $2}')
	if sudo umount "$chosen"; then
		pgrep -x dunst >/dev/null && notify-send "$chosen unmounted from $mountpoint"
	else
		pgrep -x dunst >/dev/null && notify-send "Failed to unmount $chosen"
	fi
fi
