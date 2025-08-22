#!/bin/bash

set -e

ip -j addr show dev "${1?network interface}" | jq -r .[].addr_info[].local
