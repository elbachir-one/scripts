#!/usr/bin/env bash

# Backup HOME directory files to a my server

SRC="$HOME/"
DEST="myserver:$HOME/Data/backup/home-$(date +%F)/"

EXCLUDE=(--exclude='.cache' --exclude='Downloads')

rsync -aAXv "${EXCLUDE[@]}" "${SRC[@]}" "${DEST[@]}"
