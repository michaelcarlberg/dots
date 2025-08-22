#!/usr/bin/env bash

set -eo pipefail

usage()
{
  cat <<-EOF
	Usage: ${0#*/} [opts] <path>

    -f, --files    rename files
    -d, --dirs     rename directories
    -a, --apply    apply suggested changes
    -h, --help     display this help and exit

	EOF
  exit 1
}

normalize()
{
  sed -e 'y/åäöÅÄÖ /aaoAAO_/' -e 's/[^[:alnum:]_-]//g' -e 's/__/_/g' -e 's/(^[^[:alnum:]]*|[^[:alnum:]]*$)//g' | tr '[:upper:]' '[:lower:]'
}

main()
{
  local apply='false'
  local files='false'
  local dirs='false'

  while [ "${1:0:1}" = '-' ]; do
    case "$1" in
      -a | *-apply) apply='true' ;;
      -f | *-files) files='true' ;;
      -d | *-dirs) dirs='true' ;;
      -h | *-help) usage ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        ;;
    esac
    shift
  done

  local path="${1%/}"

  [ -d "$path" ] || usage

  cd "$path"
  cd ..

  if ! "$files" && ! "$dirs"; then
    printf "Nothing to rename.\n\n" >&2
    usage
  fi

  if ! "$apply"; then
    mv()
    {
      echo "[dry-run] mv $*"
    }
  fi

  find "${path##*/}" -type d | sort -ru | while read -r dirname; do
    if "$files"; then
      find "$dirname" -mindepth 1 -type f | while read -r filename; do
        local path=${filename%/*}
        local ext="${filename##*.}"
        local normalized_filename="${filename##*/}"

        normalized_filename="${normalized_filename%.*}"
        normalized_filename="$(normalize <<< "$normalized_filename")"

        [ "${normalized_filename}.${ext}" = "${filename##*/}" ] && continue

        mv -v "${filename}" "$(dirname "${filename}")/$(basename "${normalized_filename}").${ext}"
      done
    fi

    if "$dirs"; then
      local normalized_dirname

      normalized_dirname="$(echo "$dirname" | tr '/' '\n' | normalize | tr '\n' '/' | sed 's|/$||')"

      [ "${normalized_dirname##*/}" = "${dirname##*/}" ] && continue

      mv -v "${dirname}" "$(dirname "${dirname}")/$(basename "${normalized_dirname}")"
    fi
  done

  "$apply" || printf "\nUse -a to apply the suggested changes.\n" >&2
}

main "$@"
