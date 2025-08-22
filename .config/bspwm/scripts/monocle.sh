#!/usr/bin/env bash

bspc subscribe all | while read -r e d n l; do
	case "$l" in
		monocle) ;;
		floating) ;;
	esac
	echo "event=%s desktop=%s node=%s layout=%s" "$e" "$d" "$n" "$l" | tee -a /dev/stderr | xargs -I{} notify-send "{}"
done
