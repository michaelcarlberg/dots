#!/usr/bin/env bash

yes-or-no-setting()
{
  if read -r -n1 -s -p "> ${1}: [2m[y/n][0m " answer && [ "${answer,,}" = 'y' ]; then
    printf "\r[32m+ %s[0m[K\n" "$1"
    return 0
  else
    printf '\r[31m- %s[0m[K\n' "$1"
    return 1
  fi
}

yes-or-no-setting 'enable ssh access' && set -- -p 41061:22
yes-or-no-setting 'enable ssl server' && set -- -p 41062:80

echo "\$ docker run --name myapp $* -d -v ~/my_web_pages:/www tomsik68/xampp:8"
