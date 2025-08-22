#!/usr/bin/env bash

rofi -markup -e "<span fgcolor='#e95678'>error:</span> $*"
exit 1
