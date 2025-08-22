#!/usr/bin/env bash

adb-uninstall()
{
  adb shell pm list packages | cut -d: -f2 | fzf --marker x --header "Select package to uninstall" | while read -r pkg; do
    echo "Uninstalling $pkg" >&2
    adb shell pm uninstall --user 0 "$pkg"
  done
}
