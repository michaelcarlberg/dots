#!/bin/bash

set -e

_enable()
{
  local host="${VPN_HOST:-sweden-ca-version-2.expressnetw.com}"
  local port="${VPN_PORT:-1195}"
  local tun="${VPN_IFACE:-tun0}"

  ip link show "$tun" >/dev/null

  ufw reset
  ufw disable

  set -x

  ufw default deny outgoing
  ufw default deny incoming

  ufw allow out on "$tun" to any

  ufw allow in from 192.168.0.0/16 to 192.168.0.0/16
  ufw allow out from 192.168.0.0/16 to 192.168.0.0/16

  ip route del default 2>/dev/null || :
  ip route add default dev "$tun"

  for opts in wlan0:150; do
    local iface="${opts%:*}"
    local metric="${opts##*:}"

    ufw allow in on "$iface" from 192.168.0.0/16 app mDNS
    ufw allow out on "$iface" to 224.0.0.0/24 app mDNS

    ufw allow in on "$iface" from 192.168.0.0/16 app UPnP
    ufw allow out on "$iface" to 239.255.255.250 app UPnP

    ufw allow in on "$iface" from 192.168.0.0/16 app "KDE Connect"
    ufw allow out on "$iface" to 192.168.0.0/16 app "KDE Connect"
    # link-local multicast name resolution
    ufw allow in on "$iface" from 192.168.0.0/16 to any proto udp port 5355

    gw="$(arp -i wlan0 -a | sed -nr 's/^_gateway \(([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).+/\1/p')"
    gw="${gw:-192.168.0}.1"

    dig +short "$host" | while read -r ip; do
      ufw allow out to "$ip" port 53,"$port" proto udp
      ip route del "$ip" via "$gw" dev "$iface" 2>/dev/null || :
      ip route add "$ip" via "$gw" dev "$iface" proto static metric "$metric"
    done

    ip route del 192.168.0.0/16 dev "$iface" 2>/dev/null || :
    ip route add 192.168.0.0/16 dev "$iface" proto static metric "$metric"

    ip route del 224.0.0.0/24 via "$gw" dev "$iface" 2>/dev/null || :
    ip route add 224.0.0.0/24 via "$gw" dev "$iface" proto static metric "$metric"

    ip route del 239.255.255.250 via "$gw" dev "$iface" 2>/dev/null || :
    ip route add 239.255.255.250 via "$gw" dev "$iface" proto static metric "$metric"
  done

  # ip route del default 2>/dev/null || :
  # ip route add default dev "$tun"

  # ufw allow in on eth0 from 192.168.0.0/24 app mDNS
  # ufw allow out on eth0 to 224.0.0.0/24 app mDNS
  #
  # ufw allow in on eth0 from 192.168.0.0/24 app UPnP
  # ufw allow out on eth0 to 239.255.255.250 app UPnP
  #
  # ufw allow in on eth0 from 192.168.0.0/24 app "KDE Connect"
  # ufw allow out on eth0 to 192.168.0.0/24 app "KDE Connect"
  # # link-local multicast name resolution
  # ufw allow in on eth0 from 192.168.0.0/24 to any proto udp port 5355
  #
  # dig +short "$host" | while read -r ip; do
  #   ufw allow out to "$ip" port 53,"$port" proto udp
  #   ip route del "$ip" 2>/dev/null || :
  #   ip route add "$ip" via 192.168.0.1 dev eth0 proto static metric 100
  # done
  #
  # ip route del default 2>/dev/null || :
  # ip route add default dev "$tun"
  #
  # ip route del 192.168.0.0/24 2>/dev/null || :
  # ip route add 192.168.0.0/24 dev eth0 proto static metric 100
  #
  # ip route del 224.0.0.0/24 2>/dev/null || :
  # ip route add 224.0.0.0/24 via 192.168.0.1 dev eth0 proto static metric 100
  #
  # ip route del 239.255.255.250 2>/dev/null || :
  # ip route add 239.255.255.250 via 192.168.0.1 dev eth0 proto static metric 100

  ufw enable
}

_reset()
{
  ufw reset
  set -x
  ip route del default 2>/dev/null || :
  ip route add default via 192.168.0.1
}

case "$1" in
  enable) _enable ;;
  disable) ufw disable ;;
  reset) _reset ;;
  *)
    echo "Usage: $0 <enable|disable|reset>" >&2
    exit 1
    ;;
esac
