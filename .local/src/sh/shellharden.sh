#!/usr/bin/env bash

set -eo pipefail

DEFAULT_ARGS=(--transform)

declare -a args=()
declare -a files=()

while [ $# -gt 0 ]; do
  case "$1" in
    *-filename)
      files+=("$2")
      shift
      ;;

    -h | --help) exec shellharden -h ;;

    -* | '') args+=("$1") ;;

    *) files+=("$(readlink -f "$1")") ;;
  esac
  shift
done

if [ "$DEBUG" = '1' ]; then
  echo "[$0::debug]  args: ${args[*]:-(default) ${DEFAULT_ARGS[*]}}" >&2
  echo "[$0::debug] files: ${files[*]}" >&2
fi

set -- "${args[@]:-${DEFAULT_ARGS[@]}}"

# if [[ ${files[*]} =~ $(readlink -f "$0") ]]; then
#   echo "notice: by-passing handling of custom directives for: $0" >&2
#   set -x
#   exec shfmt "$@" "${files[@]}"
# fi

COMMENT_PREFIX='shfmt'
IGNORE_BEGIN='ignore-begin'
IGNORE_END='ignore-end'
IGNORE_LINE='ignore(-line|$)'
PARSER_COMMENT='shellharden:parser'

parse_input()
{
  sed -r -f <(
    cat <<-EOF
			/# ${COMMENT_PREFIX}:${IGNORE_BEGIN}/,/# ${COMMENT_PREFIX}:${IGNORE_END}/{
				s/^/# ${COMMENT_PREFIX}:${PARSER_COMMENT}:/
			}
			/# ${COMMENT_PREFIX}:${IGNORE_LINE}/{
				: prefix-line
				  s/^[ ]*#/# ${COMMENT_PREFIX}:${PARSER_COMMENT}:\0/
				  T end
				  n
				  b prefix-line
				: end
				  s/^[ ]*[^#]/# ${COMMENT_PREFIX}:${PARSER_COMMENT}:\0/
				  b
			}
		EOF
  )
}

parse_output()
{
  sed -r "s/.*# ${COMMENT_PREFIX}:${PARSER_COMMENT}://"
}

if read -r -t 0; then
  shellharden "$@" < <(parse_input) | parse_output
else
  tmpfile="$(mktemp -u)"
  cat "${files[@]}" | parse_input >"$tmpfile"
  trap 'rm $tmpfile' EXIT
  shellharden "$@" "$tmpfile" 2>&1 | sed "s|$tmpfile|${files[*]}|g" | parse_output
fi
