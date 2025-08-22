#!/usr/bin/env bash

nmcli networking on
nmcli device up eth0
nmcli connection up expressvpn
