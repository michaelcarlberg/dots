#!/usr/bin/env bash

set -e

COLOR_TEXT='#cbcee0'
COLOR_ICON='#626985'

ICON_MUTED=''
ICON_VOLUME=('' '' '' '')

toggle_module()
{
  if pactl info &>/dev/null; then
    polybar-msg action '#volume-alsa.module_hide' || :
    polybar-msg action '#volume-pulse.module_show' || :
  else
    polybar-msg action '#volume-alsa.module_show' || :
    polybar-msg action '#volume-pulse.module_hide' || :
  fi
}

server_name()
{
  if pactl info &>/dev/null; then
    echo pulse
  elif amixer -c 0 &>/dev/null; then
    echo alsa
  fi
}

alsa_volume()
{
  if amixer -c 0 sget 'Master',0 | tail -1 | grep -q -E 'off'; then
    echo muted
  else
    amixer -c 0 sget 'Master',0 | tail -1 | sed -nr 's/.*\[([0-9]+)%\].*/\1/p'
  fi
}

alsa_events()
{
  alsactl monitor 2>/dev/null | while read -r event; do
    case "$event" in
      *Volume*) alsa_volume ;;
      *Switch*) alsa_volume ;;
    esac
  done
}

pulse_volume()
{
  if pactl get-sink-mute '@DEFAULT_SINK@' | grep -q 'yes'; then
    echo muted
  else
    pactl get-sink-volume '@DEFAULT_SINK@' | grep -o -E '[0-9]+%' | head -1
  fi
}

pulse_events()
{
  pactl subscribe 2>/dev/null | while read -r event; do
    if ! grep -q "Event 'change'" <<<"$event"; then
      continue
    fi
    case "$event" in
      *sink*) pulse_volume ;;
      *source*) pulse_volume ;;
    esac
  done
}

format_volume()
{
  local volume="$1"

  if echo "$volume" | grep -q 'muted'; then
    volume='muted'
  else
    volume="$(echo "$1" | sed -r 's/[^[:digit:]]//g')"
  fi

  case "$volume" in
    muted) echo "%{F${COLOR_ICON}}${ICON_MUTED} muted" ;;

    [0-9]*)
      max=$((${#ICON_VOLUME[@]} - 1))
      idx="$(echo "${max}*${volume}/100+0.5" | bc -l | sed -r 's/^\./0./' | cut -d. -f1)"

      if ((idx > max)); then
        ((idx = max))
      fi

      if ((volume == 0)); then
        icon="$ICON_MUTED"
      else
        icon="${ICON_VOLUME[idx]}"
        icon="${icon:-${ICON_VOLUME[0]}}"
      fi

      out=''
      out="${out}%{F${COLOR_ICON}}${icon:-${ICON_VOLUME[0]}} "
      out="${out}%{F${COLOR_TEXT}}${volume}% "

      echo "$out"
      ;;

    *) echo "err: No value given" >&2 ;;
  esac
}

main()
{
  case "${1?command}" in
    volup) exec xdotool key XF86AudioRaiseVolume ;;
    voldown) exec xdotool key XF86AudioLowerVolume ;;
    toggle) exec xdotool key XF86AudioMute ;;

    toggle-module)
      echo "[disabled] vol.sh/toggle-module" >&2
      # toggle_module
      ;;

    control)
      case "$(server_name)" in
        alsa) exec xdg-term -n 'vol.sh-alsamixer' alsamixer -c 0 ;;
        pulse) exec pavucontrol ;;
        *) exit 127 ;;
      esac
      ;;

    loop)
      server="$(server_name)"

      trap 'kill -- -$$' EXIT

      while sleep 2; do
        server_name | grep -q "$server" || kill -9 -- -$$ >/dev/null
      done &

      while read -r val; do
        if [ "$val" != "$prev" ]; then
          format_volume "$val"
          prev="$val"
        fi
      done < <(
        "${server}_volume"
        "${server}_events"
      )
      ;;

    *)
      echo "Unknown command: $1" >&2
      exit 1
      ;;
  esac
}

main "$@"
