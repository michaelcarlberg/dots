#!/bin/bash

if command -v xkblayout-state >/dev/null; then
  printf "%s\n" "$(xkblayout-state print "%s")"
else
  printf "[error: 'xkblayout-state' not found]\n"
fi
