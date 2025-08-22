#!/usr/bin/env bash

unalias dots 2>/dev/null || :

function dots
{
  local -a args=()

  if [ $# -eq 0 ]; then
    args=(status .)
  elif command -v "$1" | grep -qE '^alias'; then
    mapfile -d\  -t args < <(command -v "$1" | sed -nr -e "s/.+='([^']+)'\$/\1/p" | tr '\n' ' ')
    shift
  fi

  args+=("${*// /\\\ }")

  if [[ "${args[*]:0:3}" =~ (^git add -A;?$) ]]; then
    args=(git add -u\; "${args[@]:3}")
  fi

  for i in "${!args[@]}"; do
    if [ "${args[i]}" == '--' ]; then
      break
    elif [ -f "${args[i]}" ]; then
      file="$(readlink -f "${args[i]}" | sed -nr "s|$(dots rev-parse --show-toplevel)/(.+)|\1|p")"
      # dots ls-files | grep "$file"
      # args[i]="$(readlink -f ~/.local/bin/cloak | sed -nr "s|$(dots rev-parse --show-toplevel)/(.+)|\1|p")"
      args[i]="$file"
    fi
  done

  set -- "${args[@]}"

  if [ "$1" = "git" ]; then
    shift
  fi

  # shfmt:ignore
  # shellcheck disable=2317
  git() { /usr/bin/git --git-dir="$HOME/.dots.git" --work-tree="$HOME" "$@"; }

  eval "git $*"
  ret=$?
  unset git

  return "$ret"
}

alias dots-update-submodules='dots submodule update --init --recursive && dots submodule status --recursive'

if [ -r /usr/share/bash-completion/completions/git ]; then
  # shellcheck source=/dev/null
  . /usr/share/bash-completion/completions/git
  ___git_complete dots __git_main
fi
