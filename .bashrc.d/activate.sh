#!/usr/bin/env bash

[[ $- == *i* ]] \
  || [ "$PWD" = "$HOME" ] \
  || [ "$PWD" = "$HOME/.bashrc.d" ] \
  || return

try_activate()
{
  if [ -r activate.sh.sig ] && gpg --verify activate.sh.sig activate.sh 2>/dev/null; then
    source activate.sh
    return 0
  elif [ -r activate.sh ]; then
    : disabled
    printf '[1;31m%s/activate.sh[0m failed verification, source anyway?' "$PWD"
    read -r -p' [Y/n] ' -N1 answer
    printf '\n'
    if [ "${answer,,}" = 'y' ]; then
      source activate.sh
      return 0
    fi
  fi
  return 1
}

try_activate_recursive()
{
  pwd_old="$PWD"
  while [ "$PWD" != '/' ]; do
    try_activate && break
    cd ..
  done
  cd "$pwd_old" || :
}

try_activate_recursive
