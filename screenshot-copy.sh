#!/usr/bin/env bash

# Taking screenshot and copy to clipboard or save it with scrot and slop.
# Also giving 3 options Fullscreen/Section/Area.
# After taking a screenshot, you will be given an option to either save it or
# copy it to the clipboard without saving.
# You will also receive a notification confirming your chosen action.

IMG_PATH="$HOME/Images/Shots/"
TIME=2000

# Making sure that the screenshot directory exists if not create it.
mkdir -p "$IMG_PATH"

# Choose screenshot type.
prog="1. Fullscreen
2. Section (click on window)
3. Area (select area with mouse)"
cmd=$(echo -e "$prog" | dmenu -p 'ScreenShot')

# Timestamped screenshot.
file="$(date '+ScreenShot-%Y-%m-%d-@%H-%M-%S.png')"
cd "$IMG_PATH"

case ${cmd%% *} in
	1.*)
		scrot -d 1 -q 100 "$file" && \
		notify-send -u low -t "$TIME" 'scrot' 'Full Screen Shot saved'
		;;
	2.*)
		scrot -d 1 -s -q 100 "$file" && \
		notify-send -u low -t "$TIME" 'scrot' 'Section Screen Shot saved'
		;;
	3.*)
		geometry=$(slop -f "%x,%y,%w,%h")
		if [ -z "$geometry" ]; then
			notify-send -u critical -t "$TIME" 'Error' 'Area selection canceled'
			exit 1
		fi
		scrot -a "$geometry" -q 100 "$file" && \
		notify-send -u low -t "$TIME" 'scrot' 'Area Screen Shot saved'
		;;
	*)
		notify-send -u critical -t "$TIME" 'Error' 'Invalid selection'
		exit 1
		;;
esac

# This is an option to choose what to do with the screenshot.
action=$(echo -e "Copy to clipboard\nSave to Dist directory" | dmenu -p 'Screenshot Action')

if [[ "$action" == "Copy to clipboard" ]]; then
	xclip -selection clipboard -t image/png -i "$IMG_PATH$file"
	rm "$IMG_PATH$file"
	notify-send -u low -t "$TIME" 'Clipboard' 'Screenshot copied to clipboard and removed the file'
elif [[ "$action" == "Save to Dist directory" ]]; then
	notify-send -u low -t "$TIME" 'Saved' 'Screenshot saved in the dist directory'
else
	notify-send -u critical -t "$TIME" 'Action Error' 'No valid post-screenshot action selected'
fi
