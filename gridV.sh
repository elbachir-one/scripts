#!/bin/bash

# Ensure that four input videos are passed as arguments
if [ $# -ne 4 ]; then
    echo "Usage: $0 <input1> <input2> <input3> <input4>"
    exit 1
fi

# Assign arguments to variables
input1="$1"
input2="$2"
input3="$3"
input4="$4"

# Output file name
output="out.mkv"

# Create a 2x2 video grid using FFmpeg
ffmpeg \
   -i "$input1" \
   -i "$input2" \
   -i "$input3" \
   -i "$input4" \
  -filter_complex " \
      [0:v] setpts=PTS-STARTPTS, scale=hd1080 [a0]; \
      [1:v] setpts=PTS-STARTPTS, scale=hd1080 [a1]; \
      [2:v] setpts=PTS-STARTPTS, scale=hd1080 [a2]; \
      [3:v] setpts=PTS-STARTPTS, scale=hd1080 [a3]; \
      [a0][a1][a2][a3]xstack=inputs=4:layout=0_0|0_h0|w0_0|w0_h0[out] \
      " \
   -map "[out]" \
   -c:v libx264 -t '55' -f matroska "$output"
