#!/usr/bin/env bash

#
# Mount/unmount drives and MTP phones via dmenu
#

PHONE_MOUNT="$HOME/Phone"

action=$(printf "Mount\nUnmount" | dmenu -i -p "Choose action:")
[[ -z "$action" ]] && exit 0

if [[ "$action" == "Mount" ]]; then
	devices=$(simple-mtpfs -l 2>/dev/null)

	menu=""
	drives=$(lsblk -lpno NAME,TYPE,SIZE,MOUNTPOINT | awk '$2=="part" && $4=="" {print $1 " (drive " $3 ")"}')
	[[ -n "$drives" ]] && menu+="$drives"$'\n'

	[[ -n "$devices" ]] && menu+="Phone: ${devices//$'\n'/$'\n'Phone: }"

	[[ -z "$menu" ]] && notify-send "Mount" "No devices available" && exit 1

	chosen=$(echo "$menu" | dmenu -i -p "Select device to mount:")
	[[ -z "$chosen" ]] && exit 1

	if [[ "$chosen" == Phone:* ]]; then
		index=$(echo "$chosen" | awk -F: '{print $2}' | awk '{print $1}')
		[ -d "$PHONE_MOUNT" ] || mkdir -p "$PHONE_MOUNT"

		if simple-mtpfs --device "$index" "$PHONE_MOUNT"; then
			notify-send "Phone mounted at $PHONE_MOUNT"
		else
			notify-send "Failed to mount phone"
			exit 1
		fi
		exit 0
	fi

	chosen_dev=$(echo "$chosen" | awk '{print $1}')

	dirs=$(find "$HOME/Usb" "$HOME/Data" /media -maxdepth 3 -type d 2>/dev/null)
	mountpoint=$(echo "$dirs" | dmenu -i -p "Choose mount point:")
	[[ -z "$mountpoint" ]] && exit 1

	[[ ! -d "$mountpoint" ]] && mkdiryn=$(printf "No\nYes" | dmenu -i -p "$mountpoint does not exist. Create it?") && [[ "$mkdiryn" == "Yes" ]] && sudo mkdir -p "$mountpoint"

	fstype=$(lsblk -no FSTYPE "$chosen_dev")

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

	drives=$(lsblk -lpno NAME,SIZE,MOUNTPOINT | awk '$3!="" && $3!~/^(\/boot|\/home|\/)$/ {print $1 " (drive " $2 ") on " $3}')
	[[ -n "$drives" ]] && menu+="$drives"$'\n'

	if mount | grep -q "on $PHONE_MOUNT type fuse.simple-mtpfs"; then
		menu+="Phone at $PHONE_MOUNT"$'\n'
	fi

	[[ -z "$menu" ]] && notify-send "Unmount" "No devices mounted" && exit 0

	chosen=$(echo "$menu" | dmenu -i -p "Select device to unmount:")
	[[ -z "$chosen" ]] && exit 0

	if [[ "$chosen" == Phone* ]]; then
		fusermount -u "$PHONE_MOUNT" && notify-send "Phone unmounted"
		exit 0
	fi

	chosen_dev=$(echo "$chosen" | awk '{print $1}')
	mountpoint=$(lsblk -lpno NAME,MOUNTPOINT | awk -v dev="$chosen_dev" '$1==dev {print $2}')

	if sudo umount "$chosen_dev"; then
		notify-send "$chosen_dev unmounted from $mountpoint"
	else
		notify-send "Failed to unmount $chosen_dev"
	fi
fi
