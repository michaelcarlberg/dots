#!/usr/bin/bash
# shellcheck disable=1003

set -eo pipefail

source bootstrap.sh

include utils/ansi.sh
include utils/math.sh
include utils/str.sh

bootstrap::finish

declare -i MAX_WIDTH=120

usage()
{
  cat >&2 <<-EOF
	Usage: ${0##*/} [-auvxm] [cmd=list] -- [-hltuvV]

	  -a  show all services
	  -u  show user services
	  -x  show x11 services
	  -m  mini mode
	  -v  verbose

	EOF
  exit 1
}

cmd_vsv()
{
  if [[ $* =~ -h|--help ]]; then
    vsv -c "${ANSI_COLORS:-auto}" "$@" | sed -nr -e '/^USAGE/,$p' -e $'$i\n'
    exit 1
  else
    vsv -c "${ANSI_COLORS:-auto}" "$@" | tail -n+2
  fi
}

main()
{
  [ "$TRACE" = '1' ] && set -x

  # split group of opts:
  #   -avz --foo -ku   =>   -a -v -z --foo -k -u
  #
  # shfmt:ignore
  # shellcheck disable=2046
  set -- $(sed -r ': S; s/[^-]([-][^- ])([^- ]+)/ \1 -\2/g;t S' <<<"$@")

  local -a opts=()
  local -a vsv_opts=()
  local cmd='list'
  local opt

  for opt; do
    case "$opt" in
      -h | --help) usage ;;

      -a | -u | -v | -x | -m)
        opts+=("$opt")
        shift
        ;;

      --)
        shift
        vsv_opts=("$@")
        for vsv_opt in "${vsv_opts[@]}"; do
          case "$vsv_opt" in
            -[hltuvV] | --log | --tree | --user | --verbose | --version) ;;

            *)
              echo "Invalid vsv option: ${vsv_opt}" >&2
              exit 1
              ;;
          esac
        done
        shift $#
        break 2
        ;;

      [a-z]*) cmd="$opt" ;;

      *)
        echo "Invalid option: '${opt}'" >&2
        usage
        ;;
    esac
  done

  [ "$DEBUG" = '1' ] && printf 'cmd = %s\n' "$cmd"

  : "${ETCSVDIR:=/etc/sv}"
  : "${SVDIR:=/var/service}"
  : "${SVDIR_X11:=${SVDIR}.x11}"

  if [[ ${opts[*]} =~ (-x|--x11) ]]; then
    SVDIR="$SVDIR_X11"
    unset SVDIR_X11
  fi

  if [ ! -d "$SVDIR_X11" ] || [ "$SVDIR" = "$SVDIR_X11" ]; then
    unset SVDIR_X11
  fi

  # align_center()
  # {
  #   [ "$1" ] || set -- '<not|set>' "$2" "$3"
  #   : $((pad = ($2 - ${#1}) / 2))
  #   : $((pad = pad < 0 ? 0 : pad))
  #   printf -- " %*s||%s||%*s $3" "$pad" "" "$1" "$pad" ""
  # }
  #
  # (
  #   ansi::draw-line 120 | xargs printf '[0;38;5;19m%s[0m\n'
  #   (
  #     echo -ne "[1;2m$(align_center "ETCSVDIR" 30)[22m"
  #     align_center "SVDIR" 30
  #     align_center "SVDIR_X11" 30 $'\n'
  #
  #     align_center "${ETCSVDIR//$HOME/\~}" 30
  #     align_center "${SVDIR//$HOME/\~}" 30
  #     align_center "${SVDIR_X11//$HOME/\~}" 30 $'\n'
  #   ) | sed -e 's/ /─/g' -e 's/^/[0;38;5;61m/' -e 's/$/[0m/' -e 's/|/ /g'
  #   ansi::draw-line 120 | xargs printf '[0;38;5;19m%s[0m\n'
  # )

  case "$cmd" in
    ls | list)
      if [[ ${opts[*]} =~ (-m|--mini) ]]; then
        exec echo "$(sv check "$SVDIR"/* 2>/dev/null | sed -nr -e 's/ok: run/-/p' -e 's/ok: up/^/p' -e 's/ok: down/./p' -e 's/fail: /e/p' | cut -c1 | xargs printf '%s')"
      fi

      : "${COLUMNS:=$(tput cols)}"

      if [[ ${opts[*]} =~ (-v|--verbose) ]]; then
        ruler="$(ansi::dimmed "$(ansi::draw-line)")"
        echo "$ETCSVDIR" "$SVDIR" "$SVDIR_X11" \
          | sed -e "s|$HOME|\~|g" -e 's/^/   /' \
          | column -t -N "ETCSVDIR,SVDIR${SVDIR_X11:+,SVDIR_X11}" -o '    ' \
          | sed -r -e "1s|([^ ]+)|<b>\1</b>|g" -e 's/^/   /' \
          | sed -e "1i $ruler" -e "\$a $ruler"
      fi

      if [[ ${opts[*]} =~ (-a|--all) ]]; then
        local -a services=()
        local -i width

        mapfile -t services < <(find "$ETCSVDIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -u | while read -r sv; do
          if [ ! -d "$SVDIR/$sv" ] && [ ! -d "$SVDIR_X11/$sv" ] && [ ! -d "${SVDIR//.x11/}/$sv" ]; then
            echo "$sv"
          fi
        done)

        : "$((MAX_WIDTH = ${#services[@]} < 10 ? 0 : MAX_WIDTH))"
        : "$((MAX_WIDTH = MAX_WIDTH > COLUMNS ? COLUMNS : MAX_WIDTH))"

        printf '   <b>AVAILABLE SERVICES</b>\n'

        if [ ${#services[@]} -gt 0 ]; then
          width="$(printf '%s\n' "${services[@]}" | awk '{print length()|"sort -n"}' | tail -1)"
          width=$(math::max 20 "$width")

          while read -r sv; do
            if [ -d "$SVDIR/$sv" ] || [ -d "$SVDIR_X11/$sv" ] || [ -d "${SVDIR//.x11/}/$sv" ]; then
              continue
            fi
            printf "%-*s\n" "$width" "$sv" | cut -c-"$width"
          done < <(printf '%s\n' "${services[@]}")
        else
          printf ' <bl><b>•</b></bl> <i>no other services available</i>\n'
        fi \
          | column -c "$MAX_WIDTH" \
          | tr '	' ' ' \
          | sed -r -e 's|(^\|[^ ])([^ ]+)|   <d>\0</d>|g' -e '$a \\'
      fi

      for svdir in "$SVDIR" "$SVDIR_X11"; do
        if [ -d "$svdir" ]; then
          cmd_vsv -d "$svdir" "${vsv_opts[@]}"
        fi
      done
      ;;

    log*)
      shift
      exec svlogtail "$@"
      ;;

    *)
      if command -v vsv >/dev/null; then
        cmd_vsv "${vsv_opts[@]}"
      else
        sv "${1:-list}" "$@"
      fi
      ;;
  esac
}

if ansi::check-support; then
  ANSI_COLORS=always
fi

if [ "$UID" -ne 0 ] && [[ $* =~ (-a|^--)? ]] && [[ ! $* =~ (^(-[a-z] )*|--)*-u ]]; then
  sudo --preserve-env=ANSI_COLORS "$(readlink -f "$0")" "$@"
elif [[ ! $* =~ (-m) ]]; then
  echo
fi

main "$@" | ansi::colorize-tags
