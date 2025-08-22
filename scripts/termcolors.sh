#!/bin/bash

set -e

get_color()
{
  head -57 .termcolors-doom | tail -n+4 | cut -c2- | shyaml get-value colors."$1" | xargs echo
}

hex_to_rgbstring()
{
  echo "${1:1:2}/${1:3:2}/${1:3:2}"
}

get_color normal.red
hex_to_rgbstring "$(get_color normal.red)"
