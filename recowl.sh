#!/usr/bin/env bash

# Mini screen recorder tool for wayland WM

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/wfrec"
PIDFILE="$STATE_DIR/pid"
RAWFILE="$STATE_DIR/raw"
PALETTE="$STATE_DIR/palette.png"
OUTDIR="$HOME/Downloads"

mkdir -p "$STATE_DIR" "$OUTDIR"

notify() {
	notify-send -t 3000 "$1" "$2"
}

cleanup() {
	rm -f "$PIDFILE" "$RAWFILE" "$PALETTE"
}

stop_recording() {
	local pid raw gif

	pid="$(cat "$PIDFILE" 2>/dev/null || true)"
	raw="$(cat "$RAWFILE" 2>/dev/null || true)"

	if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
		kill -INT "$pid"

		for _ in {1..50}; do
			kill -0 "$pid" 2>/dev/null || break
			sleep 0.1
		done
	fi

	rm -f "$PIDFILE"

	if [ -n "${raw:-}" ] && [ -f "$raw" ]; then
		gif="${raw%.mkv}.gif"

		ffmpeg -y -i "$raw" \
			-vf "fps=12,scale=800:-1:flags=lanczos" \
			-gifflags -offsetting \
			-vf "palettegen" \
			"$PALETTE" >/dev/null 2>&1

		ffmpeg -y -i "$raw" -i "$PALETTE" \
			-lavfi "fps=12,scale=800:-1:flags=lanczos[x];[x][1:v]paletteuse" \
			-loop 0 "$gif" >/dev/null 2>&1

		if [ -f "$gif" ]; then
			wl-copy < "$gif"
			notify "Recording stopped" "GIF copied to clipboard."
		else
			notify "Recording stopped" "GIF conversion failed."
		fi
	else
		notify "Recording stopped" "No recording found."
	fi

	cleanup
}

start_recording() {
	local geom raw pid

	geom="$(slurp 2>/dev/null)" || exit 1
	[ -n "$geom" ] || exit 1

	raw="$OUTDIR/clip_$(date +%s).mkv"

	# start recording (add --audio if you want sound)
	nohup wf-recorder -g "$geom" -f "$raw" >/dev/null 2>&1 &
	pid=$!

	sleep 0.3
	if ! kill -0 "$pid" 2>/dev/null; then
		notify "Recording failed" "wf-recorder exited immediately."
		cleanup
		exit 1
	fi

	printf '%s\n' "$pid" > "$PIDFILE"
	printf '%s\n' "$raw" > "$RAWFILE"

	notify "Recording started" "Run again to stop."
}

if [ -f "$PIDFILE" ]; then
	stop_recording
else
	start_recording
fi
