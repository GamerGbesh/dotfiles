#!/usr/bin/env bash

# Reload Waybar
pkill waybar
waybar >/dev/null 2>&1 &

# Reload Hyprland configuration
hyprctl reload

# Reload swaync
pkill -SIGUSR2 swaync

# Reload pywal colors in running kitty windows
kitten @ set-colors --all ~/.cache/wal/colors-kitty.conf 2>/dev/null
