#!/usr/bin/env bash
# Packages needed by ~/.config/niri (darkshell-ultrawide) and
# ~/.config/quickshell (darkshell/niri).
set -euo pipefail

paru -S --needed \
  niri quickshell xwayland-satellite awww shikane swayidle cliphist \
  brightnessctl power-profiles-daemon qt6-5compat qt6-imageformats \
  fcitx5 fcitx5-qt fcitx5-gtk \
  ttf-jetbrains-mono ttf-material-symbols-variable \
  qml-niri nerd-fonts-inter

sudo systemctl enable --now power-profiles-daemon
