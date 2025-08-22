#!/bin/sh
set -e
set -x

trap '{ kill -9 $nc1 $nc2; wait $nc1 $nc2; }' 0
nc -l -k -p 8000 -c "nc 127.0.0.1 ${1:-9100}" & nc1=$!
nc -l -k -p 20000 -c "nc 127.0.0.1 ${2:-38691}" & nc2=$!

set +x
sleep 2
printf "\n-> Q<enter> to quit\n"
while read -r answer; do
  echo "$answer" | grep -q "Q" && break
done
