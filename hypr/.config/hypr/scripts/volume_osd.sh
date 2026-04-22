#!/bin/bash

# Get volume (returns like: "Volume: 0.45")
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Extract number and convert to %
volume=$(echo $vol | awk '{print int($2 * 100)}')

# Check mute
if echo $vol | grep -q MUTED; then
    notify-send -a "volume" \
        -u low \
        -h int:value:0 \
        -h string:x-canonical-private-synchronous:volume \
        "Muted"
else
    notify-send -a "volume" \
        -u low \
        -h int:value:$volume \
        -h string:x-canonical-private-synchronous:volume \
        "Volume: $volume%"
fi
