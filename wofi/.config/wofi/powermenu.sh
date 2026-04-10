#!/bin/bash

choice=$(echo -e "Shutdown\nReboot\nLogout\nSuspend" | wofi --dmenu --prompt "Power Menu")

case "$choice" in
  Shutdown) systemctl poweroff ;;
  Reboot) systemctl reboot ;;
  Logout) hyprctl dispatch exit ;;
  Suspend) systemctl suspend ;;
esac
