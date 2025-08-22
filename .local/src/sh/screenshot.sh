#!/usr/bin/env bash

set -eo pipefail

for p in scrot exiftool feh notify-send; do
  if ! command -v "$p" >/dev/null; then
    echo "Missing required binary '$p'." >&2
    exit 1
  fi
done

declare -a args=()
clipboard='false'
verbose='false'

while [ $# -gt 0 ]; do
  case "$1" in
    --clipboard) clipboard='true' ;;
    -v) verbose='true' ;;
    *) args+=("$1") ;;
  esac
  shift
done
set -- "${args[@]}"

if "$verbose"; then
  notify-send "Capturing screenshot" "$(basename "$filename")"
fi

# shellcheck disable=2016
scrot "$@" -F "$HOME/%F_%H-%M-%S_\$wx\$h.png" -e "echo \$f" -l mode=edge,width=2,color="#e60053" | while read -r filename; do
  exiftool -overwrite_original -all= "$filename"
  feh --info 'echo "\n   %f   \n"' -C ~/.local/share/fonts -e profont/9 --draw-tinted --on-last-slide quit "$filename"

  if "$clipboard"; then
    xclip -selection clipboard -t image/png <"$filename"
  fi

  notify-send "Screenshot captured ${clipboard+& copied}" "$(basename "$filename")"
done
