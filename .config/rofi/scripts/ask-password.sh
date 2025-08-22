#!/usr/bin/env bash

set -eo pipefail

rofi -dmenu -p "Enter passphrase:" -password \
  "${*+-mesg}" "${*+$*}" \
  -theme-str "listview { lines: 0; margin: 0; }" \
  -theme-str 'textbox { padding: 8px 10px; background-color: transparent; }' \
  -theme-str 'message { padding: 0; margin: 4px 0 0; background-color: transparent; }'
