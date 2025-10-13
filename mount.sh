#!/usr/bin/env bash

# Prompt user for action
action=$(echo -e "Mount\nUnmount" | dmenu -i -p "Choose action:")
[[ -z "$action" ]] && exit 0

# Mount logic
if [[ "$action" == "Mount" ]]; then
	pgrep -x dmenu && exit

	mountable=$(lsblk -lp | grep "part $" | awk '{print $1, "(" $4 ")"}')
	[[ -z "$mountable" ]] && exit 1

	chosen=$(echo "$mountable" | dmenu -i -p "Mount drive?" | awk '{print $1}')
	[[ -z "$chosen" ]] && exit 1

	if sudo mount "$chosen"; then
		pgrep -x dunst && notify-send "$chosen Mounted"
		exit 0
	fi

	dirs=$(find /home/$USER/Usb/ /home/$USER/Data/ /media -type d -maxdepth 3 2>/dev/null)
	mountpoint=$(echo "$dirs" | dmenu -i -p "Choose mount point")
	[[ -z "$mountpoint" ]] && exit 1

	if [[ ! -d "$mountpoint" ]]; then
		mkdiryn=$(echo -e "No\nYes" | dmenu -i -p "$mountpoint does not exist. Create it?")
		[[ "$mkdiryn" = "Yes" ]] && sudo mkdir -p "$mountpoint"
	fi

	sudo mount "$chosen" "$mountpoint" && pgrep -x dunst && notify-send "$chosen Mounted to $mountpoint"

# Unmount logic
elif [[ "$action" == "Unmount" ]]; then
	exclusionregex="\(/boot\|/home\|/\)$"
	drives=$(lsblk -lp | grep "t /" | grep -v "$exclusionregex" | awk '{print $1, "(" $4 ")", "on", $7}')
	[[ -z "$drives" ]] && exit 0

	chosen=$(echo "$drives" | dmenu -i -p "Unmount drive?" | awk '{print $1}')
	[[ -z "$chosen" ]] && exit 0

	mountpoint=$(lsblk -lp | awk -v dev="$chosen" '$1 == dev {print $7}')
	if sudo umount "$chosen"; then
		pgrep -x dunst && notify-send "$chosen Unmounted from $mountpoint"
	fi
fi

# Old one
#pgrep -x dmenu && exit
#
#mountable=$(lsblk -lp | grep "part $" | awk '{print $1, "(" $4 ")"}')
#[[ "$mountable" = "" ]] && exit 1
#chosen=$(echo "$mountable" | dmenu -i -p "Mount drive?" | awk '{print $1}')
#[[ "$chosen" = "" ]] && exit 1
#sudo mount "$chosen" && exit 0
#
#dirs=$(find /home/$who/Usb/ /home/$who/Data/ /media -type d -maxdepth 3 2>/dev/null)
#mountpoint=$(echo "$dirs" | dmenu -i -p "Type the mount point")
#[[ "$mountpoint" = "" ]] && exit 1
#if [[ ! -d "$mountpoint" ]]; then
#	mkdiryn=$(echo -e "No\nYes" | dmenu -i -p "$mountpoint does not exist. Create it?")
#	[[ "$mkdiryn" = Yes ]] && sudo mkdir -p "$mountpoint"
#fi
#sudo mount $chosen $mountpoint && pgrep -x dunst && notify-send "$chosen Mounted To $mountpoint."
#
#exclusionregex="\(/boot\|/home\|/\)$"
#drives=$(lsblk -lp | grep "t /" | grep -v "$exclusionregex" | awk '{print $1, "(" $4 ")", "on", $7}')
#[[ "$drives" = "" ]] && exit
#chosen=$(echo "$drives" | dmenu -i -p "Unmount drive?" | awk '{print $1}')
#[[ "$chosen" = "" ]] && exit
#sudo umount $chosen && pgrep -x dunst && notify-send "$chosen Unmounted"
