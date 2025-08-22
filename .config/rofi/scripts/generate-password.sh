#!/usr/bin/env bash

set -euo pipefail

declare -i length=32
declare -i count=3

case "${1:-}" in
  -l | --length) length="$2" ;;
  -c | --count) count="$2" ;;
esac

function notify
{
  if [ -t 0 ]; then
    echo "$1" >&2
  else
    notify-send "rofi/${0##*/}" "$1"
  fi
}

function generate()
{
  printf '%s\n' {A..Z} {a..z} {0..9} "$(grep -o . <<<'.=/#*_-!?%')" \
    | sort -R \
    | head -"$1" \
    | xargs -I{} printf '%s' {}
  printf '\n'
}

command -v keepassxc-cli >/dev/null && function generate
{
  keepassxc-cli generate -l -U -n -L "$1" -c '.=/#*_- !?'
}

for ((i = 0; i < count; i++)); do
  generate "$length"
done | rofi -dmenu -i -markup-rows -format p -no-custom \
  | tr -d '\n' \
  | tee -a /dev/stderr \
  | xsel -i -b
printf '\n'
notify "Added to clipboard."
