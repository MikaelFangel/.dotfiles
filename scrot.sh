#!/bin/env bash

path="$HOME/Pictures"
if ! [ -d "$path" ]; then
  mkdir -p "$path"
fi

grim -g "$(slurp -w 2)" "$path/screen-$(date '+%Y-%m-%d-%H:%M:%S').jpg"
