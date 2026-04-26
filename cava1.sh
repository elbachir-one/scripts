#!/bin/bash

[ -n "$BLOCK_BUTTON" ] && notify-send "$BLOCK_BUTTON"

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# create dictionary to replace char with bar
for ((i=0; i<${#bar}; i++)); do
    dict+="s/$i/${bar:$i:1}/g;"
done

# cava config
config_file="$(mktemp)"
cat > "$config_file" <<EOF
[general]
bars = 10
framerate = 20

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# Pipe cava directly to colorize.sh, no /tmp file
cava -p "$config_file" | while read -r line; do
    out=$(sed "$dict" <<< "$line")
    /home/vecondite/dwm/dwmblocks-async/scripts/colorize.sh "$out"
done

rm "$config_file"
