#!/usr/bin/env bash

STATE=$(swaync-client -d)

if [ "$STATE" = "true" ]; then
    notify-send "DND Enabled"
else
    notify-send "DND Disabled"
fi
