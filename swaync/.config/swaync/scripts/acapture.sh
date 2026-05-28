#!/usr/bin/env bash

amixer set Capture toggle

STATE=$(amixer get Capture | grep -o '\[on\]\|\[off\]' | head -n1)

if [ "$STATE" = "[off]" ]; then
    notify-send "Mic muted"
else
    notify-send "Mic enabled"
fi
