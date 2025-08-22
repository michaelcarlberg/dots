#!/usr/bin/env bash

set -e

[ "$DEBUG" = '1' ] && set -x

usage()
{
  cat >&2 <<-EOF

		Usage: ${0##*/} <command>

		Commands:
		  on
		  off
		  toggle
		  status

	EOF
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

GUARD_FILE="$XDG_RUNTIME_DIR/polybar/ghost"
GHOST_FILE="$HOME/.ghost"

ICON_ON=
ICON_OFF=
COLOR_ON='#e60053'
COLOR_OFF='#676a8d'

case "${1?command}" in
  on)
    touch "$GHOST_FILE"
    touch "$GUARD_FILE"
    ;;

  off)
    rm -f "$GHOST_FILE"
    touch "$GUARD_FILE"
    ;;

  toggle)
    if [ -e "$GHOST_FILE" ]; then
      "$0" off
    else
      "$0" on
    fi
    ;;

  status)
    if [ -e "$GHOST_FILE" ]; then
      printf -- '%s\n' "%{F${COLOR_ON} O1}${ICON_ON}%{F-}"
    else
      printf -- '%s\n' "%{F${COLOR_OFF}}${ICON_OFF}%{F-}"
    fi
    ;;

  tail)
    touch "$GUARD_FILE"
    while :; do
      "$0" status
      inotifywait -q -e attrib "$GUARD_FILE" >/dev/null 2>&1
    done
    ;;

  *) usage ;;
esac
