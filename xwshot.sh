#!/usr/bin/env bash

# Script to take Screenshots on X11 and Wayland

save_dir="${HOME}/Pictures/Screenshots"
mkdir -p "$save_dir"
timestamp=$(date +%H-%M-%S-%d-%m-%Y)
file="${save_dir}/${timestamp}.png"

# Detect session type: x11 or wayland
session_type=$(loginctl show-session "$(loginctl | awk "/$(whoami)/ {print \$1}")" -p Type --value)

show_menu() {
	if [ "$session_type" = "x11" ]; then
		echo -e "full\narea\nwindow" | dmenu -p "Screenshot:" 
	else
		echo -e "full\narea\nwindow" | dmenu-wl -p "Screenshot:"
	fi
}

take_x11_screenshot() {
	choice="$1"
	if ! command -v import &>/dev/null; then
		notify-send "❌ Missing: ImageMagick 'import'"
		exit 1
	fi
	case "$choice" in
		full)
			import -window root "$file"
			;;
		area)
			import "$file"
			;;
		window)
			if ! command -v xdotool &>/dev/null; then
				notify-send "❌ Missing: xdotool"
				exit 1
			fi
			window_id=$(xdotool selectwindow)
			import -window "$window_id" "$file"
			;;
		*)
			notify-send "❌ Unknown choice: $choice"
			exit 1
			;;
	esac
}

take_wayland_screenshot() {
	choice="$1"
	if ! command -v grim &>/dev/null; then
		notify-send "❌ Missing: grim"
		exit 1
	fi
	case "$choice" in
		full)
			grim "$file"
			;;
		area)
			if ! command -v slop &>/dev/null; then
				notify-send "❌ Missing: slop"
				exit 1
			fi
			read -r geometry < <(slop -f "%x %y %w %h")
			[ -z "$geometry" ] && notify-send "❌ Cancelled" && exit 1
			read -r x y w h <<< "$geometry"
			grim -g "${x},${y} ${w}x${h}" "$file"
			;;
		window)
			if ! command -v slurp &>/dev/null; then
				notify-send "❌ Missing: slurp"
				exit 1
			fi
			region=$(slurp)
			[ -z "$region" ] && notify-send "❌ Cancelled" && exit 1
			grim -g "$region" "$file"
			;;
		*)
			notify-send "❌ Unknown choice: $choice"
			exit 1
			;;
	esac
}

choice=$(show_menu)

if [ -z "$choice" ]; then
	notify-send "❌ Screenshot cancelled"
	exit 1
fi

if [ "$session_type" = "x11" ]; then
	take_x11_screenshot "$choice" && notify-send "✅ Screenshot saved: $file" || notify-send "❌ Screenshot failed"
elif [ "$session_type" = "wayland" ]; then
	take_wayland_screenshot "$choice" && notify-send "✅ Screenshot saved: $file" || notify-send "❌ Screenshot failed"
else
	notify-send "❌ Unsupported session type: $session_type"
	exit 1
fi
