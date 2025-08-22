#!/usr/bin/env bash

set -e

declare mx my x y w h

((mx = $(xdotool getmouselocation --shell | grep X | awk -F "=" '{print $2}')))
((my = $(xdotool getmouselocation --shell | grep Y | awk -F "=" '{print $2}')))

xrandr --current | sed -nr 's/([^ ]+) [^0-9]+([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+).*/m="\1" w=\2 h=\3 x=\4 y=\5/p' | while read -r vars; do
  eval "$vars"
  if ! ((mx < x || mx > x + w || my < y || my > y + h)); then
    xdotool mousemove $((x + w / 2)) $((y + h / 2))
    xsetroot -cursor_name left_ptr
  fi
done
