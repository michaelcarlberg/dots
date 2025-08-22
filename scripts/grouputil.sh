#!/usr/bin/env bash

set -e

source bootstrap.sh

include utils/ansi.sh
include utils/log.sh
include utils/log/defer.sh
include utils/proc.sh

bootstrap::finish

declare -g SUDO_USER
declare -g SUDO_CMD

confirm()
{
  local prompt="$1"
  shift
  printf '%s' "$prompt" "$@" | ansi::colorize-tags
  read -r -p "$1 [Y/n] " answer && [ "${answer^^}" = 'Y' ]
}

main()
{
  [ $# -gt 1 ] || {
    exec >&2
    cat >&2 <<-EOF
			Usage: $(basename "$0") <command> <args...>

			COMMANDS:
			  au | add-user <user> <group>
			  ru | remove-user <user> <group>

		EOF
    exit 1
  }

  : "${SUDO_USER:=root}"
  : "${SUDO_CMD:=sudo -u $SUDO_USER}"

  case "$1" in
    au | add-user)
      local user="${2?user}"
      local group="${3?group}"

      if confirm "Add <b>${user}</b> to <b>${group}</b>?"; then
        # shfmt:ignore
        $SUDO_CMD gpasswd --add "$user" "$group"
      fi
      ;;

    ru | remove-user)
      local user="${2?user}"
      local group="${3?group}"

      if confirm "Remove <b>${user}</b> from <b>${group}</b>?"; then
        # shfmt:ignore
        $SUDO_CMD gpasswd --delete "$user" "$group"
      fi
      ;;

    *)
      echo "Unknown command: $1" >&2
      exit 1
      ;;
  esac
}

main "$@"
