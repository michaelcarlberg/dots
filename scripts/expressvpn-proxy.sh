#!/bin/sh

echo "deprecated: using ~/src/docker/expressvpn-proxy/run.sh" >&2
exec /home/jaagr/.local/src/docker/expressvpn-proxy/run.sh "$@"

# set -e
# cd ~/var/repos/Expressvpn-Proxy-Adapter
# docker rm -f haugene-transmission-openvpn-my_expressvpn_sweden_udp 2>/dev/null || :
# ./spawn.sh my_expressvpn_sweden_udp.ovpn expressvpn 9999 cbjdbzhcrisjvnmfjj1kd3m1 nmpvunul8hfwrxzpgtls7hqy always
