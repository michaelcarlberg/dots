#!/bin/bash
set -e
ufw allow in to 192.168.0.0/24 app "KDE Connect"
ufw allow out to 192.168.0.0/24 app "KDE Connect"
sudo ufw reload
