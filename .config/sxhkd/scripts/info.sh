#!/usr/bin/env bash

exec &>/tmp/.log

ps -o comms= --pid "$PPID" >&2
ps -o comms= --pid "$$" >&2

case "${1:-$LANG}" in
  sv | sv_SE | sv_SE.*) export LC_ALL=sv_SE.UTF-8 ;;
  en | en_US | en_US.*) export LC_ALL=en_US.UTF-8 ;;

  *)
    echo "Invalid locale: $1" >&2
    exit 1
    ;;
esac

notify-send "$(date +%A)" "$(date +%c)"
