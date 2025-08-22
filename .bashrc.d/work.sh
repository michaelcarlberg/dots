#!/usr/bin/env bash

alias work-connect-rdp='xfreerdp3 /v:127.0.0.1:33895 /u:SUKMMicCar /d:PERSONAL /dynamic-resolution'
alias mobilityguard-toggle='~/scripts/toggle-window.sh com-mobilityguard-client-cmdclient-MGJavaClientMain'

gowork()
{
  local dir="${1:-sk}"
  cd "$HOME/work/$dir" || echo "No such directory: $HOME/work/$dir"
}

_gowork_completions()
{
  # shfmt:ignore
  # shellcheck disable=2207
  COMPREPLY=($(compgen -W "$(find "$HOME/work" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')" -- "${COMP_WORDS[1]}"))
}

complete -F _gowork_completions gowork

proj()
{
  cd ~/work/sk || return 1

  if [ $# -eq 1 ]; then
    cd "$(find . -maxdepth 1 -type d | cut -c3- | grep -vE "^$" | fzf -f "$1" | head -1)" || return 1
  else
    cd "$(find . -maxdepth 1 -type d | cut -c3- | grep -vE "^$" | fzf)" || return 1
  fi
}

_proj_completions()
{
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local dirs
  dirs=$(find "$HOME/work/sk" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null)
  # shfmt:ignore
  # shellcheck disable=2207
  COMPREPLY=($(compgen -W "$dirs" -- "$cur"))
}
complete -F _proj_completions proj
