#!/usr/bin/env bash
# Outputs JSON: {"cpu": 54, "gpu": 61}
# CPU: reads coretemp (Intel) or k10temp (AMD) straight from sysfs.
# Deliberately avoids `sensors`, which also queries the NVMe drives and
# kept the system SSD busy (each call took up to ~2.5s).
# GPU: nvidia-smi

cpu_temp=0
for h in /sys/class/hwmon/hwmon*; do
  case "$(<"$h/name")" in
    coretemp|k10temp)
      for l in "$h"/temp*_label; do
        case "$(<"$l")" in
          "Package id 0"|Tctl) cpu_temp=$(( $(<"${l%_label}_input") / 1000 )); break 2 ;;
        esac
      done
      ;;
  esac
done

gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu \
           --format=csv,noheader,nounits 2>/dev/null \
  | tr -d ' ')
gpu_temp=${gpu_temp:-0}

echo "{\"cpu\":$cpu_temp,\"gpu\":$gpu_temp}"
