#!/usr/bin/env bash

SRC="$HOME/"
DEST="myserver:/home/sh/Data/backup/home-$(date +%F)/"

EXCLUDE=(--exclude='.cache' --exclude='Downloads')

rsync -aAXv "${EXCLUDE[@]}" "${SRC[@]}" "${DEST[@]}"
