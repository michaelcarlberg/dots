#!/usr/bin/env bash

set -e

cd "${0%/*}"

fg="${1:-#222}"
bg="${2:-#000}"

for xbm in **/*.xbm; do
  printf "xsetroot -bg '%s' -fg '%s' -bitmap %s\n" "$bg" "$fg" "$xbm"
  xsetroot -bg "$bg" -fg "$fg" -bitmap "$xbm"
  read -r -p '-- Press Enter to continue...'
done
