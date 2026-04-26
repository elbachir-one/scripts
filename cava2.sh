#!/bin/bash

[ -n "$BLOCK_BUTTON" ] && notify-send "$BLOCK_BUTTON"

# just launch updatecava.sh and output
/home/vecondite/dwm/dwmblocks-async/scripts/bgtasks/updatecava.sh
