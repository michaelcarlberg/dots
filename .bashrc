#!/bin/bash

if [[ $- != *i* ]]; then
  return
fi

set -o vi

shopt -s expand_aliases
shopt -s globstar
shopt -s dotglob
shopt -s extglob
shopt -s cdspell
shopt -s autocd
shopt -s histappend
shopt -u force_fignore

stty -ixon # enable custom use of ctrl-s by disabling XON/XOFF flow control

export FIGNORE='.git:.dbus:nvimpager:nv:package-lock.json:~'
export HISTFILE="$XDG_STATE_HOME/bash_history"

if [ "$DISPLAY" = '' ] || [ "$TMUX" != '' ]; then
  __bashrc='activate.sh:bash-preexec.sh:shell.sh'
  for rc in ~/.bashrc.d/*.sh; do
    [[ $__bashrc =~ ${rc##*/} ]] && continue
    if [ -r "$rc" ]; then
      # shellcheck source=/dev/null
      source "$rc"
      __bashrc="$__bashrc:${rc##*/}"
    fi
  done
  unset rc

  . ~/.bashrc.d/shell.sh

  if [ -e "$(readlink -f "$HOME/.ghost")" ]; then
    export HISTFILE=/dev/null
  fi
fi

_prompt_confirmation() {
  # shfmt:ignore
  if read -r ${2+-t $2} -n 1 -s -p "$@" key && [[ "$key" =~ ^(q|||)$ ]]; then
    printf '\nAborted!\n'
    return 1
  fi
}

if [ ! "$DISPLAY" ]; then
  sudo loadkeys ~/.keystrings

  case "$(tty)" in
  /dev/tty1)
    _prompt_confirmation $'\nPress Enter to launch x11...' && "$XDG_CONFIG_HOME/xorg/launch" 1
    return
    ;;
  /dev/tty*) _prompt_confirmation $'\nPress Enter to create tmux session...' || return ;;
  esac
fi

if [ ! "$TMUX" ] && command -v tmux >/dev/null; then
  case "$TERM" in
  dumb) return ;;
  esac
  if read -r session < <(tmux ls -F '#{session_name}' -f '#{==:#{session_attached},0}' 2>/dev/null | grep -E '^default' | tail -1); then
    exec tmux attach-session -t "$session"
  else
    read -r num < <(tmux ls -F '#{session_name}' 2>/dev/null | grep -E '^default' | cut -c9- | sort -n | tail -1)
    exec tmux new-session -s "default-$((++num))"
  fi
fi
