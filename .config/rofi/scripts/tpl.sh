#!/usr/bin/env bash

set -eo pipefail

TPL_FILE="${1:-/tmp/rofi.tpl}"

if ! [ -r "$TPL_FILE" ]; then
  notify-send "Cannot read '${TPL_FILE}'..."
  exit 1
fi

sed -r '1,$=' "$TPL_FILE" \
  | sed -nr '/^[0-9]+/N;s/\n/. /p' \
  | rofi -dmenu -i -markup-rows -format d -no-custom -p template: \
  | xargs -I{} sed -n '{}p' "$TPL_FILE" \
  | while read -r line; do
    echo -n "$line" | tee -a /dev/stderr | xsel -i -b
    printf '\n'
    notify-send "Added to clipboard."
  done || notify-send "Error"
