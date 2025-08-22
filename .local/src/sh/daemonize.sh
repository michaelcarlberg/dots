#!/usr/bin/env bash

set -e

daemonize()
{
  local cmd="${1##*/}"
  if ! command -v "$cmd" >/dev/null; then
    exit 127
  fi
  pkill -e -x "$cmd" || :
  nohup "$@" &>"$XDG_CACHE_HOME/${cmd}.log" &
  echo "$!" >"$XDG_RUNTIME_DIR/${cmd}.pid"
  pgrep -a -F "$XDG_RUNTIME_DIR/${cmd}.pid"
}

daemonize "$@"
