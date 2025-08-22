#!/usr/bin/env bash

set -eo pipefail

if ! command -v cloak >/dev/null; then
  exec rofi -markup -e "<b>error:</b> 'cloak' is not installed."
fi

rofi -e "loading" &
pid=$!

mapfile -t entries < <(cloak list | {
  kill -9 $pid &>/dev/null || :
  tee
} | sed -nr 's|^Account: ([^-]+)-(.+)|🔒 <b>\1</b>\t<i>\2</i>|p' | column -t)

[ ${#entries[@]} -gt 0 ]

printf '%s\n' "${entries[@]}" | rofi -dmenu -p otp -i -markup-rows -format p -no-custom -window-hide-active-window true \
  | tr -s ' ' \
  | cut -d' ' -f2- \
  | tr ' ' '-' \
  | xargs -I{} cloak -q view {} \
  | tr -d '\n' \
  | xsel -i -b
