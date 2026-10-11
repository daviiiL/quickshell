#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
key="${1:-geminiApiKey}"

data=$(secret-tool lookup service quickshell key "$key")
if [[ -z "$data" ]]; then
  if "${SCRIPT_DIR}/is_unlocked.sh"; then
    echo 'not found'
    exit 1
  fi
  echo 'locked'
  exit 2
fi
printf '%s\n' "$data"
