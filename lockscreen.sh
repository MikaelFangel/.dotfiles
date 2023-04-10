#!/bin/env bash

path=/tmp/tmpbg.png
pathout=/tmp/tmpbgblur.png

# Take screenshot
grim "$path"

# Use gaussion blur
ffmpeg -i "$path" -filter:v "gblur=sigma=40" -frames:v 1 "$pathout" > /dev/null 2>&1

# Lock the screen
swaylock -c '1b2021' -i "$pathout"

# Remove temp bgs
rm -f "$path" "$pathout"
