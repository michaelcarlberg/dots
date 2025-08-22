#!/usr/bin/env bash

source ~/.bashrc.d/bash-preexec.sh

declare -gx __loaded=''

on_cwd_changed()
{
  ! [ -r activate.sh ] \
    || [ "$PWD" = "$OLDPWD" ] \
    || [ "$PWD" = "$HOME" ] \
    || [ "$PWD" = "$HOME/.bashrc.d" ] && return

  [[ $__loaded =~ $PWD/activate.sh ]] && return

  if [ -x activate.sh ]; then
    ./activate.sh
  else
    source activate.sh || :
  fi

  __loaded="$PWD/activate.sh:$__loaded"
}

precmd_functions+=(on_cwd_changed)

__bp_install
