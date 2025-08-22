#!/usr/bin/env bash

set -e

[ "$DEBUG" = '1' ] && set -x

usage()
{
  cat >&2 <<-EOF

		Usage: ${0##*/} name [opts...] <command>

		Options:
		  -0 <icon-on>
		  -1 <icon-off>

		Commands:
		  on
		  off
		  toggle
		  status

	EOF
  exit 1
}

if [ $# -eq 0 ]; then
  usage
fi

MODE_ID="${1//[^[:alnum:]]/}"
shift

LOCK_GUARD="$XDG_RUNTIME_DIR/polybar/scripts/${MODE_ID}.lock"
STATE_FILE="$XDG_DATA_HOME/polybar/scripts/${MODE_ID}.state"

ICON_ON=on
ICON_OFF=off

COLOR_ON="$(grep -Eo "^err = (.*)" "${XDG_CONFIG_HOME}/polybar/config.ini" | cut -d= -f2 | tr -d ' ')"
COLOR_OFF="$(grep -Eo "^muted = (.*)" "${XDG_CONFIG_HOME}/polybar/config.ini" | cut -d= -f2 | tr -d ' ')"

mkdir -p \
  "$(dirname "$LOCK_GUARD")" \
  "$(dirname "$STATE_FILE")"

while [ "${1:0:1}" = '-' ]; do
  case "$1" in
    -0)
      ICON_OFF="$2"
      shift
      ;;
    -1)
      ICON_ON="$2"
      shift
      ;;
  esac
  shift
done

case "${1?command}" in
  on)
    touch "$STATE_FILE"
    touch "$LOCK_GUARD"
    ;;

  off)
    rm -f "$STATE_FILE"
    touch "$LOCK_GUARD"

    ;;

  toggle)
    if [ -e "$STATE_FILE" ]; then
      "$0" "$MODE_ID" -0 "$ICON_OFF" -1 "$ICON_ON" off
    else
      "$0" "$MODE_ID" -0 "$ICON_OFF" -1 "$ICON_ON" on
    fi
    ;;

  status)
    if [ -e "$STATE_FILE" ]; then
      printf -- '%s\n' "%{F${COLOR_ON}}${ICON_ON}%{F-}"
    else
      printf -- '%s\n' "%{F${COLOR_OFF}}${ICON_OFF}%{F-}"
    fi
    ;;

  tail)
    touch "$LOCK_GUARD"
    while :; do
      "$0" "$MODE_ID" -0 "$ICON_OFF" -1 "$ICON_ON" status
      inotifywait -q -e attrib "$LOCK_GUARD" >/dev/null 2>&1
    done
    ;;

  *) usage ;;
esac
