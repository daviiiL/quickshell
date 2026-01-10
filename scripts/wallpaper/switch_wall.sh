#!/usr/bin/env bash

# Simple wallpaper switcher for Quickshell
# Uses swww for wallpaper switching
# Optionally generates color scheme with matugen

set -e

usage() {
    echo "Usage: $0 [--scheme <matugen-scheme>] [--mode <dark|light>] <image-path>"
    echo "Switches wallpaper using swww"
    echo "Optionally generates color scheme with matugen"
    echo ""
    echo "Options:"
    echo "  --scheme <scheme>  Matugen color scheme to use (default: scheme-tonal-spot)"
    echo "  --mode <mode>      Dark or light mode for matugen (default: dark)"
    exit 1
}

# Parse arguments
MATUGEN_SCHEME="scheme-tonal-spot"
MATUGEN_MODE="dark"
WALLPAPER_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --scheme)
            MATUGEN_SCHEME="$2"
            shift 2
            ;;
        --mode)
            MATUGEN_MODE="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            WALLPAPER_PATH="$1"
            shift
            ;;
    esac
done

# Check if image path is provided
if [ -z "$WALLPAPER_PATH" ]; then
    usage
fi

# Validate that the file exists
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: File not found: $WALLPAPER_PATH" >&2
    exit 1
fi

# Get absolute path
WALLPAPER_PATH="$(realpath "$WALLPAPER_PATH")"

if command -v swww &>/dev/null; then
    if ! pgrep -x swww-daemon > /dev/null; then
        swww-daemon &
        sleep 1
    fi

    swww img "$WALLPAPER_PATH" \
        --transition-type fade \
        --transition-duration 1

    if command -v matugen &>/dev/null; then
        matugen image "$WALLPAPER_PATH" --type "$MATUGEN_SCHEME" --mode "$MATUGEN_MODE" &>/dev/null &
        sleep 1
    fi

    pkill -SIGUSR1 kitty 2>/dev/null || true

    exit 0
fi

notify-send -a "Wallpaper Service" "Error: swww is not available" "Please install swww: https://github.com/LGFae/swww"
exit 1
