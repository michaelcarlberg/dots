#!/bin/bash

if nmcli -t -f type,state c | grep -qE '^(vpn|tun):activated' && nmcli net con check | grep -q full; then
  echo 
else
  echo
fi
