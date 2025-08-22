#!/usr/bin/env bash
# shellcheck disable=2164

find-name()
{
  if [ $# -gt 1 ]; then
    find "$1" -iname "*${2}${2:+*}"
  else
    find . -iname "*${1}${1:+*}"
  fi
}

dir-du()
{
  local rootdir="${1:-.}"
  cd "$rootdir" || exit 1
  find . -maxdepth 1 -type d -exec du -sh {} \; | sort -h
}

_find_dir()
{
  cd "$HOME"
  cd "$(fd -t d -L -u --ignore-file "$HOME/.fdignore" | fzf --query="$1")"
}

_find_dir_projs()
{
  if [ $# -eq 1 ]; then
    cd "$HOME/src/$(find -L "$HOME/src" -maxdepth 2 -type d -print | sed -r "s|$HOME/src/||" | tail +2 | fzf -f "$1" | head -1)"
  else
    [ $# -gt 0 ] && set -- -q "$@"
    cd "$HOME/src/$(find -L "$HOME/src" -maxdepth 2 -type d -print | sed -r "s|$HOME/src/||" | tail +2 | fzf "$@")"
  fi
  if [ "$DISPLAY" ]; then
    # HACK: force prompt update
    xdotool key enter
    xdotool key enter
  fi
}

_find_bookmarks()
{
  local file=~/.bookmarks.json
  jq -r -c '.[]|[.name, .path, .tags]|.[0,1],(.[2]|.|@tsv)' "$file" \
    | sed -r '1~3N;N;s/\n/,/g;s/\t/:/g' \
    | while IFS=$'\n,' read -r name path tags; do
      echo -e "name=${name}\tpath=${path}\ttags=${tags//$'\t'/:}"
    done
}

_src()
{
  [ "$2" ] || _find_dir_projs
}

complete -F _src src

command -v sd >/dev/null \
  || alias sd='_find_dir'
command -v src >/dev/null \
  || alias src='_find_dir_projs'

bind -x '"":_find_dir_projs'
bind -x '"":_find_bookmarks'
