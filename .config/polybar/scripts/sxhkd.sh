#!/usr/bin/env bash

set -e

[ "$DEBUG" = '1' ] && set -x

exec >/dev/null

usage()
{
  cat >&2 <<-EOF

		Usage: ${0##*/} <command>

		Commands:
		  on
		  off
		  reset

	EOF
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

case "${1?command}" in
  reload)
    (
      polybar-msg action sxhkd-on send "reloading..."
      polybar-msg action sxhkd-off send "reloading..."
      sv -x restart sxhkd
    ) 2>&1 || :
    ;;

  off)
    polybar-msg action '#sxhkd-on.module_hide'
    polybar-msg action '#sxhkd-off.module_show'
    ;;

  on)
    polybar-msg action '#sxhkd-off.module_hide'
    polybar-msg action '#sxhkd-on.module_show'
    ;;

  toggle) bspwm-helper toggle-hotkey-daemon ;;

  init | reset)
    polybar-msg action '#sxhkd-off.module_hide'
    polybar-msg action sxhkd-off send "$(polybar-helper ipc-content module/sxhkd-off)"
    polybar-msg action '#sxhkd-on.module_show'
    polybar-msg action sxhkd-on send "$(polybar-helper ipc-content module/sxhkd-on)"

    "$0" on
    ;;

  *) usage ;;
esac
