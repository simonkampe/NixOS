#!/usr/bin/env bash

num_monitors=$(hyprctl monitors | grep -c "Monitor")

if [[ num_monitors -gt 1 ]]; then
  hyprctl keyword monitor "eDP-1, disable"
fi