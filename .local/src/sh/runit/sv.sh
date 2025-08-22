#!/usr/bin/env bash
#
# runit service helper
#

set -eo pipefail

source bootstrap.sh

include utils/ansi.sh
include utils/log/banner.sh

bootstrap::finish

usage()
{
  cat >&2 <<-EOF
	usage: ${0##*/} [-uxhv] [-w sec] [cmd=list] [service...]
	EOF
  exit 1
}

# post-pass: eval
LOG_E=$(printf '<rd><b>error</b></rd>\n' | ansi::colorize-tags)
LOG_W=$(printf '<yl><b>warning</b></yl>\n' | ansi::colorize-tags)
LOG_I=$(printf '<gr><b>info</b></gr>\n' | ansi::colorize-tags)

format_pipelog()
{
  log::banner | sed -e 's| |[2;38m▌[22m|' -e "s|$HOME|\~|"
}

main()
{
  [ "$TRACE" = '1' ] && set -x

  # split group of opts:
  #   -avz --foo -ku   =>   -a -v -z --foo -k -u
  #
  # shfmt:ignore
  # shellcheck disable=2046
  set -- $(sed -r ': S; s/(^|[^-a-z0-9])([-][^- ])([^- ]+)/ \2 -\3/g;t S' <<<"$@")

  : "${SVCMD:=$(command -v /usr/bin/sv)}"

  declare -a args=()
  declare -a pargs=()
  declare uid="$UID"
  declare explicitdir='false'

  while [ $# -gt 0 ]; do
    case "$1" in
      -q) exec >/dev/null ;;
      -u)
        if "$explicitdir"; then
          printf "%s: -u and -x are mutually exclusive (ignoring -u)\n" "$LOG_W" >&2
        else
          uid=1000
          explicitdir='true'
          SVDIR="$HOME/.local/sv"
        fi
        ;;
      -x)
        if "$explicitdir"; then
          printf "%s: -u and -x are mutually exclusive (ignoring -x)\n" "$LOG_W" >&2
        else
          uid=1000
          explicitdir='true'
          SVDIR="$HOME/.local/sv.x11"
        fi
        ;;
      -w*)
        if [ "${1:2:1}" != '' ]; then
          args=(-w "${1:2}" "${args[@]}")
        else
          args=(-w "$2" "${args[@]}")
          shift
        fi
        ;;
      -[vh]*) args=("$1" "${args[@]}") ;;
      --) break ;;
      -*) usage ;;
      *) pargs+=("$1") ;;
    esac
    shift
  done

  case "$uid" in
    0)
      : "${ETCSVDIR:=/etc/sv}"
      : "${SVDIR:=/var/service}"
      ;;
    1000)
      : "${ETCSVDIR:=$HOME/.runit/sv}"
      : "${SVDIR:=$HOME/.runit/runsvdir}"
      ;;
  esac

  if [ "$DEBUG" = '1' ]; then
    printf 'SVDIR: %s\n' "$SVDIR"
    printf 'ETCSVDIR: %s\n' "$ETCSVDIR"
    printf '\n'
  fi

  local cmd='ls'

  if [ ${#pargs[@]} -gt 0 ]; then
    cmd="${pargs[0]}"
    pargs=("${pargs[@]:1}")
  fi

  if [ "$DEBUG" = '1' ]; then
    cat >&2 <<-EOF
			+ cmd=$cmd
			+ uid=$uid
			+ args=${args[*]}
			+ pargs=${pargs[*]}
			+ svdir=$SVDIR
			+ etcsvdir=$ETCSVDIR

		EOF
  fi

  case "$cmd" in
    pid)
      for parg in "${pargs[@]}"; do
        local service="${parg##*/}"
        if [ -r "$SVDIR/$service/supervise/pid" ]; then
          cat "$SVDIR/$service/supervise/pid"
        fi
      done
      ;;

    log*)
      [[ ! $* =~ (-u|-xu) ]] && [[ "$uid" = 1000 ]] && set -- -u "${args[@]}" "${pargs[@]}" "$@"
      exec svlogtail "$@"
      ;;

    enable*)
      for parg in "${pargs[@]}"; do
        local service="${parg##*/}"
        if [ -L "$SVDIR/$service" ]; then
          printf "%s: Already enabled: %s\n" "$LOG_W" "$service" >&2
        elif [ ! -d "$ETCSVDIR/$service" ]; then
          printf "%s: Invalid service: %s\n" "$LOG_E" "$service" >&2
          exit 1
        else
          printf "%s: Enabling service: %s\n" "$LOG_I" "$service" >&2
          ln -vnsf "$ETCSVDIR/$service" "$SVDIR/$service" >&2
          while sleep 1; do
            if sv -q check "$SVDIR/$service"; then
              break
            fi
          done
        fi
        sv check "$SVDIR/$service"
      done
      exit
      ;;

    disable*)
      for parg in "${pargs[@]}"; do
        local service="${parg##*/}"
        if [ ! -L "$SVDIR/$service" ]; then
          printf "%s: Invalid service: %s\n" "$LOG_E" "$service" >&2
          exit 1
        else
          printf "%s: Disabling service: %s\n" "$LOG_I" "$service" >&2
          (
            set -x
            sv force-stop "$SVDIR/$service" || :
            sv force-shutdown "$SVDIR/$service" || :
            rm -f "$SVDIR/$service"
          )
        fi
      done
      exit
      ;;

    l | ls | list)
      printf "==> %s <==\n" "$ETCSVDIR"
      for f in "$ETCSVDIR"/*; do
        if [ ! -e "$SVDIR/${f##*/}" ]; then
          echo "${f##*/}"
        fi
      done
      printf "\n==> %s <==\n" "$SVDIR"
      mapfile -t services < <("$SVCMD" s "$SVDIR"/*)
      printf '%s\n' "${services[@]##*/}"
      exit
      ;;

    -h | *-help) usage ;;
  esac

  if [ ${#pargs[@]} -eq 0 ]; then
    usage
  fi

  set -e

  for parg in "${pargs[@]}"; do
    if [ -d "$parg" ]; then
      "$SVCMD" "${args[@]}" "$cmd" "$parg" | sed -r -e "s|$SVDIR/||g" -e "s|$HOME|\~|" -e 's|^[ ]*||'
      # "$SVCMD" ${args[@]}" "$cmd" "$parg" | sed -r -e "s|$SVDIR/||g" | format_pipelog
    elif [ -L "$SVDIR/${parg}" ]; then
      "$SVCMD" "${args[@]}" "$cmd" "$SVDIR/$parg" | sed -r -e "s|$SVDIR/||g" -e "s|$HOME|\~|" -e 's|^[ ]*||'
      # "$SVCMD" "${args[@]}" "$cmd" "$SVDIR/$parg" | sed -r -e "s|$SVDIR/||g" | format_pipelog
    else
      printf "%s: Invalid service: %s\n" "$LOG_E" "$parg" >&2
      exit 1
    fi
  done
}

if [[ $* =~ (re-enable[ ]*)$ ]]; then
  printf "%s: Missing service...\n" "$LOG_E" >&2
  exit 1
elif [[ $* =~ re-enable ]]; then
  "$0" "${*//re-enable/disable}"
  "$0" "${*//re-enable/enable}"
  exit
fi

main "$@"
