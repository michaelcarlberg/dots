#!/bin/bash

set -e

token="$(jq -r .access_token ~/.config/spotify-tui/.spotify_token_cache.json)"

if [ "$token" = "" ]; then
  exit
fi

current="$(curl -s -H "Authorization: Bearer $token" https://api.spotify.com/v1/me/player/currently-playing)"
artist="$(jq -r .item.artists[0].name <<<"$current")"
song="$(jq -r .item.name <<<"$current")"

printf "%s - %s\n" "$artist" "$song"
