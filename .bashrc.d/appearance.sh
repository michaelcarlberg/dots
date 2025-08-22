#!/usr/bin/env bash

case "$TERM" in
  dumb | vterm-*) return ;;
esac

if command -v dircolors >/dev/null; then
  if [ -r "${XDG_CONFIG_HOME}/.dircolors" ]; then
    eval "$(dircolors -b "${XDG_CONFIG_HOME}/.dircolors")"
  elif [ -r "${HOME}/.dircolors" ]; then
    eval "$(dircolors -b "${HOME}/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi

if [ "$DISPLAY" = '' ] && [ -r "$HOME/.bashrc.d/termcolors.tty" ]; then
  export BASE16_SHELL_SET_BACKGROUND='false'
  # shellcheck source=/dev/null
  source "$HOME/.bashrc.d/termcolors.tty"
elif [ "${USE_TERMCOLORS=1}" = '1' ] && [ -r "$HOME/.bashrc.d/termcolors" ]; then
  export BASE16_SHELL_SET_BACKGROUND='true'
  # shellcheck source=/dev/null
  source "$HOME/.bashrc.d/termcolors"
elif [[ "$USE_TERMCOLORS" =~ \.sh$ ]] && [ -r "$USE_TERMCOLORS" ]; then
  # shellcheck source=/dev/null
  source "$USE_TERMCOLORS"
fi

function print-colors
{
  for i in 0 10; do
    seq $((30 + i)) $((38 + i)) | xargs -I{} printf '[30;{}m++'
    printf '[0m\n'
  done
}

function print-colors-all
{
  local -i w=8

  if [ "$1" = '-w' ]; then
    : $((w = $2))
  elif [ $# -eq 1 ]; then
    : $((w = $1))
  fi

  seq 0 256 | while read -r i; do
    if ((i != 256 && i % w == 0)); then
      local -i from="$i"
      local -i to=$((from + w))
      local nl=''
      ((i > 0)) && nl=$'\n'
      printf '[0;2m%s%3d-%-3d[0m  ' "$nl" "$from" "$to"
    fi
    printf -- "[0;48;5;%dm  " "$i"
  done
  printf '[0m\n'
}

function gtk-reload-theme
{
  theme="${1:-$(gsettings get org.gnome.desktop.interface gtk-theme)}"
  gsettings set org.gnome.desktop.interface gtk-theme ''
  sleep 1
  gsettings set org.gnome.desktop.interface gtk-theme "$theme"
}

function figlet
{
  if [ $# -eq 0 ]; then
    find "$XDG_DATA_HOME/figlet-fonts/" -iname "*.[tf]lf" \
      | fzf --height 100% --preview "echo ${FIGLET_TEXT:-foo bar} | figlet -f {}" --preview-window "right:70%:border-sharp:nohidden"
  else
    command -p figlet -d "$XDG_DATA_HOME/figlet-fonts" "$@"
  fi
}

alias base16-theme='ls $HOME/var/repos/base16-shell/scripts/*.sh | grep -v -- -light | fzf --height 100% --bind "focus:execute:source {}" --preview-window "right:70%:border-sharp:nohidden" --preview "cat {} | python -m pygments" || clear'
alias term-reset='(reset; clear; print-colors; echo); source "$HOME/.bashrc.d/appearance.sh"'
