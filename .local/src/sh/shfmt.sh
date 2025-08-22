#!/usr/bin/env bash

if ! command -v shfmt >/dev/null; then
  PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
fi

set -eo pipefail

[ "$DEBUG" = '1' ] && set -x

DEFAULT_ARGS=(--indent 2
  --case-indent
  --binary-next-line
  --func-next-line)

declare -a args=()
declare -a files=()

while [ $# -gt 0 ]; do
  case "$1" in
    *-filename)
      files+=("$(readlink -f "$2")")
      shift
      ;;

    -h | --help) exec shfmt -h ;;

    -i | --indent)
      args+=("$1" "$2")
      shift
      ;;

    -ln | --language-dialect)
      args+=("$1" "$2")
      shift
      ;;

    -*) args+=("$1") ;;

    *) files+=("$(readlink -f "$1")") ;;
  esac
  shift
done

set -- "${args[@]:-${DEFAULT_ARGS[@]}}"

# if [[ ${files[*]} =~ $(readlink -f "$0") ]]; then
#   echo "notice: by-passing handling of custom directives for: $0" >&2
#   exec shfmt "$@" "${files[@]}"
# fi

COMMENT_PREFIX='shfmt'
IGNORE_BEGIN='ignore-begin'
IGNORE_END='ignore-end'
IGNORE_LINE='ignore(-line|$)'
PARSER_COMMENT='parser'

parse_input() {
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

parse_output() {
  sed -r "s/.*# ${COMMENT_PREFIX}:${PARSER_COMMENT}://"
}

if read -r -t 0; then
  if [ "${files[0]}" ]; then
    set -- "$@" --filename "${files[0]}"
  fi

  shfmt "$@" < <(parse_input) | parse_output
else
  tmpfile="$(mktemp -u)"
  cat "${files[@]}" | parse_input >"$tmpfile"
  trap 'rm $tmpfile' EXIT
  shfmt "$@" "$tmpfile" 2>&1 | parse_output | sed "s|$tmpfile|${files[*]}|g"
fi
