#!/bin/bash

set_brightness()
{
  xrandr -q | grep " connected" | cut -d' ' -f1 | while read -r display; do
    xrandr --output "$display" --brightness "${1?brightness}"
  done
}

amixer set Master toggle
set_brightness 0

while [ "$input" != "ok" ]; do
  read -e -r input
  if [ "$input" != "" ]; then
    ((empty = 0))
  elif ((empty++ > 10)); then
    break
  fi
done

set_brightness 1
amixer set Master toggle
