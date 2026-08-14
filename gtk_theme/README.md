# Quickshell GTK theme

A GTK3 + GTK4/libadwaita theme override that matches the Quickshell desktop
shell, so GTK apps sit flush with the bar and panels instead of looking like
visitors from another desktop.

## Install

```sh
./install.sh            # install, dark active
./install.sh light      # install, light active
./set-scheme.sh light   # switch scheme later
./install.sh --uninstall
```

Restart GTK apps afterwards. Everything replaced is backed up once to
`*.pre-quickshell`.

## Design source

The palette is not invented — it is transcribed from the shell itself:

| Source | What it provides |
|---|---|
| `../common/Colors.qml` | every colour, both `darkMode` branches |
| `../common/Theme.qml` | radii, padding, border width, font |
| `../preview/*.html` | the same tokens as CSS, used to cross-check |

All three agree, which is what made a faithful port possible.

### Palette

| Token | Dark | Light | Role |
|---|---|---|---|
| `qs_bar_bg` | `#0a0a0a` | `#e4e0e9` | headerbars |
| `qs_panel_bg` | `#0f0f13` | `#f5f2f7` | sidebars |
| `qs_surface` | `#141218` | `#f5f2f7` | window background |
| `qs_surface_lowest` | `#0f0d13` | `#fbf9fc` | content/list views |
| `qs_surface_low` | `#1d1b20` | `#eee9f0` | hover, selected row fill |
| `qs_surface_container` | `#211f26` | `#e3dee6` | cards, popovers |
| `qs_surface_high` | `#2b2930` | `#d4cfd9` | tooltips, menu hover |
| `qs_ink` | `#e6e0e9` | `#1c1820` | primary text |
| `qs_ink_dim` | `#8f8f8f` | `#5b5764` | secondary text |
| `qs_ink_dimmer` | `#6b6b6b` | `#827e8a` | tertiary text |
| `qs_ink_faint` | `#4d4d4d` | `#a8a4b0` | disabled text |
| `qs_hair` | `#272727` | `#d6d1dc` | 1px idle border |
| `qs_hair_hot` | `#3a3a3a` | `#bcb7c2` | 1px hover border |
| `qs_accent` | `#e3e3e3` | `#1c1820` | switches, checks, focus |
| `qs_live` | `#5dc70a` | `#3d8f0a` | success |
| `qs_warn` | `#ffd4ab` | `#a65a1c` | warning |
| `qs_error` | `#f2b8b5` | `#b3261e` | error |

**The accent is monochrome on purpose.** `Colors.qml` defines a Material You
purple (`#d0bcff`) but no preview ever renders it — the shell's actual accent is
`barAccent`, a neutral `#e3e3e3`. Colour is reserved for status. Selected rows
therefore use a `qs_surface_low` fill plus a 2px accent edge rather than a
filled block, mirroring `.row.selected` in `../preview/launcher.html`.

Geometry follows `Theme.qml`: **3px** radius on controls
(`mainBarButtonRadius`), **4px** on containers (`mainBarDockItemRadius`), **8px**
on windows, **1px** hairline borders (`borderWidth`), no gradients or bevels.

## Layout

```
tokens-dark.css     raw @define-color tokens          ← edit colours here
tokens-light.css
gtk-3.0/
  map.css           tokens → Adwaita GTK3 colour names
  widgets.css       geometry + widget rules
  gtk.css           entry: Adwaita light + tokens + map + widgets
  gtk-dark.css      entry: Adwaita dark  + tokens + map + widgets
gtk-4.0/
  map.css           tokens → libadwaita named colours
  widgets.css       geometry + widget rules
  dark.css          entry: tokens-dark  + map + widgets
  light.css         entry: tokens-light + map + widgets
lib.sh              shared shell helpers
```

Both toolkits share the token layer, so a colour change means editing one file.

## How each toolkit is wired

The two are wired differently because they have to be.

**GTK3** finds themes by name. `install.sh` symlinks
`~/.local/share/themes/Quickshell` → this directory and sets
`gtk-theme-name=Quickshell`. GTK3 then picks `gtk.css` or `gtk-dark.css`
automatically from `gtk-application-prefer-dark-theme`.

**GTK4** does not. libadwaita 1.9 ignores `gtk-theme-name` entirely; its only
supported hook is `~/.config/gtk-4.0/gtk.css`, loaded on top of the built-in
stylesheet. `set-scheme.sh` writes a one-line loader there importing `dark.css`
or `light.css`.

## Gotchas worth knowing

Each of these was hit and verified while building the theme.

- **`~/.config/gtk-4.0/gtk.css` must be a real file, not a symlink.** GTK
  resolves relative `@import` URLs against the path it was handed, so a symlink
  would send `../tokens-dark.css` to `~/.config/tokens-dark.css`. The generated
  loader uses an absolute `file://` import instead.
- **GTK 4.22's CSS parser has no `light-dark()`** (it has `color-mix` and
  `oklab`, but not that). One file cannot serve both schemes, which is why
  scheme switching rewrites the loader rather than toggling a media query.
- **Never set `gtk-application-prefer-dark-theme` in `gtk-4.0/settings.ini`.**
  libadwaita logs `Using GtkSettings:gtk-application-prefer-dark-theme with
  libadwaita is unsupported` once per app launch and ignores it. `set-scheme.sh`
  actively removes it there while keeping it for GTK3, which does need it.
- **The CSD shadow must be byte-identical in `:backdrop`.** Both toolkits derive
  a client-side-decorated toplevel's invisible border from the decoration
  node's box-shadow *extents* (`decoration` on GTK3, `window.csd` on GTK4),
  recomputed per state. A backdrop shadow with a different offset or blur
  therefore moves the Wayland surface origin every time the window gains or
  loses focus — and because Adwaita also sets `transition: 200ms ease-out` on
  `decoration:backdrop`, it moves *continuously* across those 200ms. Firefox
  repaints its entire surface at each step, which reads as a flash on focus
  in/out. Measured with `WAYLAND_DEBUG=1`: `set_window_geometry` origin swept
  `34,30 → 68,60` through ~19 intermediate values per focus toggle. Adwaita
  avoids this by leading its backdrop shadow with a fully transparent copy of
  the active one (`0 3px 9px 1px transparent, …`) purely to pin the extents.
  This theme drops the blurred shadow altogether — niri already frames windows
  with gaps plus a focus ring — and keeps only the constant 1px hairline.

- **`/*` inside a comment is a parse error, not a nested comment.** GTK's CSS
  parser logs `Theme parsing error: … '/*' in comment block` and it surfaces on
  every app launch. Writing a glob like `preview/*.html` in a header comment is
  enough to trigger it.

- **Scale sliders must stay larger than twice Adwaita's negative margin.**
  Adwaita pulls the slider over the trough with `margin: -7px`; a `min-width`
  below 14px computes negative and GTK floods stderr with
  `reported min width -N, but sizes must be >= 0`. Slider size and margin are
  kept in step at `18 - 2*7 = 4`.

## WebKitGTK views

Both `webkit2gtk-4.1` (GTK3) and `webkitgtk-6.0` (GTK4) read
`gtk-application-prefer-dark-theme`, but GTK4 webviews also resolve the scheme
from `gsettings … color-scheme`. Verified with a `prefers-color-scheme` probe
page in both `MiniBrowser` builds: both report **dark** under this theme, and
the surrounding GTK chrome is themed.

Page *content* is still the page's own responsibility — a site with no
`prefers-color-scheme: dark` rules stays light. The theme sets the webview
widget background to `qs_surface_lowest` so nothing flashes white behind it.

## Keeping in sync

`tokens-*.css` mirrors `../common/Colors.qml` by hand. If you change a colour
there, change it here — the token names match the QML property names to make
that mechanical.
