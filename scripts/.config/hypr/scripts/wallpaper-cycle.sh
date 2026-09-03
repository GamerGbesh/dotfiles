#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

while true; do
    wallpaper=$(find -L "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) |
        shuf -n 1)

    [ -n "$wallpaper" ] && awww img "$wallpaper" \
        --transition-type random \
        --transition-duration 1.5
    sleep $((60 * 10))
done
