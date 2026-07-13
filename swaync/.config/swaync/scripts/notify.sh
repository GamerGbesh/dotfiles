#!/usr/bin/env bash

STATE=$(swaync-client -D)

if [ "$STATE" = "false" ]; then
    paplay --volume=32768 ~/.config/swaync/notification.ogg
fi

