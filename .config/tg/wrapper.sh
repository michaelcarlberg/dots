#!/usr/bin/env bash

set -eo pipefail

cd "$(dirname "$(readlink -f "$0")")"

if ! [ -r accounts.gpg ]; then
  echo "file not readable: 'accounts.gpg'" >&2
  exit 1
fi

if ! [ -L ./conf.py ] || ! [ -e ./conf.py ] || ! grep -i -q phone ./conf.py; then
  tmpfile="$(mktemp -u)"

  ln -svf "$tmpfile" ./conf.py
fi

gpg -q -d -r 0xEFBC5C49C8205280 ./accounts.gpg | column -t -s: | fzf --sync --prompt 'Telegram account: ' -d' ' --with-nth 1 | while read -r line; do
  cat ./conf.tpl.py <(echo "PHONE = '${line##* }'") >./conf.py
done

cat ./conf.py

command -p tg "$@"
