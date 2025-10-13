#!/usr/bin/env bash

INTERNAL="LVDS-1"
EXTERNAL="HDMI-1"

# Check if external monitor is connected
if xrandr | grep -q "^$EXTERNAL connected"; then
	xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto
else
	xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --off
fi
