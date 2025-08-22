#!/usr/bin/env bash

git()
{
  if [ "$PWD" = "$HOME" ] && [ "$2" != "clone" ]; then
    /usr/bin/git --git-dir="$HOME/.dots.git" --work-tree="$HOME" "$@"
  else
    /usr/bin/git "$@"
  fi
}
