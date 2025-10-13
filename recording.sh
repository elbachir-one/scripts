#!/bin/bash

# Screen Recorder with Multiple Options
# Requirements: ffmpeg, dmenu, slop

function stop_recording() {
	kill "$ffmpeg_pid" 2>/dev/null
	exit
}

trap stop_recording SIGINT

# Set output directory
output_dir="$HOME/Recordings"
mkdir -p "$output_dir"

# Ask for filename
output_file=$(echo "" | dmenu -p "File name:")
if [ -z "$output_file" ]; then
	exit 1
fi

# Choose recording mode
mode=$(echo -e "Record 1366x768\nRecord 1920x1080\nSelect Area\nRecord Both Screens" | dmenu -p "Select recording mode:")

case "$mode" in
	"Record 1366x768")
		video_size="1366x768"
		offset="0,0"
		ffmpeg -framerate 30 -f x11grab -video_size "$video_size" -i :0.0+"$offset" \
			-preset ultrafast -crf 8 "$output_dir/$output_file" &
		;;

	"Record 1920x1080")
		video_size="1920x1080"
		# Adjust the offset if your second monitor starts after 1366px
		offset="1366,0"
		ffmpeg -framerate 30 -f x11grab -video_size "$video_size" -i :0.0+"$offset" \
			-preset ultrafast -crf 8 "$output_dir/$output_file" &
		;;

	"Select Area")
		read -r X Y WIDTH HEIGHT < <(slop -f "%x %y %w %h")
		if [[ -z "$X" || -z "$Y" || -z "$WIDTH" || -z "$HEIGHT" ]]; then
			echo "Invalid area selected."
			exit 1
		fi
		ffmpeg -f x11grab -video_size "${WIDTH}x${HEIGHT}" -i ":0.0+${X},${Y}" \
			-c:v libx264 -preset ultrafast -crf 18 "$output_dir/$output_file" &
		;;

	"Record Both Screens")
		video_size="3286x1848"
		offset="0,0"
		ffmpeg -framerate 30 -f x11grab -video_size "$video_size" -i :0.0+"$offset" \
			-preset ultrafast -crf 8 "$output_dir/$output_file" &
		;;

	*)
		echo "No valid option selected."
		exit 1
		;;
esac

ffmpeg_pid=$!

wait "$ffmpeg_pid"
