#!/usr/bin/env bash
locked_state=$(busctl --user get-property org.freedesktop.secrets \
  /org/freedesktop/secrets/aliases/default \
  org.freedesktop.Secret.Collection Locked 2>/dev/null)
if [[ "${locked_state}" == "b false" ]]; then
  echo 'Keyring is unlocked' >&2
  exit 0
fi
echo 'Keyring is locked' >&2
exit 1
