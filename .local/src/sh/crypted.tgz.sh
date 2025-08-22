#!/usr/bin/env bash

# encrypt
# cd /path/to/dir
# tar cz . | openssl enc -aes-256-cbc -pbkdf2 -e -out out.tar.gz.enc

# decrypt
# openssl enc -aes-256-cbc -pbkdf2 -d -in out.tar.gz.enc -out - | tar xvzf -

# set -e
#
# if [ "$1" = '-d' ]; then
#   if [[ $2 =~ \.enc$ ]]; then
#     outfile="${2%.enc}"
#   else
#     outfile="${2}.dec"
#   fi
#
#   if [ -w "$(readlink -f "${outfile%/*}/${outfile}")" ]; then
#     echo '[ok] write access '
#   fi
#
#   # append unix timestamp to outfile if it already exists
#   if [ -e "$outfile" ]; then
#     outfile="${outfile}.$(date +%s)"
#   fi
#
#   # log "will output the processed file(s) encrypted
#   # outfile="${outfile}.$(date +%s)"
#
#   if ! openssl aes-256-cbc -pbkdf2 -iter 100000 -d -in "$2" -out "$outfile"; then
#     rm "$outfile"
#     exit 1
#   else
#     echo "$outfile"
#     exit 0
#   fi
# else
#   if [ ! -d "$1" ]; then
#     echo "Not a directory: $1" >&2
#     exit 1
#   fi
#
#   cd "$1"
#
#   tar cz . | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -e >../"$(basename "$1")".tar.gz.enc
# fi

# tar czvf ../backup.tar.gz .
# encrypt

set -e

cd "${0%/*}"

usage()
{
  if [ $# -gt 0 ]; then
    echo -e "$*\n" >&2
  fi

  echo "Usage: ${0##*/} [-o OUTFILE] FILE..." >&2
  exit 1
}

can_write()
{
  if ! mkdir "$outfile" 2>/dev/null; then
    usage "Cannot write to: $outfile"
  else
    rmdir "$outfile"
  fi
}

main()
{
  [ $# -eq 0 ] && usage

  local decrypt='false'
  local force='false'
  local outfile
  local outfile_next

  while [ $# -gt 0 ]; do
    if false; then
      :
    fi
  done

  while [ "${1:0:1}" = '-' ]; do
    case "$1" in
      e | enc | encrypt)
        local src="${1?srcfile}"
        local dst="${2?dstdir}"
        shift 2
        ;;

      d | dec | decrypt)
        local src="${1?srcfile}"
        local dst="${2?dstdir}"
        shift 2
        ;;

      *) usage "invalid option: $1" ;;
    esac
    shift
  done

  while [ "${1:0:1}" = '-' ]; do
    case "$1" in
      -h | --help | -help)
        usage ;;

      d | dec | decrypt)
        ;;
        outfile="$2"
        shift
        ;;
      *) usage "invalid option: $1" ;;
    esac
    shift
  done

  if "$decrypt"; then
    :
  fi

  while [ -e "$outfile" ] && ! [ "$outfile_next" ]; do
    if [ ! -w "$outfile" ]; then
      usage "File not writable: $outfile"
    elif ! "$force"; then
      usage "File exists: $outfile (use -f to mv to ${outfile_next})"
    else
      mv -v "$outfile" "$outfile_next"
    fi

    outfile="$outfile"
  done

  tar cvzf "$outfile" "$@"
}

main "$@"

# tar czvf ../backup.tar.gz .

# encrypt
# openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -e -in /tmp/backup.tar.gz -out /tmp/backup.tar.gz.enc

# decrypt
# openssl aes-256-cbc -pbkdf2 -iter 100000 -d -in backup.tar.gz.enc -out backup.tar.gz

# vim:ft=sh
