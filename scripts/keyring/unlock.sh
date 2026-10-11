#!/usr/bin/env bash
set -u
umask 077
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if "${SCRIPT_DIR}/is_unlocked.sh"; then
  exit 0
fi

IFS= read -r PW || exit 1
printf '%s' "$PW" | gnome-keyring-daemon --unlock >/dev/null 2>&1
rc=$?
unset PW
exit $rc
