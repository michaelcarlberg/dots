#!/usr/bin/env bash

if pgrep -x dunst; then
  pkill -e -x dunst
fi

/usr/bin/notify-send -t "${1:-1000}" 'title that is very very long lorem ipsum dolor' 'foo bar baz'
/usr/bin/notify-send -t "${1:-1000}" -i /usr/share/icons/Adwaita/scalable/mimetypes/x-office-document.svg -h 'string:wired-tag:icon' 'title' 'foo bar baz'
/usr/bin/notify-send -a progress -t "${1:-1000}" -h 'string:wired-tag:brightness' -h 'int:value:40' 'progress'
/usr/bin/notify-send -u low -t "${1:-1000}" 'low: title' 'foo bar baz'
/usr/bin/notify-send -u normal -t "${1:-1000}" 'normal: title' 'foo bar baz'
/usr/bin/notify-send -u critical -t "${1:-1000}" 'critical: title' 'foo bar baz'
/usr/bin/notify-send -t "${1:-1000}" 'timeout: title' 'start foo bar baz foo bar baz foo bar end'
