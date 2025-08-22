#!/bin/bash

set -xe

# echo ">>> waiting for device..." >&2
#
# while ! mapfile -t devices < <(xinput list | grep -iE '\[.+keyboard' | grep -i varmilo | grep -oE 'id=\S+' | cut -d= -f2 | sort -n); do
#   sleep 1
# done
#
# for device in "${devices[@]}"; do
#   if [ $# -gt 1 ] && [ "$device" != "$1" ]; then
#     echo ">>> skipping device $device"
#     continue
#   fi
#
#   echo ">>> found device $device"
#
#   # shfmt:ignore-begin
#   setxkbmap ${device:+-device "$device"} -option "" "us"
#   setxkbmap ${device:+-device "$device"} -config "$XDG_CONFIG_HOME/xorg/xkbmap.config"
#   # shfmt:ignore-end
# done

setxkbmap -option "" -config "$XDG_CONFIG_HOME/xorg/xkbmap.config"
# xmodmap "$XDG_CONFIG_HOME/xorg/xmodmap"

if pgrep -x xcape >/dev/null; then
  pkill -9 -e -x xcape
fi

ALT_R='#108'
CAPS_LOCK='#66'

xcape -e "${CAPS_LOCK}=Escape;${ALT_R}=Menu" -t 500
# xcape -e "Super_L=Escape;Alt_R=Menu" -t 500

xset r rate 210 40
numlockx
