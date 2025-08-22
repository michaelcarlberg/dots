#!/usr/bin/env bash
# shellcheck disable=2034

PROMPT_LONG=20
PROMPT_MAX=95
PROMPT_AT=@

# usage: text [length of printed chars]
# __prompt_right_align()
# {
#   local text="$1"
#   local pos=$COLUMNS
#
#   if [ $# -eq 2 ]; then
#     ((pos -= $2))
#   else
#     len=$(echo -n "$text" | sed -r 's/\\\[[^]]+\\\]//' | wc -m)
#     ((pos -= len))
#   fi
#
#   printf '\[\e[s\e[\r\e[%dC\]%s\[\e[u\]' "$pos" "$text"
# }

__prompt()
{
  local exitcode=$?

  exitcode=${exitcode#0}
  exitcode=${exitcode#130}

  local ps_reset='\[\e[0m\]'
  local ps_user='\[\e[0;38;5;105m\]\u'
  local ps_at='\[\e[0;38;5;63m\] @ '
  local ps_host='\[\e[0;38;5;105m\]\H'
  local ps_path='\[\e[0;38;5;63m\]\w'
  local ps_time='\[\e[0;38;5;105m\]\t'
  local ps_symbol_line1='' # '\[\e[0;38;5;63m\]╔═'
  local ps_symbol_line2='' # '\[\e[0;38;5;63m\]╚═'
  local ps_symbol_end=''   # '\[\e[0;31m\]λ' # ϟ Ω
  local ps_git_branch
  local ps_virtualenv
  local ps_exitcode

  case "$exitcode" in
    0 | 130) ;;
    *) ps_exitcode="\[\e[0;31m\] $exitcode " ;;
  esac

  if [ "$USER" = "jaagr" ]; then
    unset ps_user
    unset ps_at
  fi
  if [ "$HOSTNAME" = "devbox" ] || [ "$HOSTNAME" = "phax" ]; then
    unset ps_host
    unset ps_at
  fi

  if [ "$PWD" != "$HOME" ] && ps_git_branch="$(git branch --show-current 2>/dev/null)"; then
    ps_git_branch="\[\e[0;38;5;103m\]git\[\e[0;38;5;60m\]:${ps_git_branch}"
  fi
  if [ "${VIRTUAL_ENV##*/}" != "" ]; then
    ps_virtualenv="\[\e[0;38;5;103m\]py\[\e[0;38;5;60m\]:${VIRTUAL_ENV##*/}"
  fi
  if [ "$PROMPT_EXTRA" ]; then
    ps_promptextra="$PROMPT_EXTRA"
  fi

  if ((COLUMNS < 50)); then
    unset ps_user
    unset ps_host
  fi
  if ((COLUMNS < 75)); then
    unset ps_git_branch
  fi
  if ((COLUMNS < 100)); then
    unset ps_symbol_line1
    unset ps_symbol_line2
  fi

  local -a ps=()

  # ps+=("$ps_symbol_line1")
  ps+=("$ps_path")
  ps+=("$ps_exitcode")
  ps+=("$ps_git_branch")
  ps+=("$ps_virtualenv")
  ps+=("$ps_promptextra")
  ps+=("\n")
  # ps+=("$ps_symbol_line2")
  ps+=("$ps_user$ps_at$ps_host")
  # ps+=("$ps_symbol_end")

  for p in "${!ps[@]}"; do
    [ "$(echo "${ps[p]// /}" | sed -r 's/\\\[[^]]+]//g')" ] || unset -v 'ps[p]'
  done

  PS1=" ${ps[*]// /}${ps_reset} "
}

PROMPT_COMMAND="__prompt"
# PS1=" \[\e[38;5;63m\]\w\[\e[0m\]\n \[\e[38;5;60m\]\h \[\e[31m\]λ\[\e[0m\] "
