#!/usr/bin/env bash
# Single-instance launcher for wofi menus.
#
# Usage: launch.sh <name> <command...>
#   - No menu open:             runs <command>.
#   - Same <name> already open: closes it (acts as a toggle).
#   - Different menu open:      closes it, then opens this one.
#
# The menu runs in its own process group, so closing it also stops any
# wrapper script around wofi (e.g. wifi-menu.sh while it is still scanning).

dir="${XDG_RUNTIME_DIR:-/tmp}"
pidfile="$dir/wofi-menu.pid"
namefile="$dir/wofi-menu.name"

name=$1
shift

if [[ -f $pidfile ]] && pid=$(<"$pidfile") && kill -0 -- "-$pid" 2>/dev/null; then
  kill -- "-$pid" 2>/dev/null
  if [[ $(<"$namefile") == "$name" ]]; then
    rm -f "$pidfile"
    exit 0
  fi
  for _ in {1..20}; do
    kill -0 -- "-$pid" 2>/dev/null || break
    sleep 0.05
  done
fi
# Catch any wofi that was started some other way.
pkill -x wofi 2>/dev/null

echo "$name" >"$namefile"
setsid "$@" &
echo $! >"$pidfile"
wait $!
