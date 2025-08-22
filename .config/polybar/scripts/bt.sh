#!/usr/bin/env bash

green="$(grep -Eo "^ok = (.*)" "${XDG_CONFIG_HOME}/polybar/config.ini" | cut -d= -f2 | tr -d ' ')"
muted="$(grep -Eo "^muted = (.*)" "${XDG_CONFIG_HOME}/polybar/config.ini" | cut -d= -f2 | tr -d ' ')"

read -r icon < <(printf '\ue0b0\n')

device_status()
{
  if bluetooth | grep -q ' = off'; then
    echo "%{F${muted}}${icon} off"
  elif bluetoothctl info | grep -q "Connected: yes"; then
    echo "%{F${green}}${icon} $(bluetoothctl info | sed -nr 's/.+Name: (.+)/\1/p')"
  else
    echo "%{F${green}}${icon} on"
  fi
}

cmd="${1?command}"
shift

case "$cmd" in
  toggle | on | off | 1 | 0)
    state="$cmd"
    state="${cmd//1/on}"
    state="${cmd//0/off}"
    sudo bluetooth "$state"
    ;;

  status)
    device_status
    sudo udevadm monitor -u 2>/dev/null | while read -r evt; do
      if grep -q bluetooth <<<"$evt"; then
        device_status
      fi
    done
    ;;
esac
