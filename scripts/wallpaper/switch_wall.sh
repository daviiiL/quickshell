#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [--scheme <matugen-scheme>] [--mode <dark|light>] <image-path>"
    echo "Switches wallpaper using awww"
    echo "Optionally generates color scheme with matugen"
    echo ""
    echo "Options:"
    echo "  --scheme <scheme>  Matugen color scheme to use (default: scheme-tonal-spot)"
    echo "  --mode <mode>      Dark or light mode for matugen (default: dark)"
    exit 1
}

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

if [ -z "$WALLPAPER_PATH" ]; then
    usage
fi

if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: File not found: $WALLPAPER_PATH" >&2
    exit 1
fi

WALLPAPER_PATH="$(realpath "$WALLPAPER_PATH")"

if command -v awww &>/dev/null; then
    if ! pgrep -x awww-daemon > /dev/null; then
        awww-daemon &
        sleep 1
    fi

    awww img "$WALLPAPER_PATH" \
        --transition-type fade \
        --transition-duration 1

    if command -v matugen &>/dev/null; then
        matugen image "$WALLPAPER_PATH" --type "$MATUGEN_SCHEME" --mode "$MATUGEN_MODE" &>/dev/null &
        sleep 1
    fi

    pkill -SIGUSR1 kitty 2>/dev/null || true

    exit 0
fi

notify-send -a "Wallpaper Service" "Error: awww is not available" "Please install awww: https://codeberg.org/LGFae/awww"
exit 1
