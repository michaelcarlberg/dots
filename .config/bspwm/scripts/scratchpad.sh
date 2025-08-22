#!/usr/bin/env bash

set -eo pipefail

[ "$DEBUG" = '1' ] && set -x

# declare PID_FILE="${XDG_RUNTIME_DIR}/scratchpad.pid"
# declare TOGGLE_SCRIPT="${XDG_CONFIG_HOME}/bspwm/scripts/toggle-window.sh"
declare WM_CLASS='scratchpad'
declare -a FRAME_PARAMETERS=('(sticky . t)'
  "(name . \"${WM_CLASS}\")"
  '(width . 200)'
  '(height . 30)'
  '(floating . t)'
  '(inhibit-startup-echo-area-message . t)'
  '(persp-mode . nil)')

# scratchpad_err()
# {
#   if [ -t 0 ]; then
#     echo "$*" >&2
#   else
#     notify-send "scratchpad" "$*"
#   fi
#   return 1
# }

scratchpad_create()
{
  if ! xdotool search --classname "$WM_CLASS"; then
    # bspc rule -a "Emacs:${WM_CLASS}" -o state=floating hidden=on sticky=on
    bspc rule -a "*:${WM_CLASS}" -o state=floating hidden=on sticky=on follow=on focus=on
    # TMUX=1 st -n "$WM_CLASS" -g 150x20 -f "ProFont NF:size=9.0"
    st -n "$WM_CLASS" -g 150x20+0+0 -f "ProFont NF:size=9.0" -- /bin/tmux new-session -s scratchpad

    # shfmt:ignore-line
    # (
    #   set -x
    #   /bin/emacsclient -c -F "(${FRAME_PARAMETERS[*]})" -e '(progn (+workspace-delete (+workspace-current-name)) (+workspace-switch "main") (doom/switch-to-scratch-buffer))'
    # ) &

    # /bin/emacsclient -c -F "(${FRAME_PARAMETERS[*]})" -e '(progn (doom/switch-to-project-scratch-buffer) (+workspace/switch-to +workspaces-main))' &

    # {{{
    # read -r hidden layer state < <(bspc query -T -n "$window" | jq -r '.hidden,.client.layer,.client.state')
    #
    # case "$hidden" in
    #   # true) bspc node "$window" -g hidden -f ;;
    #   # false) bspc node "$window" -f ;;
    #   *) ;;
    # esac
    #
    # case "$layer" in
    #   above) ;;
    #   below | normal) bspc node "$window" -l above ;;
    # esac
    #
    # case "$state" in
    #   floating) ;;
    #   tiled | pseudo_tiled | fullscreen) bspc node "$window" -t floating ;;
    # esac
    #
    # bspc node "$window" -m "$(bspc query -M -m)"
    #
    # local -i x y w2 h2
    # read -r x y < <(bspc query -T -n "$window" | jq -r '.client.floatingRectangle|[.x,.y]|@tsv')
    # read -r w2 h2 < <(bspc query -T -m | jq -r '.rectangle|[.width/2,.height/2]|@tsv')
    # read -r mw mh < <(bspc query -T -m "$(bspc query -M -m)" | jq -r '.rectangle|[.width/4,.height/4]|@tsv')
    #
    # # notify-send "$x $y $((x + mw)) $((y + mh))"
    # # bspc node "$window" -v $(((x - mw) * -1)) -$(((y - mh) * -1)) #
    # }}}

    xdotool search --sync --classname "$WM_CLASS"
  fi
}

scratchpad_toggle()
{
  local monitor
  local window

  if ! read -r window < <(xdotool search --classname "$WM_CLASS"); then
    notify-send "scratchpad" "error: window not found"
    exit 1
  fi

  read -r monitor < <(bspc query -M -m --names)

  if bspc query -T -n "$window" | jq .hidden | grep -q false; then
    bspc node "$window" -g hidden=on
  else
    bspc node "$window" -m "$monitor" || :
    bspc node "$window" -g hidden=off
    bspc node "$window" -f || :
    bspc node "$window" -t floating || :
    bspc node "$window" -l above || :

    bspc subscribe | while read -r; do
      if bspc query -N -n | xargs printf '%d\n' | grep -q "$window"; then
        xdotool windowmove "$window" x 0
        ~/src/sh/centerwin.sh -x "$window" "${monitor:-$(bspc query -M -m --names)}"
        unset monitor
      else
        bspc node "$window" -g hidden=on
        break
      fi
    done
  fi
}

case "${1:-default}" in
  create) scratchpad_create ;;
  toggle) scratchpad_toggle ;;

  default)
    scratchpad_create
    scratchpad_toggle
    ;;

  *)
    printf "Unknown command '%s'\n" "$1" >&2
    exit 1
    ;;
esac
