#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Usage: ${0##*/} <window class/name>" >&2
  exit 1
fi

WIN_CLASS="$1"
WIN_ID="$(wmctrl -lx | grep "$WIN_CLASS" | cut -d' ' -f1)"

if [ "$WIN_ID" = "" ]; then
  echo "error: window not found" >&2
  exit 1
fi

STATE=$(xprop -id "$WIN_ID" _NET_WM_STATE | grep -c "_NET_WM_STATE_HIDDEN")

if [ "$STATE" -eq 0 ]; then
  wmctrl -i -r "$WIN_ID" -b add,hidden
else
  wmctrl -i -r "$WIN_ID" -b remove,hidden
fi
