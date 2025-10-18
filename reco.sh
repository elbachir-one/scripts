#!/usr/bin/env bash

if pgrep -x "ffmpeg" > /dev/null; then
	echo "󱜐"
else
	echo "󱜅"
fi
