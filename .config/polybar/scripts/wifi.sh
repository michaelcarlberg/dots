#!/usr/bin/env bash

set -x

# if [ $# -eq 1 ]; then
#   bar="$1"
#   shift
#   pid="$(polybar-helper pid "$bar")"
#   polybar-msg -p "$pid" action '#wifi.module_hide'
#   polybar-msg -p "$pid" action '#wifi-menu-loading.module_show'
#   polybar-msg -p "$pid" action wifi-menu-loading send '%{F#e60053}%{F-} scanning...'
#   loading='true'
# fi

# nmcli -t --fields ssid,security,signal,in-use device wifi list --rescan no | grep -v -E '^:' | sort -u

function exec_rofi
{
  exec rofi \
    -location 3 \
    -yoffset 40 \
    -xoffset -15 \
    -width -200 \
    "$@"
}

function exec_nmcli
{
  exec nmcli -c no "$@"
}

function main
{
  local loader
  local connected
  local -a entries=() networks=()
  local -i lines=1 maxlines=10

  exec_rofi -e "Scanning for networks..." -lines 1 &
  loader=$!

  mapfile -t networks < <(exec_nmcli -t --fields in-use,ssid,security,signal device wifi list --rescan auto | grep -v -E '^ ::')
  kill "$loader"

  printf "Found %d networks...\n" "${#networks[@]}"

  case "$(exec_nmcli radio wifi)" in
    enabled)
      for network in "${networks[@]}"; do
        if [ "${network##\**}" = "" ]; then
          connected='true'
          echo "${#entries[@]}"
          echo "Connected to: $network"
        fi
      done

      if "$connected"; then
        entries+=('> Disconnect')
      fi

      entries+=('> Turn off Wi-Fi')

      for network in "${networks[@]}"; do
        entries+=("$network")
      done

      lines=${#entries[@]}
      if ((lines > maxlines)); then
        lines=$maxlines
      fi

      # case "$(exec_nmcli networking connectivity check)" in
      #   # the host is not connected to any network.
      #   none) ;;
      #   # the host is behind a captive portal and cannot reach the full Internet.
      #   portal) ;;
      #   # the host is connected to a network, but it has no access to the Internet.
      #   limited) ;;
      #   # the host is connected to a network and has full access to the Internet.
      #   full) ;;
      #   # the connectivity status cannot be found out.
      #   unknown) ;;
      # esac
      ;;

    disabled)
      entries+=('> Turn on Wi-Fi')
      ;;
  esac

  exec_rofi -e "Scanning for Wi-Fi networks..." -lines 1 &
  pid=$!
  kill "$pid"
  printf -- '%s\n' "${entries[@]}" | exec_rofi -dmenu -i -p "command:" -lines "$lines" -theme-str "listview { lines: $lines; }" | while read -r selection; do
    case "$selection" in
      "> Disconnect") ;;
      "> Turn off Wi-Fi") ;;
      *) ;;
    esac
  done
}

main "$@"

# # https://github.com/zbaylin/rofi-wifi-menu/blob/master/rofi-wifi-menu.sh
#
# # Starts a scan of available broadcasting SSIDs
# # nmcli dev wifi rescan
#
# FIELDS=SSID,SECURITY,BARS
# POSITION=3
# YOFF=40
# XOFF=-15
#
# # SEPARATOR='─────────────────────────────────────────────────────────────────────────'
#
# LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d' | awk -F'  +' '{ if (!seen[$2]++) print}' | tail -n+2)
# # For some reason rofi always approximates character width 2 short... hmmm
# RWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }') + 2))
# # Dynamically change the height of the rofi menu
# LINENUM=$(echo "$LIST" | wc -l)
# # Gives a list of known connections so we can parse it later
# KNOWNCON=$(nmcli connection show)
# # Really janky way of telling if there is currently a connection
# CONSTATE=$(nmcli -fields WIFI g)
#
# ARGS="-async-pre-read 0 -location $POSITION -yoffset $YOFF -xoffset $XOFF -width -$RWIDTH"
#
# roficmd()
# {
#   if "$loading"; then
#     polybar-msg -p "$pid" action '#wifi.module_show'
#     polybar-msg -p "$pid" action '#wifi-menu-loading.module_hide'
#     loading='false'
#   fi
#   eval "$(command -v rofi) $ARGS $*"
# }
#
# CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')
#
# if [ "$CURRSSID" != "" ]; then
#   HIGHLINE=$(echo "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fxn -m 1 "$CURRSSID" | awk -F ":" '{print $1}') + 1" | bc)
# fi
#
# # HOPEFULLY you won't need this as often as I do
# # If there are more than 8 SSIDs, the menu will still only have 8 lines
# if [ "$LINENUM" -gt 8 ] && [[ $CONSTATE =~ "enabled" ]]; then
#   LINENUM=8
# elif [[ $CONSTATE =~ "disabled" ]]; then
#   LINENUM=1
# fi
# echo "$CONSTATE"
#
# LINENUM=$((2 + $(wc -l <<<"$LIST")))
# echo "$LINENUM"
#
# if [[ $CONSTATE =~ "enabled" ]]; then
#   TOGGLE="> toggle off"
# elif [[ $CONSTATE =~ "disabled" ]]; then
#   TOGGLE="> toggle on"
# fi
#
# CHENTRY=$(echo -e "$LIST${LIST+\n\n}$TOGGLE" | uniq -u | roficmd -dmenu -p "network: " -lines "$LINENUM" -a "$HIGHLINE" -theme-str \"listview \{ lines: "$LINENUM"\; \}\")
# #CHENTRY=$(echo -e "$TOGGLE\nmanual\n$LIST" | uniq -u | roficmd "$ARGS" -dmenu -p "network: " -lines "$LINENUM" -a "$HIGHLINE" -location "$POSITION" -yoffset "$YOFF" -xoffset "$XOFF" -width -"$RWIDTH")
# #CHENTRY=$(echo -e "$LIST" | uniq -u | roficmd "$ARGS" -dmenu -p "network: " -lines "$LINENUM" -a "$HIGHLINE" -location "$POSITION" -yoffset "$YOFF" -xoffset "$XOFF" -width -"$RWIDTH")
# #echo "$CHENTRY"
# CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')
# #echo "$CHSSID"
#
# # If the user inputs "manual" as their SSID in the start window, it will bring them to this screen
# if [ "$CHENTRY" = "manual" ]; then
#   # Manual entry of the SSID and password (if appplicable)
#   MSSID=$(echo "enter the SSID of the network (SSID,password)" | roficmd "$ARGS" -dmenu -p "manual entry: " -lines 1)
#   # Separating the password from the entered string
#   MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')
#
#   # If the user entered a manual password, then use the password nmcli command
#   if [ "$MPASS" = "" ]; then
#     nmcli dev wifi con "$MSSID"
#   else
#     nmcli dev wifi con "$MSSID" password "$MPASS"
#   fi
#
# elif [ "$CHENTRY" = "> toggle on" ]; then
#   sudo nmcli radio wifi on
# elif [ "$CHENTRY" = "> toggle off" ]; then
#   sudo nmcli radio wifi off
# else
#
#   # If the connection is already in use, then this will still be able to get the SSID
#   if [ "$CHSSID" = "*" ]; then
#     CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
#   fi
#
#   if [ "$CHSSID" = "$CURRSSID" ]; then
#     nmcli connection down "$CHSSID"
#   # Parses the list of preconfigured connections to see if it already contains the chosen SSID. This speeds up the connection process
#   elif [[ $(echo "$KNOWNCON" | grep "$CHSSID") == "$CHSSID" ]]; then
#     nmcli connection up "$CHSSID"
#   else
#     if [[ $CHENTRY =~ "WPA2" ]] || [[ $CHENTRY =~ "WEP" ]]; then
#       WIFIPASS=$(echo "if connection is stored, hit enter" | roficmd "$ARGS" -dmenu -p "password: " -lines 1)
#     fi
#     nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
#   fi
#
# fi
