#!/bin/bash

set -e

echo ">>> waiting for device..." >&2

while ! mapfile -t devices < <(xinput list | grep -iE touchpad | grep -oE 'id=\S+' | cut -d= -f2 | sort -n); do
  sleep 1
done

for device in "${devices[@]}"; do
  echo ">>> found device $device"

  if xinput list-props "$device" | grep -i 'tapping enabled' | grep -iv default | grep -qE '1$'; then
    echo ">>> tapping already enabled..."
  else
    echo ">>> enabling tapping..."
    prop="$(xinput list-props "$device" | grep -i 'tapping enabled' | grep -iv default | sed -nr 's/.*\(([0-9]+)\):.*/\1/p')"
    xinput set-prop "$device" "$prop" 1
  fi
done
