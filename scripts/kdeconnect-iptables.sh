#!/bin/bash

set -e
set -x

ip rule add fwmark 2 table 100
ip route flush cache

iptables -t mangle -A OUTPUT -p tcp --dport 1714:1764 -j MARK --set-mark 2
iptables -t mangle -A OUTPUT -p udp --dport 1714:1764 -j MARK --set-mark 2
iptables -t mangle -A INPUT -p tcp --dport 1714:1764 -j MARK --set-mark 2
iptables -t mangle -A INPUT -p udp --dport 1714:1764 -j MARK --set-mark 2
iptables -t nat -A POSTROUTING -o wlan0 -j SNAT --to-source 192.168.0.2
