#!/usr/bin/env bash

set -euo pipefail

clipboard()
{
  tee -a /dev/stderr | tr -d '\n' | xsel -i -b
}

decrypt()
{
  gpg -o accounts "$@" -q -d -r "${GPG_DEFAULT_ID:-0xEFBC5C49C8205280}" --batch accounts.txt.gpg 2>/dev/null
}

function main
{
  local -a args=()
  local use_passfile='true'
  local show_error='true'

  while [ $# -gt 0 ]; do
    case "$1" in
      -qq)
        use_passfile='false'
        show_error='false'
        ;;

      -q) use_passfile='false' ;;

      *) args+=("$1") ;;
    esac
    shift
  done

  set -- "${args[@]}"

  cd "$XDG_CONFIG_HOME/cloak"

  if ! [ -r accounts.txt.gpg ]; then
    echo "file not readable: 'accounts.txt.gpg'" >&2
    exit 1
  fi

  # shellcheck disable=2064
  trap "[ -e accounts ] && shred -uz accounts >/dev/null" EXIT

  [ -e accounts ] || {
    decrypt --pinentry-mode cancel || :
  }

  [ -e accounts ] || {
    if ! decrypt --pinentry-mode loopback "${use_passfile+--passphrase-file}" <("$use_passfile" && "${XDG_CONFIG_HOME}/rofi/scripts/ask-password.sh" | while read -r pass; do
      [ "$pass" ] || exit 1
      echo "$pass" | keepassxc-cli show -s "$KPDB" signkey | sed -nr 's/Password: (.+)/\1/p'
    done); then
      [ "${PIPESTATUS[0]}" -eq 2 ] && exit 0 || exit 1
    fi
  }

  [ -e accounts ] || {
    "$show_error" && "${XDG_CONFIG_HOME}/rofi/scripts/show-error.sh" "failed to decrypt accounts"
    exit 1
  }

  export CLOAK_ACCOUNTS_DIR="$PWD"

  case "${1:-list}" in
    add | delete)
      cp accounts accounts.txt

      declare -A msg_ok

      msg_ok[add]='Account successfully created'
      msg_ok[delete]='Account successfully deleted'

      if ! command -p cloak "$@" | tee /dev/stderr | grep -q "${msg_ok[$1]}"; then
        exit 1
      fi

      printf -- '[0;1;33m** Re-encrypting db file to persist changes.[0m\n'

      make encrypt
      shred -uz accounts.txt
      ;;

    query)
      shift
      command -p cloak list | cat -s | sed -nr '/^Account:/,+1!d;N;s/\nTOTP: /\t/;s/^Account: //p' | column -t | fzf -q "$*" --sync --prompt 'Account: ' -d' ' --with-nth 1 | sed -r 's/.+[ ]+//' | clipboard
      ;;

    view) command -p cloak "$@" | cat -s | clipboard ;;

    *) command -p cloak "$@" | cat -s ;;
  esac
}

main "$@"
