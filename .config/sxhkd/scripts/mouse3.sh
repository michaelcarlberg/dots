#!/usr/bin/env bash

mousepos_in_window()
{
  declare -a geom=()

  eval "$(xdotool getmouselocation --shell)"
  mapfile -t geom < <(xdotool getwindowgeometry "$WINDOW" | tr -c '0-9' ' ' | tr -s ' ' | tr ' ' '\n' | sed -nr '3p;4p;6p;7p')

  ((mx = X - geom[0]))
  ((my = Y - geom[1]))
  ((width = geom[2]))
  ((height = geom[3]))

  px="$(echo "($mx / $width) * 100.0" | bc -l | cut -d. -f1)"
  py="$(echo "($my / $height) * 100.0" | bc -l | cut -d. -f1)"

  echo "$px $py"
}

xinput test 13 | while read -r evt; do
  case "$evt" in
    *"button press   9")
      mousepos_in_window | grep -q -E '^(1|9)[0-9] (1|9)[0-9]$'
      # 10 10     90 10     10  90      90 90
      echo alt down
      xdotool keydown super
      ;;
    *"button release 9")
      echo alt up
      xdotool keyup super
      ;;
  esac
done
