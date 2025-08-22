#!/usr/bin/env bash

set -eo pipefail

cd "${0%/*}"

if ! [ -r accounts ]; then
  echo "file not readable: 'accounts'" >&2
  exit 1
fi

set -x
gpg -v -e -r 0xEFBC5C49C8205280 accounts
