#!/usr/bin/env bash
#
# Livestreaming with FFMPEG for Twitch.tv
#
URL="rtmp://localhost/live/livestream"
INRES="670x670"
LOC="20,87"
OUTRES="670x670" #"1280x720"
FPS="30"
QUAL="ultrafast"

# -f x11grab       forces input to be from x11grab
# -s "$INRES"      sets a specific image size, relying on the variable $INRES
# -r "$FPS"        sets framerate to be the value equal to $FPS
# -i :1.0          gets input, in this case its pulling in screen :0.0 from x11
# -c:v libx264     sets video codec to libx264
# -crf 23          sets the ffmpeg constant rate factor to 23 (the default)
# -preset "$QUAL"  sets the preset compression quality and speed. possible presets are:
#                      ultrafast, superfast, veryfast, faster
#                      fast, medium, slow, slower, veryslow
# -s "$OUTRES"     specifies size of image
# -threads 0       sets cpu threads to start, 0 autostarts threads based on cpu cores
# -pix_fmt yuv420p sets pixel format to Y'UV420p. Otherwise by default Y'UV444 is used and is incompatible with twitch
# -f flv "$URL"    forces format to flv, and outputs to the twitch RTMP url

ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :1.0+"$LOC" \
  -c:v libx264 -preset "$QUAL" -s "$OUTRES" \
  -threads 0 -pix_fmt yuv420p \
  -f flv "$URL"
