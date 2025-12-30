#!/usr/bin/env bash

# Generate thumbnails for wallpaper images using ImageMagick
# Following the FreeDesktop.org thumbnail specification
# https://specifications.freedesktop.org/thumbnail-spec/latest/

set -e

# Thumbnail sizes mapping
get_thumbnail_size() {
    case "$1" in
        normal) echo 128 ;;
        large) echo 256 ;;
        x-large) echo 512 ;;
        xx-large) echo 1024 ;;
        *) echo 128 ;;
    esac
}

usage() {
    echo "Usage: $0 [--size normal|large|x-large|xx-large] [--directory <path>]"
    echo "       $0 [--size normal|large|x-large|xx-large] [--file <path>]"
    exit 1
}

urlencode() {
    # Percent-encode a string for use in a URI
    local str="$1"
    local encoded=""
    local c
    for ((i=0; i<${#str}; i++)); do
        c="${str:$i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]|/) encoded+="$c" ;;
            *) printf -v hex '%%%02X' "'${c}'"; encoded+="$hex" ;;
        esac
    done
    echo "$encoded"
}

generate_thumbnail() {
    local src="$1"
    local abs_path
    abs_path="$(realpath "$src")"

    # Skip non-image files (GIFs, videos, etc.)
    case "${abs_path,,}" in
        *.gif|*.mp4|*.webm|*.mkv|*.avi|*.mov)
            return
            ;;
    esac

    # Calculate MD5 hash of file:// URI
    local encoded_path
    encoded_path="$(urlencode "$abs_path")"
    local uri="file://$encoded_path"
    local hash
    hash="$(echo -n "$uri" | md5sum | awk '{print $1}')"

    local out="$CACHE_DIR/$hash.png"
    mkdir -p "$CACHE_DIR"

    # Skip if thumbnail already exists
    if [ -f "$out" ]; then
        echo "FILE $abs_path"
        return
    fi

    # Generate thumbnail using ImageMagick
    if magick "$abs_path" -resize "${THUMBNAIL_SIZE}x${THUMBNAIL_SIZE}" "$out" 2>/dev/null; then
        echo "FILE $abs_path"
    fi
}

# Parse arguments
SIZE_NAME="normal"
MODE=""
TARGET=""
PROGRESS=0
COMPLETED=0
TOTAL=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --file|-f)
            MODE="file"
            TARGET="$2"
            shift 2
            ;;
        --directory|-d)
            MODE="dir"
            TARGET="$2"
            shift 2
            ;;
        --size|-s)
            SIZE_NAME="$2"
            shift 2
            ;;
        --machine_progress)
            PROGRESS=1
            shift
            ;;
        *)
            usage
            ;;
    esac
done

THUMBNAIL_SIZE="$(get_thumbnail_size "$SIZE_NAME")"
CACHE_DIR="$HOME/.cache/thumbnails/$SIZE_NAME"

if [ -z "$MODE" ] || [ -z "$TARGET" ]; then
    usage
fi

case "$MODE" in
    file)
        if [ ! -f "$TARGET" ]; then
            echo "File not found: $TARGET" >&2
            exit 2
        fi
        generate_thumbnail "$TARGET"
        ;;
    dir)
        if [ ! -d "$TARGET" ]; then
            echo "Directory not found: $TARGET" >&2
            exit 2
        fi

        # Count total image files
        if [ "$PROGRESS" -eq 1 ]; then
            for f in "$TARGET"/*; do
                [ -f "$f" ] || continue
                case "${f,,}" in
                    *.jpg|*.jpeg|*.png|*.webp|*.tif|*.tiff|*.svg)
                        TOTAL=$((TOTAL + 1))
                        ;;
                esac
            done
        fi

        # Generate thumbnails
        for f in "$TARGET"/*; do
            [ -f "$f" ] || continue
            case "${f,,}" in
                *.jpg|*.jpeg|*.png|*.webp|*.tif|*.tiff|*.svg)
                    generate_thumbnail "$f"
                    if [ "$PROGRESS" -eq 1 ]; then
                        COMPLETED=$((COMPLETED + 1))
                        echo "PROGRESS $COMPLETED/$TOTAL"
                    fi
                    ;;
            esac
        done
        ;;
    *)
        usage
        ;;
esac
