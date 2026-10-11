#!/usr/bin/env bash
# Install the Quickshell GTK theme.
#
#   ./install.sh          # install, dark active
#   ./install.sh light    # install, light active
#   ./install.sh --uninstall
#
# Idempotent. Every file it replaces is backed up once to *.pre-quickshell.
set -euo pipefail

THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$THEME_DIR/lib.sh"

FONT_NAME="Inter Nerd Font Propo 11"

GTK3_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0"
GTK4_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0"
THEMES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
LINK="$THEMES_DIR/$THEME_NAME"

if [ "${1:-}" = "--uninstall" ]; then
  echo "Uninstalling $THEME_NAME…"
  [ -L "$LINK" ] && rm -v "$LINK"
  for f in "$GTK4_CONF/gtk.css" "$GTK3_CONF/settings.ini" "$GTK4_CONF/settings.ini"; do
    if [ -e "$f.pre-quickshell" ]; then
      mv -v "$f.pre-quickshell" "$f"
    elif [ -e "$f" ] && grep -q 'set-scheme.sh' "$f" 2>/dev/null; then
      rm -v "$f"
    fi
  done
  if command -v gsettings >/dev/null 2>&1; then
    gsettings reset org.gnome.desktop.interface gtk-theme  || true
    gsettings reset org.gnome.desktop.interface font-name  || true
  fi
  echo "Done. Restart GTK apps."
  exit 0
fi

scheme="${1:-dark}"
case "$scheme" in dark|light) ;; *) echo "usage: $(basename "$0") [dark|light|--uninstall]" >&2; exit 2 ;; esac

echo "Installing $THEME_NAME GTK theme from $THEME_DIR"

# ── GTK3: expose the theme under a name GTK can find ───────────────────
# GTK3 searches ~/.local/share/themes and ~/.themes for <name>/gtk-3.0/gtk.css.
# A directory symlink is safe here: relative @imports stay inside the link.
mkdir -p "$THEMES_DIR"
if [ -L "$LINK" ]; then
  ln -sfn "$THEME_DIR" "$LINK"
elif [ -e "$LINK" ]; then
  echo "  ! $LINK exists and is not a symlink — leaving it alone." >&2
  echo "    Move it aside and re-run to let GTK3 find this theme." >&2
else
  ln -s "$THEME_DIR" "$LINK"
fi
echo "  GTK3 theme  : $LINK → $THEME_DIR"

# ── Back up anything we are about to rewrite ───────────────────────────
backup_once "$GTK4_CONF/gtk.css"
backup_once "$GTK3_CONF/settings.ini"
backup_once "$GTK4_CONF/settings.ini"

# ── settings.ini: theme name + font, for both toolkits ─────────────────
# libadwaita ignores gtk-theme-name, but plain GTK4 apps honour it, and GTK3
# needs it to load our stylesheet at all.
for conf in "$GTK3_CONF" "$GTK4_CONF"; do
  set_ini_key "$conf/settings.ini" gtk-theme-name        "$THEME_NAME"
  set_ini_key "$conf/settings.ini" gtk-font-name         "$FONT_NAME"
  set_ini_key "$conf/settings.ini" gtk-icon-theme-name   "Adwaita"
  set_ini_key "$conf/settings.ini" gtk-cursor-theme-name "Adwaita"
done
echo "  settings.ini: gtk-theme-name=$THEME_NAME, gtk-font-name=$FONT_NAME"

# ── gsettings: what the settings portal and libadwaita read ────────────
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" || true
  gsettings set org.gnome.desktop.interface font-name "$FONT_NAME"  || true
fi

# ── Scheme (writes the GTK4 loader stub + prefer-dark flags) ───────────
"$THEME_DIR/set-scheme.sh" "$scheme"
