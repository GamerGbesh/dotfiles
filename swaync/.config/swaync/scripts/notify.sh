#!/usr/bin/env bash

STATE=$(swaync-client -D)

if [ "$STATE" = "false" ]; then
    paplay ~/.config/swaync/notification.ogg
fi

