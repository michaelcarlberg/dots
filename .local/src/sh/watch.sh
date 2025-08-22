#!/bin/bash
#
# Usage: $0 [args...] file notifyfn
#

main()
{
  local -F fn
  local args

  fn="${*:$#}"
  args="${*:1:$(($# - 1))}"

  echo "+ inotifywait $args" >&2
  while :; do
    inotifywait -e close_write -e delete_self "$args"
    eval "$fn"
  done
}

main "$@"
