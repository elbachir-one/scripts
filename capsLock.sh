#!/bin/bash

caps_status=$(xset q | grep "Caps Lock:" | awk '{print $4}')

if [ "$caps_status" == "on" ]; then
    notify-send "Caps Lock is ON"
else
    notify-send "Caps Lock is OFF"
fi
