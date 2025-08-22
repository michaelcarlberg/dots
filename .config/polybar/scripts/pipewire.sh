#!/bin/bash

function main()
{
  exec 2>/dev/null

  SOURCE="$(pactl get-default-source)"
  SINK="$(pactl get-default-sink)"
  VOLUME="$(pactl get-sink-volume "$SINK" | grep -o -E '[0-9]+%' | head -1)"
  IS_MUTED="$(pactl get-sink-mute "$SINK" | grep -o 'yes$')"

  case "${action=$1}" in
    +) pactl set-sink-volume @DEFAULT_SINK@ +10% ;;
    -) pactl set-sink-volume @DEFAULT_SINK@ -10% ;;
    mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    *)
      if [ "$IS_MUTED" != "" ]; then
        echo " ${SOURCE} |   MUTED ${SINK}"
      else
        echo " ${SOURCE} |    ${VOLUME}% ${SINK}"
      fi
      ;;
  esac
}

main "$@"
