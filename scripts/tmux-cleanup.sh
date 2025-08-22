#!/bin/bash

tmux list-sessions | grep '^default' | grep -v attached | cut -d: -f1 | while read -r session; do
  printf 'Terminating session "%s"\n' "$session"
  tmux kill-session -t "$session"
done
