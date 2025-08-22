#!/bin/bash

polybar-msg action "#sxhkd-on.module_show" >/dev/null || :

pid=$(polybar-helper monitor-pid | head -1)
red='#e60053'
str="%{F${red}}  "

((N = 90, O = 0, i = 0, j = 3))

#
# Go push the mpd controls
#
# shellcheck disable=2031
seq "$N" | while read -r i; do
  : $((O += (j * (i >= (N / 2) ? -1 : 1))))
  : $((O += ((i * 2) / (i >= (N / 2) ? -1 : 1)) / 10 + 4))
  polybar-msg -p "$pid" action sxhkd-on send "$str%{O$O}" &>/dev/null
  sleep 0.01
done

declare -a icons=()

icons+=($'\ue203')
icons+=($'\ue270')
icons+=($'\ue271')
icons+=($'\ue272')
icons+=($'\ue273')
icons+=($'\ue274')
icons+=($'\ue275')
icons+=($'\ue276')
icons+=($'\ue058')
icons+=($'\ue203')
icons+=($'\ue270')
icons+=($'\ue271')
icons+=($'\ue272')
icons+=($'\ue273')
icons+=($'\ue058')
icons+=('')
icons+=($'\ue058')
icons+=('')
icons+=($'\ue058')
icons+=('')
icons+=($'\ue058')
icons+=('')
icons+=($'\ue058')
icons+=('')
icons+=($'\ue058')
icons+=('')
icons+=($'\ue058')
icons+=('')
icons+=($'\ue058')
icons+=('')

#
# And whine a bit about the silence...
#
for icon in "${!icons[@]}"; do
  if [ ! "${icons[icon]}" ] || [ ! "${icons[icon - 1]}" ]; then
    sleep 0.2
  else
    ((O = 1 + RANDOM % 5))
    sleep 0.05
  fi

  polybar-msg -p "$pid" action sxhkd-on send "${str}%{O$((O - 8))}%{F-}${icons[icon]:-  }" &>/dev/null
done
