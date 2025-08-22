#!/bin/bash

if wmctrl -l | wc -l | grep -q 0; then
  set -- -e "There are no windows..."
fi

declare -i lines mx my x y w h
declare -a monitorloc=()

mapfile -t monitorloc < <(xrandr --query \
  | grep -E "^$(bspc query -M -m --names) connected" \
  | grep -oE "[0-9]+x[0-9]+\+[0-9]*\+[0-9]*" \
  | cut -d+ -f2-3 \
  | tr + '\n')

((mx = $(xdotool getmouselocation --shell | grep X | awk -F "=" '{print $2}')))
((my = $(xdotool getmouselocation --shell | grep Y | awk -F "=" '{print $2}')))

: $((mx -= monitorloc[0]))
: $((my -= monitorloc[1]))

read -r lines < <(wmctrl -l | wc -l | tr 0 1)

: $((--lines))

exec rofi \
  -show window \
  -show-icons \
  -window-format "{t}" \
  -window-thumbnail \
  -window-hide-active-window true \
  -monitor -3 \
  -click-to-exit \
  -hover-select \
  -me-select-entry '' \
  -me-accept-entry MousePrimary \
  -theme-str "listview { lines: $lines; }" \
  -theme-str 'inputbar, prompt { enabled: false; }' \
  -theme-str 'listview { cursor: pointer; margin: 0; }' \
  -theme-str "window { location: north west; x-offset: ${mx}px; y-offset: ${my}px; width: 300px; border-radius: 0; border: 1px; border-color: @bg2; }" \
  -theme-str 'mainbox { padding: 0; }' \
  -theme-str 'element { border: 0 0 1px 0; border-radius: 0; border-color: @bg2; }' \
  "$@"
