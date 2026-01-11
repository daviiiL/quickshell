#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIO_FILE="${SCRIPT_DIR}/../assets/soft-startup.mp3"

preVol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')"

echo "System current volume level ${preVol}"

wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0

maxedVol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')"

echo "System current volume level ${maxedVol}"

echo "Playing startup sound"

pw-play "$AUDIO_FILE"

sleep 0.5 

wpctl set-volume @DEFAULT_AUDIO_SINK@ $preVol 

postVol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')"

echo "System current volume level ${postVol}"
