#!/usr/bin/env bash

if [[ $* =~ -u ]]; then
  LOGDIR="$HOME/.local/var/log"
  shift
else
  LOGDIR=/var/log/socklog
fi

if [ $# -eq 0 ]; then
  (
    tail -n5 "$LOGDIR"/*/current
    tail -Fq -n0 "$LOGDIR"/*/current | uniq
  ) | sed -r "s|==> $LOGDIR/.+ <==|[32;1m&[0m|"
else
  for log; do
    case "$log" in
      -*)
        echo "${0##*/} [-u] [filter...]" >&2
        exit 1
        ;;
    esac
    if [ -d "$LOGDIR/$log" ]; then
      old="$old $LOGDIR/$log/*.[us]"
      cur="$cur $LOGDIR/$log/current"
    else
      echo "no logs for $log" 1>&2
      exit 1
    fi
  done
  # shellcheck disable=2086
  if command -v spc >/dev/null && [ -e "$XDG_CONFIG_HOME"/supercat/svlogtail ]; then
    # shfmt:ignore-begin
    (
      cat $old $cur | tail -100 | sort
      tail -Fq -n0 $cur
    ) | spc -c "$XDG_CONFIG_HOME"/supercat/svlogtail
    # shfmt:ignore-end
  else
    # shfmt:ignore-begin
    cat $old $cur | tail -100 | sort
    tail -Fq -n0 $cur
    # shfmt:ignore-end
  fi
fi
