#!/usr/bin/env bash

set -eo pipefail

declare -A visible
declare monitor

for monitor in $(bspwm-helper list-monitors); do
  window="$(polybar-helper list-monitor-bars "$monitor" | head -1)"
  [ "$window" ] || continue

  bar="$(polybar-helper list-monitor-bars "$monitor" | head -1)"
  [ "$bar" ] || continue

  if xprop -id "$(polybar-helper window-id "$bar")" WM_STATE | grep -q Withdrawn; then
    visible[monitor]='false'
  else
    visible[monitor]='true'
  fi

  if ! polybar -q -d override-redirect "$bar" 2>/dev/null | grep -q true; then
    echo "warning: override-redirect should probably be true..." >&2
  fi
  if polybar -q -d wm-restack "$bar" &>/dev/null; then
    echo "warning: wm-restack should probably not be used..." >&2
  fi
done

while sleep .1; do
  monitor="$(bspwm-helper focused-monitor)"
  if ! ${visible[monitor]} && xdotool getmouselocation --shell | grep -q Y=0; then
    if sleep .5 && xdotool getmouselocation --shell | grep -q Y=0; then
      polybar-helper show "$monitor"
      visible[monitor]='true'
    fi
  elif ${visible[monitor]}; then
    if sleep 1 && ! xdotool getmouselocation --shell | grep -qE '^Y=(|1|2)[0-9]$'; then
      polybar-helper hide "$monitor"
      visible[monitor]='false'
    fi
  fi
done
