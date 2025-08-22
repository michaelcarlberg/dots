#!/bin/bash

set -e

ICON_TILED=
ICON_PSEUDOTILED=
ICON_FLOATING=
ICON_FULLSCREEN=
ICON_MONOCLE=''

bar="${1:-main}"
monitor="$(polybar-helper monitor "$bar")"

exec 2>/dev/null

bspc subscribe report | while read -r; do
  if ! bspwm-helper active-monitor | grep -q "^${monitor}"; then
    continue
  fi

  mapfile -t windows < <(bspc query -N -d | while read -r window; do
    if ! xprop -id "$window" WM_NAME &>/dev/null; then
      continue
    elif ! bspc query -T -n "$window" | jq -r .client.state | grep -q -E '(floating|fullscreen)'; then
      echo "$window"
    fi
  done)

  icon=''
  status="$(bspwm-helper monitor-status "$monitor")"

  if grep -q ':LM:' <<<"$status"; then
    icon="%{A1:bspc desktop -l tiled:}$ICON_MONOCLE%{A}"
    # if ((${#windows[@]} > 1)); then
    #   icon="%{A1:bspc desktop -l tiled:}$ICON_MONOCLE%{A}"
    # fi
  elif grep -q ':LT:' <<<"$status"; then
    case "$(bspwm-helper node-state)" in
      T) icon="$ICON_TILED" ;;
      P) icon="$ICON_PSEUDOTILED" ;;
      F) icon="$ICON_FLOATING" ;;
      =) icon="$ICON_FULLSCREEN" ;;
      @) icon="$ICON_FULLSCREEN" ;;
    esac
  fi

  if [ "$icon" != "$was" ]; then
    echo "$icon"
  fi

  was="${bar}$(bspc query -D -d)${icon}"
done
