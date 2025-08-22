#!/usr/bin/env bash

# if [ "$DEBUG" = '1' ]; then
#   set -x
# fi

declare -a fzf_opts=(-d 35% -m --no-preview --no-border)
declare -a entries
declare entry
declare type

filter_paths()
{
  echo "$*" | while IFS=' ' read -r word; do
    if [ -f "$word" ]; then
      echo "$word"
    fi
  done
}

filter_urls()
{
  echo "$*" | grep -oE '(https?|ftp|file):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'
  echo "$*" | grep -oE '(http?s://)?www\.[a-zA-Z](-?[a-zA-Z0-9])+\.[a-zA-Z]{2,}(/\S+)*' | grep -vE '^https?://' | sed 's/^\(.*\)$/http:\/\/\1/'
  echo "$*" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?(/\S+)*' | sed 's/^\(.*\)$/http:\/\/\1/'
  echo "$*" | grep -oE '(ssh://)?git@\S*' | sed 's/:/\//g' | sed 's/^\(ssh\/\/\/\)\{0,1\}git@\(.*\)$/https:\/\/\2/'
  echo "$*" | grep -oE "['\"]([_A-Za-z0-9-]*/[_.A-Za-z0-9-]*)['\"]" | sed "s/['\"]//g" | sed 's#.#https://github.com/&#'
}

content="$(tmux capture-pane -J -p)"

mapfile -t entries < <((
  filter_paths "$content" | sed 's/^/file:/'
  filter_urls "$content" | sed 's/^/ www:/'
) | sort -u | grep -vE '^$')

if [ ${#entries[@]} -eq 0 ]; then
  printf '[1;33m No matching entries found \n'
  exit 0
fi

open_url()
{
  local url="$1"
  tmux display-message "#[fg=green,bold] Opening URL: $url"
  nohup xdg-open "$url" &>/dev/null
}

open_path()
{
  local filename="$1"
  tmux display-message "#[fg=green,bold] Opening file: $filename"
  case "$(tmux display-message -p '#{pane_current_command}')" in
    sh | bash | fish | zsh)
      tmux send-keys C-c
      sleep .1
      tmux send-keys "vim $filename"
      sleep .1
      tmux send-keys C-m
      ;;

    *) exec xdg-term "nvim $filename" ;;
  esac
}

fzf-tmux <<<"$(printf '%s\n' "${entries[@]}" | sed -r 's/([^:]+):/[33m\1[0m   /')" | while IFS=$'\n ' read -r type entry; do
  if [ "$entry" = '' ]; then
    exit 1
  fi

  type="${type//[^[:alnum:]]/}"

  case "$type" in
    www) open_url "$entry" ;;
    file) open_path "$entry" ;;

    *)
      printf '[1;30;41m Unknown type: %s \n' "$type"
      tmux display-message "#[bg=red,fg=black,bold] Unknown type: $type "
      exit 1
      ;;
  esac
done
