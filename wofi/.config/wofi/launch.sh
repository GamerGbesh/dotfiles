#!/usr/bin/env bash
# Single-instance launcher for menus (wofi, the Quickshell Wi-Fi panel).
#
# Usage: launch.sh <name> <command...>
#   - No menu open:             runs <command>.
#   - Same <name> already open: closes it (acts as a toggle).
#   - Different menu open:      closes it, then opens this one.
#
# Only the menu process itself is ever killed (plus any stray wofi). It is
# matched by PID *and* start time, so a finished menu's PID can never match
# another program, and apps launched from a menu are never touched.

dir="${XDG_RUNTIME_DIR:-/tmp}"
state="$dir/menu-launch.state" # "<pid> <starttime> <name>"

name=$1
shift

# Process start time (field 22 of /proc/PID/stat; skip past "(comm)" first,
# since the command name can contain spaces).
starttime() { sed 's/.*) //' "/proc/$1/stat" 2>/dev/null | awk '{print $20}'; }

if read -r pid start open_name <"$state" 2>/dev/null &&
  [[ -n $pid && $(starttime "$pid") == "$start" ]]; then
  kill "$pid" 2>/dev/null
  pkill -x wofi 2>/dev/null
  if [[ $open_name == "$name" ]]; then
    rm -f "$state"
    exit 0
  fi
  for _ in {1..20}; do
    [[ $(starttime "$pid") == "$start" ]] || break
    sleep 0.05
  done
fi
# Catch any wofi that was started some other way.
pkill -x wofi 2>/dev/null

"$@" &
pid=$!
echo "$pid $(starttime "$pid") $name" >"$state"
wait "$pid"

# The menu closed by itself (e.g. an app was picked): forget it, unless
# another menu has already replaced it.
read -r cur _ <"$state" 2>/dev/null
[[ $cur == "$pid" ]] && rm -f "$state"
