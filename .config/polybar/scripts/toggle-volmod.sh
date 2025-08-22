#!/bin/bash

set -e

case "$1" in
  alsa)
    echo "showing alsa module" >&2
    notify-send "polybar.sh" "Showing [module/volume-alsa]"
    polybar-msg action volume-alsa module_show
    polybar-msg action volume-pulse module_hide
    ;;

  pulse)
    echo "showing pulse module" >&2
    notify-send "polybar.sh" "Showing [module/volume-pulse]"
    polybar-msg action volume-alsa module_hide
    polybar-msg action volume-pulse module_show
    ;;

  *)
    echo "toggle current modules" >&2
    notify-send "polybar.sh" "Toggling [module/volume-*]"
    polybar-msg action volume-alsa module_toggle
    polybar-msg action volume-pulse module_toggle
    ;;
esac
