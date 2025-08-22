#!/usr/bin/env bash

if pactl info &>/dev/null; then
  pactl set-sink-mute '@DEFAULT_SINK@' toggle
else
  read -r cards < <(grep -c -E '^[ ]*[0-9]+' /proc/asound/cards)
  for ((card = cards - 1; card >= 0; --card)); do
    amixer -c "$card" controls | grep -i switch | while read -r mixer; do
      case "${mixer,,}" in
        *"playback switch"*)
          case "$1" in
            mute) amixer -q -c "$card" cset "$mixer" 0 ;;
            unmute) amixer -q -c "$card" cset "$mixer" 1 ;;
            toggle) amixer -q -c "$card" cset "$mixer" toggle ;;
            *)
              echo "command not supported: $1" >&2
              exit 1
              ;;
          esac
          break 3
          ;;
      esac
    done
  done
fi
