#!/bin/bash

set -e

if [ "$1" = '-l' ]; then
  ip="$(ip addr | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v 127.0.0.1 | grep -vE '\.255$')"
else
  ip="$(curl -s ipinfo.io | jq -r .ip)"
fi

echo "${ip:-Not connected}"
