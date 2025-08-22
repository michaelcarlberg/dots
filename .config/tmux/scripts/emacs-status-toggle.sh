#!/usr/bin/env sh

set -x

tmux display -p '#{window_zoomed_flag}:#{pane_current_command}'

if tmux list-panes -F '#{window_zoomed_flag}:#{pane_current_command}' -f '#{||:#{window_zoomed_flag},#{&&:#{pane_at_bottom},#{&&:#{pane_at_left},#{pane_at_right}}}}' | grep -qE '^(1|[0-9]:emacs)$'; then
  tmux set status off
else
  tmux set status on
fi
