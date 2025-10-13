#!/bin/bash
for img in *.{png,bmp,gif,webp}; do
  if [[ -f "$img" ]]; then
    ffmpeg -i "$img" "${img%.*}.jpg"
  fi
done
