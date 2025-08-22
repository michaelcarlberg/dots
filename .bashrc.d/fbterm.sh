#!/usr/bin/env bash

if [ "$FBTERM" = '1' ]; then
  export TERM=fbterm
fi

if [ "$FBTERM" != '1' ] && [ "$TERM" != 'fbterm' ]; then
  return
fi

export TERM=fbterm-256color
export PAGER=less
