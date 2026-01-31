#!/usr/bin/env bash

#
# Mount/unmount drives and MTP phones via dmenu
#

PHONE_MOUNT="$HOME/Phone"

is_swap() {
	local dev="$1"
	grep -q "^$dev" /proc/swaps
}

# Ask for action
action=$(printf "Mount\nUnmount" | dmenu -i -p "Choose action:")
[[ -z "$action" ]] && exit 0

if [[ "$action" == "Mount" ]]; then
	devices=$(simple-mtpfs -l 2>/dev/null)

	menu=""

	drives=$(lsblk -lpno NAME,TYPE,SIZE,MOUNTPOINT | awk '$2=="part" && $4=="" {print $1 " (drive " $3 ")"}')

	while IFS= read -r dev; do
		dev_name=$(echo "$dev" | awk '{print $1}')
		[[ "$dev_name" == "/boot"* || "$dev_name" == "/"* ]] && continue
		is_swap "$dev_name" && continue
		menu+="$dev"$'\n'
	done <<< "$drives"

	if [[ -n "$devices" ]]; then
		while IFS= read -r dev; do
			menu+="Phone: $dev"$'\n'
		done <<< "$devices"
	fi

	[[ -z "$menu" ]] && notify-send "Mount" "No devices available" && exit 1

	chosen=$(echo "$menu" | dmenu -i -p "Select device to mount:")
	[[ -z "$chosen" ]] && exit 1

	# Handle phone mounting
	if [[ "$chosen" == Phone:* ]]; then
		index=$(echo "$chosen" | awk -F: '{print $2}' | awk '{print $1}')
		[[ -d "$PHONE_MOUNT" ]] || mkdir -p "$PHONE_MOUNT"

		if simple-mtpfs --device "$index" "$PHONE_MOUNT"; then
			notify-send "Phone mounted at $PHONE_MOUNT"
		else
			notify-send "Failed to mount phone"
			exit 1
		fi
		exit 0
	fi

	# Handle normal drive mounting
	chosen_dev=$(echo "$chosen" | awk '{print $1}')

	# Ask for mount point
	dirs=$(find "$HOME/Usb" "$HOME/Data" /media -maxdepth 3 -type d 2>/dev/null)
	mountpoint=$(echo "$dirs" | dmenu -i -p "Choose mount point:")
	[[ -z "$mountpoint" ]] && exit 1

	# Optionally create mount point if it doesn't exist
	if [[ ! -d "$mountpoint" ]]; then
		mkdiryn=$(printf "No\nYes" | dmenu -i -p "$mountpoint does not exist. Create it?")
		[[ "$mkdiryn" == "Yes" ]] && sudo mkdir -p "$mountpoint"
	fi

	fstype=$(lsblk -no FSTYPE "$chosen_dev")

	# Mount based on filesystem type
	if [[ "$fstype" == "ntfs" || "$fstype" == "vfat" ]]; then
		if sudo mount -o uid=1000,gid=1000,umask=000 "$chosen_dev" "$mountpoint"; then
			notify-send "$chosen_dev mounted to $mountpoint"
		else
			notify-send "Failed to mount $chosen_dev"
		fi
	else
		if sudo mount "$chosen_dev" "$mountpoint"; then
			notify-send "$chosen_dev mounted to $mountpoint"
		else
			notify-send "Failed to mount $chosen_dev"
		fi
	fi

elif [[ "$action" == "Unmount" ]]; then
	menu=""

	# List mounted partitions excluding /boot, /home, /, and swap
	drives=$(lsblk -lpno NAME,SIZE,MOUNTPOINT | awk '$3!="" && $3!~/^(\/boot|\/home|\/)$/ {print $1 " (drive " $2 ") on " $3}')

	while IFS= read -r dev; do
		dev_name=$(echo "$dev" | awk '{print $1}')
		is_swap "$dev_name" && continue
		menu+="$dev"$'\n'
	done <<< "$drives"

	# Add phone if mounted
	if mount | grep -q "on $PHONE_MOUNT type fuse.simple-mtpfs"; then
		menu+="Phone at $PHONE_MOUNT"$'\n'
	fi

	[[ -z "$menu" ]] && notify-send "Unmount" "No devices mounted" && exit 0

	chosen=$(echo "$menu" | dmenu -i -p "Select device to unmount:")
	[[ -z "$chosen" ]] && exit 0

	# Handle phone unmounting
	if [[ "$chosen" == Phone* ]]; then
		fusermount -u "$PHONE_MOUNT" && notify-send "Phone unmounted"
		exit 0
	fi

	# Handle normal device unmount
	chosen_dev=$(echo "$chosen" | awk '{print $1}')
	mountpoint=$(lsblk -lpno NAME,MOUNTPOINT | awk -v dev="$chosen_dev" '$1==dev {print $2}')

	if sudo umount "$chosen_dev"; then
		notify-send "$chosen_dev unmounted from $mountpoint"
	else
		notify-send "Failed to unmount $chosen_dev"
	fi
fi
