#!/usr/bin/env bash
# shellcheck disable=1091

_bind_complete()
{
  complete -o bashdefault -o default -o nospace -F "$2" "$1" \
    || complete -o default -o nospace -F "$2" "$1"
}

if [ -r /usr/share/bash-completion/bash_completion ]; then
  # shellcheck source=/dev/null
  . /usr/share/bash-completion/bash_completion
elif [ -r /etc/bash_completion ]; then
  # shellcheck source=/dev/null
  . /etc/bash_completion
fi

if [ -d ~/.local/share/bash-completion/completions ]; then
  for compfile in ~/.local/share/bash-completion/completions/*; do
    if [ -r "$compfile" ]; then
      # shellcheck source=/dev/null
      . "$compfile"
    fi
  done
  unset compfile

  # if [ -r ~/.local/share/bash-completion/complete_alias ]; then
  #   . ~/.local/share/bash-completion/complete_alias
  # fi
fi

# git {{{

if [ -r /usr/share/bash-completion/completions/git ]; then
  # shellcheck source=/dev/null
  . /usr/share/bash-completion/completions/git

  __git_complete g _git
  __git_complete ga _git_add
  __git_complete grm _git_rm
  __git_complete gd _git_diff
  __git_complete gco _git_checkout
  __git_complete gst _git_status
  __git_complete giu _git_add
  __git_complete gcm _git_commit
  __git_complete gbl _git_branch
  __git_complete gbL _git_branch
  __git_complete gbx _git_branch
  __git_complete gbX _git_branch
  __git_complete gia _git_add
  __git_complete gcf _git_commit
  __git_complete gcF _git_commit
fi

# }}}
# pyenv {{{

if [ -r "$PYENV_ROOT/completions/pyenv.bash" ]; then
  # shellcheck source=/dev/null
  . "$PYENV_ROOT/completions/pyenv.bash"
fi

# }}}
# electrum {{{

if command -v electrum >/dev/null; then
  __electrum_complete()
  {
    __electrum_cmds="${XDG_DATA_HOME}/electrum/commands"

    if ! [ -f "$__electrum_cmds" ]; then
      mkdir -p "$(dirname "$__electrum_cmds")"
      electrum commands | tr ' ' '\n' >"$__electrum_cmds"
    fi

    local prev="${COMP_WORDS[COMP_CWORD - 1]}"
    local current="${COMP_WORDS[COMP_CWORD]}"
    if [ "$prev" ] && grep -qE "^${prev}" "$__electrum_cmds"; then
      return
    fi

    mapfile -t COMPREPLY < <(compgen -W "$(cat "$__electrum_cmds")" -- "$current")
  }

  _bind_complete electrum __electrum_complete
fi

# }}}
# pip {{{

if command -v pip >/dev/null; then
  _pip_completion()
  {
    COMPREPLY=("$(COMP_WORDS="${COMP_WORDS[*]}" \
      COMP_CWORD="$COMP_CWORD" \
      PIP_AUTO_COMPLETE=1 "$1" 2>/dev/null)")
  }

  complete -o default -F _pip_completion pip
fi

# }}}

_generic_compfunc()
{
  local cur prev
  local -n opts="_${1}_opts"

  if [ "$opts" = '' ]; then
    mapfile -t opts < <("$1" -h 2>&1 | grep -viE '^(usage.+)?$' | grep -oE '^[ ]*\S+' | tr '\n' ' ')
  fi

  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case $prev in
    '-F' | '--file')
      local IFS=$'\n'
      compopt -o filenames
      COMPREPLY=("$(compgen -f -- "$cur")")
      return 0
      ;;
    '-f' | '--facility')
      COMPREPLY=("$(compgen -W "kern user mail daemon auth syslog lpr news" -- "$cur")")
      return 0
      ;;
    '-l' | '--level' | '-n' | '--console-level')
      COMPREPLY=("$(compgen -W "emerg alert crit err warn notice info debug" -- "$cur")")
      return 0
      ;;
    '-s' | '--buffer-size')
      COMPREPLY=("$(compgen -W "size" -- "$cur")")
      return 0
      ;;
    '--time-format')
      COMPREPLY=("$(compgen -W "delta reltime ctime notime iso" -- "$cur")")
      return 0
      ;;
    '-h' | '--help' | '-V' | '--version')
      return 0
      ;;
  esac

  # shfmt:ignore
  # shellcheck disable=2086
  case "$prev" in
    '' | "$1") mapfile -t COMPREPLY < <(compgen -W "${opts[*]}" -- "$cur") ;;
  esac
}

_volumectl_opts='mute + -'
complete -o nospace -F _generic_compfunc volumectl

_xdotool_opts='
  getactivewindow
  getwindowfocus
  getwindowname
  getwindowclassname
  getwindowpid
  getwindowgeometry
  getdisplaygeometry
  search
  selectwindow
  help
  version
  behave
  behave_screen_edge
  click
  getmouselocation
  key
  keydown
  keyup
  mousedown
  mousemove
  mousemove_relative
  mouseup
  set_window
  type
  windowactivate
  windowfocus
  windowkill
  windowclose
  windowquit
  windowmap
  windowminimize
  windowmove
  windowraise
  windowreparent
  windowsize
  windowstate
  windowunmap
  set_num_desktops
  get_num_desktops
  set_desktop
  get_desktop
  set_desktop_for_window
  get_desktop_for_window
  get_desktop_viewport
  set_desktop_viewport
  exec
  sleep'
complete -o nospace -F _generic_compfunc xdotool
