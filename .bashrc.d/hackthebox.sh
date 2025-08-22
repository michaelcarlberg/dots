#!/usr/bin/env bash

if [ "$vm" = "" ] && [ -f /tmp/htb.vm ]; then
  . /tmp/htb.vm
fi

alias htb-vm='printf "enter ip: "; read -r vm; echo "export vm=${vm}" >/tmp/htb.vm'
