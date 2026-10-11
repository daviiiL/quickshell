#!/usr/bin/env bash
# usage: wifi_connect.sh connect|rekey SSID [BSSID] [wpa-psk|sae]   (PSK on stdin)
set -euo pipefail
umask 077
export LC_ALL=C

mode="${1:-}"
ssid="${2:-}"
bssid="${3:-}"
keymgmt="${4:-wpa-psk}"

case "$mode" in connect|rekey) ;; *) exit 2 ;; esac
case "$keymgmt" in wpa-psk|sae) ;; *) exit 2 ;; esac
[[ -n "$ssid" && "$ssid" != *$'\n'* ]] || exit 2
if [[ -n "$bssid" ]]; then
  [[ "$bssid" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || exit 2
  bssid="${bssid^^}"
fi

IFS= read -r PSK || exit 1
[[ -n "$PSK" ]] || exit 1

runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
tmp="$(mktemp "$runtime/qs-wifi.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
printf '802-11-wireless-security.psk:%s\n' "$PSK" > "$tmp"
unset PSK

field() {
  nmcli -t --escape no -g "$1" connection show uuid "$2" 2>/dev/null || true
}

name_taken() {
  local n
  while IFS= read -r n; do
    [[ "$n" == "$1" ]] && return 0
  done < <(nmcli -t --escape no -g NAME connection show)
  return 1
}

uuid=""
unpinned=""
while IFS= read -r line; do
  u="${line%%:*}"
  [[ "${line#*:}" == "802-11-wireless" && -n "$u" ]] || continue
  [[ "$(field 802-11-wireless.ssid "$u")" == "$ssid" ]] || continue
  pinned="$(field 802-11-wireless.bssid "$u")"
  if [[ -n "$pinned" ]]; then
    if [[ -n "$bssid" && "${pinned^^}" == "$bssid" ]]; then
      uuid="$u"
      break
    fi
    continue
  fi
  if [[ -z "$unpinned" ]]; then
    unpinned="$u"
  fi
  if [[ -z "$bssid" ]]; then
    break
  fi
done < <(nmcli -t --escape no -g UUID,TYPE connection show)
[[ -n "$uuid" ]] || uuid="$unpinned"

if [[ -z "$uuid" ]]; then
  [[ "$mode" == "connect" ]] || exit 3
  uuid="$(cat /proc/sys/kernel/random/uuid)"
  name="$ssid"
  n=1
  while name_taken "$name"; do
    n=$((n + 1))
    name="$ssid $n"
  done
  nmcli connection add type wifi con-name "$name" ifname '*' connection.uuid "$uuid" \
    ssid "$ssid" wifi-sec.key-mgmt "$keymgmt" >/dev/null
fi

nmcli connection modify uuid "$uuid" wifi-sec.psk-flags 0
up=(connection up uuid "$uuid" passwd-file "$tmp")
if [[ -n "$bssid" ]]; then
  up+=(ap "$bssid")
fi
nmcli "${up[@]}"
