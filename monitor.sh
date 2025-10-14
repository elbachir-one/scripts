#!/usr/bin/env bash

# Trun off the laptop screen if the external moniter is pluged in

INTERNAL="LVDS-1"
EXTERNAL="HDMI-1"

if xrandr | grep -q "^$EXTERNAL connected"; then
	xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto
else
	xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --off
fi
