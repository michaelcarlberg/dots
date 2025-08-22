#!/bin/bash

function usage
{
  echo "Usage: ${0##*/} [from code-point] [to code-point] " >&2
  exit 1
}

function main
{
  local -i columns=8
  local -i from=-1
  local -i to=-1
  local -i max

  max="$(printf '%d\n' 0x10FFFF)"

  while [ $# -gt 0 ]; do
    case "${1,,}" in
      -c)
        shift
        columns=$1
        ;;

      [[:xdigit:]]*)
        if [ $# -gt 0 ] && ! grep -qE '^([ ]*(0x)?[[:xdigit:]]+){1,2}$' <<<"$*"; then
          usage
        fi
        if ((from < 0)); then
          from="$(printf '%d\n' "0x${1#0x}")"
        elif ((to < 0)); then
          to="$(printf '%d\n' "0x${1#0x}")"
        fi
        ;;
    esac
    shift
  done

  : $((to = to > -1 ? to : max))

  [ "$DEBUG" ] && {
    echo "columns = $columns" >&2
    echo "   from = $from" >&2
    echo "     to = $to" >&2
  }

  seq "$from" "${to:-$max}" | while read -r n; do
    printf '%15s\n' "$(echo -e "$(printf '\\u%04x,%04X' "$n" "$n")")"
  done | sed -r "$(seq "$((columns - 1))" | xargs -I{} printf ';N;s/\\n/....../g' | cut -c2-);!d" | sed -r 's/,/   /g ; s/[\.]{2,}/\t/g' | sed -r -e '1i\\n' -e '$a\\n' -e 's/^/    /g'
}

main "$@"
