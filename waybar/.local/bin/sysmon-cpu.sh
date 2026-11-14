#!/usr/bin/env bash
# Outputs CPU usage as an integer 0-100
# Uses /proc/stat for accuracy (two samples, 0.5s apart)

prev=( $(grep '^cpu ' /proc/stat) )
sleep 0.5
curr=( $(grep '^cpu ' /proc/stat) )

prev_idle=$(( prev[4] + prev[5] ))
curr_idle=$(( curr[4] + curr[5] ))

prev_total=0; for v in "${prev[@]:1}"; do (( prev_total += v )); done
curr_total=0; for v in "${curr[@]:1}"; do (( curr_total += v )); done

d_total=$(( curr_total - prev_total ))
d_idle=$(( curr_idle - prev_idle ))

echo $(( (d_total - d_idle) * 100 / d_total ))
