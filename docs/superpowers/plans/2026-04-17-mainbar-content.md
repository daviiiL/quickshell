# Main Bar Content Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder "Main Bar" label in `modules/MainBar.qml` with the render.com-inspired populated bar validated in the HTML preview (clock + workspaces + running-apps dock + network/brightness/volume/battery status + notification bell).

**Architecture:** Split the bar into focused per-component QML files under `modules/mainbar/`. A reusable `MainBarButton.qml` base supplies the hover/click shell; each status/notification/dock button composes it with an SVG icon and optional label. Status buttons expose an `activated` signal and a stub handler (`onActivated: {}` with a clear TODO) so the overlay-spawning mechanism is wired in place but does nothing yet — per the user's explicit direction. Real clock/workspace/volume/brightness/battery/notification values come from the existing services (`DateTime`, `SystemNiri`, `SystemAudio`, `Brightness`, `Power`, `Notifications`). The dock uses a hardcoded 6-app placeholder model (Firefox/Terminal/VS Code/Slack/Discord/Spotify) matching the HTML preview, with a TODO to wire real running-app data later. SVG icons are moved to `assets/icons/` as project assets.

**Tech Stack:** Quickshell (QML) — `Image` for SVG rendering, `MouseArea` for hover/click, `transform: Translate` + clip-path equivalent (`Shape`/`ShapePath` OR `Rectangle` with `layer.effect`) for the slanted battery fill, `Repeater` for workspace tiles and dock items. Existing services under `services/`. Existing widgets in `widgets/` (e.g. `StyledText`) reused where sensible; otherwise plain `Text` with theme tokens.

**Design source of truth:** `docs/superpowers/previews/mainbar.html` (the validated live preview) and its extracted palette/type/sizing values, distilled into `common/Theme.qml` and `common/Colors.qml` tokens below.

**User preference for this repo:** Do NOT run `git commit`. Every task below writes/edits files only; commits are the user's call. Classic TDD does not apply — this is pure display QML with no test harness, so verification steps are `qmllint` (per file) + a single end-to-end `qs -p ...` launch at the end with the user present.

---

## File plan

| Action | Path | Responsibility |
| --- | --- | --- |
| Move | `docs/superpowers/previews/icons/*.svg` → `assets/icons/*.svg` | Move the 9 validated icons into the project's production asset tree |
| Modify | `common/Colors.qml` | Append render-inspired mainbar tokens (barBg, hair, hairHot, inkDim/Dimmer/Faint, barAccent, live) alongside the existing Material palette |
| Modify | `common/Theme.qml` | Append mainbar sizing tokens inside `ThemeStyle` |
| Create | `modules/mainbar/MainBarButton.qml` | Reusable hoverable button base (inner `Rectangle` + `MouseArea` + `activated` signal) |
| Create | `modules/mainbar/LiveDot.qml` | Pulsing 6-px lime "shell live" dot |
| Create | `modules/mainbar/ClockView.qml` | `HH:MM` time with blinking separator + `Ddd DD Mmm` date, both wired to `DateTime` |
| Create | `modules/mainbar/Workspaces.qml` | Row of 32×32 workspace tiles bound to `SystemNiri` |
| Create | `modules/mainbar/DockItem.qml` | Single 34×34 dock tile with icon, focused/running states, optional unread badge |
| Create | `modules/mainbar/Dock.qml` | Row of `DockItem`s fed by a hardcoded placeholder model (wires up real data later) |
| Create | `modules/mainbar/NetworkButton.qml` | Ethernet icon + `eth0` label, composes `MainBarButton`, stubs `onActivated` |
| Create | `modules/mainbar/BrightnessButton.qml` | Sun-icon + `%` label bound to `Brightness`, stubs `onActivated` |
| Create | `modules/mainbar/VolumeButton.qml` | Speaker icon + `%` label bound to `SystemAudio`, stubs `onActivated` |
| Create | `modules/mainbar/BatteryButton.qml` | Rounded capsule with slanted light-grey fill + `%` label bound to `Power`, stubs `onActivated`; visible only when `GlobalStates.isLaptop` |
| Create | `modules/mainbar/NotificationButton.qml` | Bell icon + count pill bound to `Notifications.popups.length`, stubs `onActivated` |
| Modify | `modules/MainBar.qml` | Replace the single centered "Main Bar" label with a `RowLayout` composing all sub-components into three groups (left: live-dot + clock + workspaces; center: dock; right: status-cluster + notification); keep `WlrLayer.Top`, anchors, `exclusiveZone`, focused-mode hiding |

All new `.qml` files use `pragma ComponentBehavior: Bound` and import `qs.common` / `qs.services` as needed. No `qs.widgets` import unless a file uses a specific widget (only `ClockView.qml` may use `StyledText`).

---

## Task 1: Move SVG icons to the project asset tree

**Files:**
- Move: `docs/superpowers/previews/icons/ethernet.svg` → `assets/icons/ethernet.svg`
- Move: `docs/superpowers/previews/icons/wifi-1.svg` → `assets/icons/wifi-1.svg`
- Move: `docs/superpowers/previews/icons/wifi-2.svg` → `assets/icons/wifi-2.svg`
- Move: `docs/superpowers/previews/icons/wifi-3.svg` → `assets/icons/wifi-3.svg`
- Move: `docs/superpowers/previews/icons/brightness-1.svg` → `assets/icons/brightness-1.svg`
- Move: `docs/superpowers/previews/icons/brightness-2.svg` → `assets/icons/brightness-2.svg`
- Move: `docs/superpowers/previews/icons/brightness-3.svg` → `assets/icons/brightness-3.svg`
- Move: `docs/superpowers/previews/icons/volume.svg` → `assets/icons/volume.svg`
- Move: `docs/superpowers/previews/icons/bell.svg` → `assets/icons/bell.svg`

- [ ] **Step 1: Create the target directory**

Run: `mkdir -p /home/davidas/.config/quickshell/assets/icons`

- [ ] **Step 2: Move all 9 files**

Run:
```sh
mv /home/davidas/.config/quickshell/docs/superpowers/previews/icons/*.svg /home/davidas/.config/quickshell/assets/icons/
```

- [ ] **Step 3: Update the HTML preview to point at the new location**

Modify `docs/superpowers/previews/mainbar.html`:

The preview references icons inline (`<svg>…</svg>`) — no filesystem paths to update. **No change required.** Skip this step if the earlier grep confirms zero `icons/` references in the HTML.

Verify by running: `grep -c 'icons/' /home/davidas/.config/quickshell/docs/superpowers/previews/mainbar.html`
Expected: `0`.

- [ ] **Step 4: Verify the assets directory is populated**

Run: `ls /home/davidas/.config/quickshell/assets/icons/`

Expected output (alphabetical):
```
bell.svg
brightness-1.svg
brightness-2.svg
brightness-3.svg
ethernet.svg
volume.svg
wifi-1.svg
wifi-2.svg
wifi-3.svg
```

---

## Task 2: Extend `common/Colors.qml` with mainbar tokens

**Files:**
- Modify: `common/Colors.qml` — append new properties at the end of the `Singleton` block (just before the closing `}`), after the existing `success`/`warning` block.

- [ ] **Step 1: Read current `Colors.qml` end**

Open `common/Colors.qml`. Confirm it ends with `readonly property color warning: "#ffd4ab"` followed by `}`.

- [ ] **Step 2: Append mainbar tokens**

Insert these lines immediately **before** the final closing `}`:

```qml

    // ——— Main-bar tokens (render.com-inspired grey scale) ———
    readonly property color barBg:      "#0a0a0a"   // bar background (slightly darker than surface)
    readonly property color hair:       "#272727"   // hairline divider
    readonly property color hairHot:    "#3a3a3a"   // hairline on hover
    readonly property color inkDim:     "#8f8f8f"   // secondary text / resting icon
    readonly property color inkDimmer:  "#6b6b6b"   // tertiary text / numeric values at rest
    readonly property color inkFaint:   "#4d4d4d"   // quaternary — running-indicator underline
    readonly property color barAccent:  "#e3e3e3"   // light-grey accent (active state, notif pill, battery fill)
    readonly property color live:       "#5dc70a"   // lime — "live / online" functional signal
```

- [ ] **Step 3: Syntax check**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/common/Colors.qml`

Expected: warnings only for unresolved imports (`Quickshell`). No errors.

---

## Task 3: Extend `common/Theme.qml` with mainbar sizing tokens

**Files:**
- Modify: `common/Theme.qml` — append inside `component ThemeStyle: QtObject { … }`, after the existing `sidePanelWidth` property.

- [ ] **Step 1: Locate the `ThemeStyle` block**

Open `common/Theme.qml`. The block currently ends at:

```qml
        readonly property int mainBarHeight: 48
        readonly property int sidePanelWidth: 320
        readonly property int borderWidth: 1
        readonly property int iconSize: 24
    }
```

- [ ] **Step 2: Insert mainbar sizing tokens after `sidePanelWidth`**

Replace:

```qml
        readonly property int mainBarHeight: 48
        readonly property int sidePanelWidth: 320
        readonly property int borderWidth: 1
        readonly property int iconSize: 24
```

with:

```qml
        readonly property int mainBarHeight: 48
        readonly property int sidePanelWidth: 320
        readonly property int borderWidth: 1
        readonly property int iconSize: 24

        // main-bar sizing
        readonly property int mainBarSubGroupPadX:   14
        readonly property int mainBarButtonHeight:   30
        readonly property int mainBarButtonPadX:     9
        readonly property int mainBarButtonGap:      7
        readonly property int mainBarButtonRadius:   3
        readonly property int mainBarIconSize:       14
        readonly property int mainBarDockIconSize:   18
        readonly property int mainBarDockItemSize:   34
        readonly property int mainBarDockItemGap:    3
        readonly property int mainBarDockItemRadius: 4
        readonly property int mainBarWsSize:         32
        readonly property int mainBarWsGap:          8
        readonly property int mainBarWsRadius:       3
        readonly property int mainBarHairWidth:      1
        readonly property int mainBarBatteryWidth:   44
        readonly property int mainBarBatteryHeight:  12
        readonly property int mainBarBatterySlant:   6
```

- [ ] **Step 3: Syntax check**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/common/Theme.qml`

Expected: warnings only for unresolved imports. No errors.

---

## Task 4: Create `modules/mainbar/MainBarButton.qml`

**Files:**
- Create: `modules/mainbar/` (new directory)
- Create: `modules/mainbar/MainBarButton.qml`

- [ ] **Step 1: Create the directory**

Run: `mkdir -p /home/davidas/.config/quickshell/modules/mainbar`

- [ ] **Step 2: Write `MainBarButton.qml`**

Create the file with exactly this content:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    // public interface
    property bool hovered: mouseArea.containsMouse
    property bool active: false
    property int contentPadX: Theme.ui.mainBarButtonPadX
    property int contentGap: Theme.ui.mainBarButtonGap
    default property alias content: row.data

    signal activated()

    implicitHeight: Theme.ui.mainBarButtonHeight
    implicitWidth: row.implicitWidth + 2 * contentPadX
    radius: Theme.ui.mainBarButtonRadius

    color: {
        if (root.active)   return "transparent";
        if (root.hovered)  return Colors.surfaceContainerLow;
        return "transparent";
    }
    border.width: Theme.ui.mainBarHairWidth
    border.color: {
        if (root.active)  return Colors.hairHot;
        if (root.hovered) return Colors.hair;
        return "transparent";
    }

    Behavior on color        { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.contentPadX
        anchors.rightMargin: root.contentPadX
        spacing: root.contentGap
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
```

Design notes encoded in the file:
- Rest color transparent; on hover we tint with `Colors.surfaceContainerLow` (close to the `#141414` surface token in the HTML).
- Border transparent → `Colors.hair` on hover → `Colors.hairHot` when the button is `active`.
- The reusable `activated` signal is the "overlay spawn trigger." Consumers connect to it (currently with a TODO).

- [ ] **Step 3: Syntax check**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/MainBarButton.qml`

Expected: warnings only for unresolved `qs.common` import + unqualified `Theme`/`Colors`. No errors.

---

## Task 5: Create `modules/mainbar/LiveDot.qml`

**Files:**
- Create: `modules/mainbar/LiveDot.qml`

- [ ] **Step 1: Write the file**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Item {
    id: root

    implicitWidth: 6
    implicitHeight: 6

    Rectangle {
        id: dot
        anchors.centerIn: parent
        width: 6
        height: 6
        radius: width / 2
        color: Colors.live
    }

    // pulsing halo — mirrors the HTML @keyframes pulse
    Rectangle {
        id: halo
        anchors.centerIn: parent
        width: dot.width
        height: dot.height
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: Qt.alpha(Colors.live, 0.55)
        opacity: 1

        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation { from: 1;  to: 2.3; duration: 1400; easing.type: Easing.OutCubic }
            NumberAnimation { from: 2.3; to: 1;  duration: 1000; easing.type: Easing.InQuad }
        }
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0; duration: 1400; easing.type: Easing.OutCubic }
            NumberAnimation { from: 0; to: 1; duration: 1000 }
        }
    }
}
```

- [ ] **Step 2: Syntax check**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/LiveDot.qml`

Expected: warnings only. No errors.

---

## Task 6: Create `modules/mainbar/ClockView.qml`

**Files:**
- Create: `modules/mainbar/ClockView.qml`

- [ ] **Step 1: Inspect the existing `DateTime` service so the bindings are correct**

Read the first 60 lines of `services/DateTime.qml` to identify the exposed properties. Expect properties like `time`, `date`, `hour`, `minute`, or a full `Date` object. Adapt the binding in Step 2 to match what's actually exported.

(If `DateTime` exposes a raw `Date` under a property named `now`, the binding becomes `Qt.formatDateTime(DateTime.now, "HH")`; if it exposes pre-formatted strings, use those directly.)

- [ ] **Step 2: Write `ClockView.qml`, adapting the binding to what `DateTime` actually exposes**

Write the file with the following shape. Replace every `DateTime.<prop>` reference in the bindings with the actual DateTime property names (from Step 1):

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

RowLayout {
    id: root
    spacing: 10

    // If DateTime exposes a raw QDateTime, derive the formatted strings from it:
    readonly property string hhmm: Qt.formatDateTime(DateTime.now, "HH:mm")
    readonly property string ddate: Qt.formatDateTime(DateTime.now, "ddd dd MMM")

    RowLayout {
        spacing: 0

        Text {
            text: root.hhmm.slice(0, 2)
            font.family: Theme.font.family.departureMono
            font.pixelSize: 14
            font.weight: Font.Medium
            color: Colors.fgSurface
            font.letterSpacing: 0.4
        }

        Text {
            id: sep
            text: ":"
            font.family: Theme.font.family.departureMono
            font.pixelSize: 14
            font.weight: Font.Medium
            color: Colors.barAccent
            Layout.leftMargin: 0
            Layout.rightMargin: 0

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 1;    to: 0.35; duration: 1000 }
                NumberAnimation { from: 0.35; to: 1;    duration: 1000 }
            }
        }

        Text {
            text: root.hhmm.slice(3, 5)
            font.family: Theme.font.family.departureMono
            font.pixelSize: 14
            font.weight: Font.Medium
            color: Colors.fgSurface
            font.letterSpacing: 0.4
        }
    }

    // vertical hairline divider between HH:MM and date
    Rectangle {
        Layout.fillHeight: false
        Layout.preferredHeight: 14
        Layout.preferredWidth: 1
        color: Colors.hair
    }

    Text {
        text: root.ddate.toUpperCase()
        font.family: Theme.font.family.departureMono
        font.pixelSize: 11
        color: Colors.inkDim
        font.letterSpacing: 1.0
    }
}
```

**If Step 1 reveals `DateTime` does not expose `now`:** replace the two `Qt.formatDateTime(DateTime.now, ...)` calls with whatever DateTime actually exports. Do not invent properties.

- [ ] **Step 3: Syntax check**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/ClockView.qml`

Expected: warnings only. If qmllint flags `DateTime.<prop>` as unresolved, ignore — that's the normal cross-module unresolved warning. If it flags a property as "not found on DateTime," the binding from Step 2 was wrong — re-inspect the service and fix.

---

## Task 7: Create `modules/mainbar/Workspaces.qml`

**Files:**
- Create: `modules/mainbar/Workspaces.qml`

- [ ] **Step 1: Inspect `SystemNiri` service**

Read `services/SystemNiri.qml` to identify what workspace data it exposes. Most likely shape: a `workspaces` list property (array of `{id, name, occupied, focused}`), plus a function to switch workspace. Note the exact property/function names — they're needed in Step 2.

- [ ] **Step 2: Write `Workspaces.qml`**

Adapt `SystemNiri.workspaces` / `SystemNiri.focusedWorkspace` / `SystemNiri.switchTo(id)` to the actual property and function names from Step 1. The template below assumes those names:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

RowLayout {
    id: root
    spacing: Theme.ui.mainBarWsGap

    Repeater {
        // Fallback to 5 dummy workspaces if SystemNiri exposes no list yet.
        model: (SystemNiri.workspaces && SystemNiri.workspaces.length > 0)
                 ? SystemNiri.workspaces
                 : [{id:1, occupied:true, focused:false},
                    {id:2, occupied:true, focused:true},
                    {id:3, occupied:true, focused:false},
                    {id:4, occupied:false, focused:false},
                    {id:5, occupied:false, focused:false}]

        Rectangle {
            id: tile
            required property var modelData

            implicitWidth: Theme.ui.mainBarWsSize
            implicitHeight: Theme.ui.mainBarWsSize
            radius: Theme.ui.mainBarWsRadius
            border.width: Theme.ui.mainBarHairWidth

            color: modelData.focused ? Qt.alpha(Colors.barAccent, 0.05) : "transparent"
            border.color: modelData.focused
                ? Colors.barAccent
                : (hoverArea.containsMouse ? Colors.hairHot : Colors.hair)

            Behavior on color        { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: modelData.id
                font.family: Theme.font.family.departureMono
                font.pixelSize: 13
                font.weight: Font.Medium
                color: modelData.focused ? Colors.barAccent
                                         : (hoverArea.containsMouse ? Colors.fgSurface : Colors.inkDim)
            }

            // occupied-dot in top-right corner
            Rectangle {
                visible: modelData.occupied
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 5
                anchors.rightMargin: 5
                width: 4
                height: 4
                radius: 2
                color: modelData.focused ? Colors.barAccent : Colors.inkFaint
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (SystemNiri.switchTo) {
                        SystemNiri.switchTo(tile.modelData.id);
                    }
                    // no-op if SystemNiri exposes a different name; wire in a follow-up.
                }
            }
        }
    }
}
```

**If Step 1 shows `SystemNiri.workspaces` doesn't exist or has a different shape:** the Repeater's fallback model (the hardcoded 5 entries) still makes the component render and prevents a QML crash. Keep the fallback. Replace `SystemNiri.workspaces` / `SystemNiri.switchTo` with the real names found in Step 1; if none exist yet, remove those references and leave the Repeater on the hardcoded fallback model plus add `// TODO: wire to SystemNiri once service exposes workspaces`.

- [ ] **Step 3: Syntax check**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/Workspaces.qml`

Expected: warnings only. No errors.

---

## Task 8: Create `modules/mainbar/DockItem.qml` and `modules/mainbar/Dock.qml`

**Files:**
- Create: `modules/mainbar/DockItem.qml`
- Create: `modules/mainbar/Dock.qml`

- [ ] **Step 1: Write `DockItem.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Rectangle {
    id: root

    property string iconSource: ""
    property string label: ""
    property bool running: true
    property bool focused: false
    property int unreadCount: 0

    signal activated()

    implicitWidth: Theme.ui.mainBarDockItemSize
    implicitHeight: Theme.ui.mainBarDockItemSize
    radius: Theme.ui.mainBarDockItemRadius
    border.width: Theme.ui.mainBarHairWidth

    readonly property bool hovered: hoverArea.containsMouse

    color: {
        if (root.focused) return Qt.alpha(Colors.barAccent, 0.05);
        if (root.hovered) return Colors.surfaceContainerLow;
        return "transparent";
    }
    border.color: {
        if (root.focused) return Colors.hairHot;
        if (root.hovered) return Colors.hair;
        return "transparent";
    }

    Behavior on color        { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Image {
        anchors.centerIn: parent
        width: Theme.ui.mainBarDockIconSize
        height: Theme.ui.mainBarDockIconSize
        source: root.iconSource
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        smooth: true
        // NOTE: QML Image recolors SVGs only via shader effects; for this scaffold the SVGs
        // are single-color strokes using `stroke="currentColor"` which defaults to black when
        // rendered directly. A follow-up can wrap this in a ColorOverlay to tint per theme.
    }

    // running indicator — short underline at bottom
    Rectangle {
        visible: root.running
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 3
        width: root.focused ? 16 : 12
        height: 2
        radius: 1
        color: root.focused ? Colors.barAccent : Colors.inkFaint
        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    // unread badge pill
    Rectangle {
        visible: root.unreadCount > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 2
        anchors.rightMargin: 2
        height: 14
        width: Math.max(14, badgeLabel.implicitWidth + 6)
        radius: 7
        color: Colors.barAccent
        border.width: 2
        border.color: Colors.barBg

        Text {
            id: badgeLabel
            anchors.centerIn: parent
            text: root.unreadCount
            font.family: Theme.font.family.departureMono
            font.pixelSize: 9
            font.weight: Font.Bold
            color: Colors.barBg
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
```

- [ ] **Step 2: Syntax check `DockItem.qml`**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/DockItem.qml`

Expected: warnings only.

- [ ] **Step 3: Write `Dock.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

RowLayout {
    id: root
    spacing: Theme.ui.mainBarDockItemGap

    // Hardcoded placeholder model matching the validated HTML preview.
    // TODO: wire to real running-apps data (e.g., SystemNiri windows enumeration or a new service).
    readonly property var items: [
        { id: "firefox",  icon: "assets/icons/firefox.svg",  label: "Firefox",  focused: true,  unread: 0 },
        { id: "terminal", icon: "assets/icons/terminal.svg", label: "Terminal", focused: false, unread: 0 },
        { id: "vscode",   icon: "assets/icons/vscode.svg",   label: "VS Code",  focused: false, unread: 0 },
        { id: "slack",    icon: "assets/icons/slack.svg",    label: "Slack",    focused: false, unread: 2 },
        { id: "discord",  icon: "assets/icons/discord.svg",  label: "Discord",  focused: false, unread: 0 },
        { id: "spotify",  icon: "assets/icons/spotify.svg",  label: "Spotify",  focused: false, unread: 0 }
    ]

    Repeater {
        model: root.items

        DockItem {
            required property var modelData

            iconSource: modelData.icon
            label:      modelData.label
            focused:    modelData.focused
            running:    true
            unreadCount: modelData.unread ?? 0

            onActivated: {
                // TODO: spawn overlay / switch focus to running app once overlay mechanism exists.
            }
        }
    }
}
```

Note on icons: the 6 dock icons (`firefox.svg`, `terminal.svg`, `vscode.svg`, `slack.svg`, `discord.svg`, `spotify.svg`) are **not** in the Task-1 asset move (those were status icons only). For the scaffold, create minimal placeholder files **in this same task** so the dock isn't broken:

- [ ] **Step 4: Write placeholder dock icon files**

Create each of `assets/icons/firefox.svg`, `terminal.svg`, `vscode.svg`, `slack.svg`, `discord.svg`, `spotify.svg` with the corresponding content from the HTML preview's inline `<svg>` (they're already authored inside `docs/superpowers/previews/mainbar.html`).

Each file uses the same header as the status icons:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
```

Paths per app (copied verbatim from the preview):

- `firefox.svg`:
  ```xml
  <circle cx="12" cy="12" r="9"/>
  <path d="M3 12h18"/>
  <path d="M12 3c3 3 3 15 0 18"/>
  <path d="M12 3c-3 3-3 15 0 18"/>
  ```
- `terminal.svg`:
  ```xml
  <rect x="3" y="5" width="18" height="14" rx="2"/>
  <path d="M7 10l3 2-3 2"/>
  <path d="M12 15h5"/>
  ```
- `vscode.svg`:
  ```xml
  <path d="M8 8l-4 4 4 4"/>
  <path d="M16 8l4 4-4 4"/>
  <path d="M14 6l-4 12"/>
  ```
- `slack.svg`:
  ```xml
  <path d="M9 4v16M15 4v16"/>
  <path d="M4 9h16M4 15h16"/>
  ```
- `discord.svg`:
  ```xml
  <path d="M5 7c0-1 1-2 2-2h10c1 0 2 1 2 2v8c0 1-1 2-2 2h-6l-4 3v-3H7c-1 0-2-1-2-2V7z"/>
  <circle cx="9" cy="11" r="1"/>
  <circle cx="15" cy="11" r="1"/>
  ```
- `spotify.svg`:
  ```xml
  <circle cx="12" cy="12" r="9"/>
  <path d="M7.5 10c3-1 6.5-.5 9.5 1"/>
  <path d="M8 13c2.5-.5 5.5 0 8 1.5"/>
  <path d="M9 16c2 0 4 .3 6 1.5"/>
  ```

- [ ] **Step 5: Syntax check `Dock.qml`**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/Dock.qml`

Expected: warnings only.

- [ ] **Step 6: Verify the new dock icon files exist**

Run: `ls /home/davidas/.config/quickshell/assets/icons/ | grep -E '^(firefox|terminal|vscode|slack|discord|spotify)\.svg$' | wc -l`

Expected output: `6`.

---

## Task 9: Create the five status / notification button components

**Files:**
- Create: `modules/mainbar/NetworkButton.qml`
- Create: `modules/mainbar/BrightnessButton.qml`
- Create: `modules/mainbar/VolumeButton.qml`
- Create: `modules/mainbar/BatteryButton.qml`
- Create: `modules/mainbar/NotificationButton.qml`

Each composes `MainBarButton` and exposes a stubbed `onActivated` handler with an explicit TODO comment marking where the overlay-spawn hook goes. This is the "wire the mechanism but keep it blank" instruction encoded.

- [ ] **Step 1: Write `NetworkButton.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

MainBarButton {
    id: root

    // TODO: wire network state from services/Network.qml once needed.
    property string connectionLabel: "eth0"

    onActivated: {
        // TODO: spawn network overlay window. Mechanism is already in place
        // (MainBarButton emits activated); overlay component wiring is a follow-up.
    }

    Image {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize
        source: "../../assets/icons/ethernet.svg"
        sourceSize.width: Theme.ui.mainBarIconSize * 2
        sourceSize.height: Theme.ui.mainBarIconSize * 2
        smooth: true
    }

    Text {
        text: root.connectionLabel
        color: root.hovered ? Colors.fgSurface : Colors.inkDim
        font.family: Theme.font.family.departureMono
        font.pixelSize: 13
    }
}
```

Relative path: the file is at `modules/mainbar/NetworkButton.qml`, the asset at `assets/icons/ethernet.svg` — two `../` up from the file to the shell root, then `assets/icons/ethernet.svg`. All other button files below use the same pattern.

- [ ] **Step 2: Syntax check `NetworkButton.qml`**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/NetworkButton.qml`

Expected: warnings only.

- [ ] **Step 3: Write `BrightnessButton.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    // Map 0..1 brightness to one of three icons: moon face < 0.15, small sun < 0.55, full sun ≥ 0.55.
    // Fall back to 0.72 (matches the preview) if Brightness service is unavailable.
    readonly property real level: (typeof Brightness !== "undefined" && Brightness.brightness !== undefined)
                                    ? Brightness.brightness
                                    : 0.72

    readonly property string iconKey: {
        if (root.level < 0.15) return "brightness-1";
        if (root.level < 0.55) return "brightness-2";
        return "brightness-3";
    }

    onActivated: {
        // TODO: spawn brightness overlay window.
    }

    Image {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize
        source: "../../assets/icons/" + root.iconKey + ".svg"
        sourceSize.width: Theme.ui.mainBarIconSize * 2
        sourceSize.height: Theme.ui.mainBarIconSize * 2
        smooth: true
    }

    Text {
        text: Math.round(root.level * 100) + "%"
        color: root.hovered ? Colors.fgSurface : Colors.inkDim
        font.family: Theme.font.family.departureMono
        font.pixelSize: 13
    }
}
```

- [ ] **Step 4: Syntax check `BrightnessButton.qml`**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/BrightnessButton.qml`

Expected: warnings only.

- [ ] **Step 5: Write `VolumeButton.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    readonly property real volume: (typeof SystemAudio !== "undefined" && SystemAudio.volume !== undefined)
                                     ? SystemAudio.volume
                                     : 0.42

    onActivated: {
        // TODO: spawn volume / audio overlay window.
    }

    Image {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize
        source: "../../assets/icons/volume.svg"
        sourceSize.width: Theme.ui.mainBarIconSize * 2
        sourceSize.height: Theme.ui.mainBarIconSize * 2
        smooth: true
    }

    Text {
        text: Math.round(root.volume * 100) + "%"
        color: root.hovered ? Colors.fgSurface : Colors.inkDim
        font.family: Theme.font.family.departureMono
        font.pixelSize: 13
    }
}
```

- [ ] **Step 6: Syntax check `VolumeButton.qml`**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/VolumeButton.qml`

Expected: warnings only.

- [ ] **Step 7: Write `BatteryButton.qml` (the slanted capsule)**

The slanted fill uses QtQuick.Shapes to draw a four-point polygon whose right edge tilts. Rounded outer corners come from a `Rectangle` overlay acting as a clipping frame.

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.common
import qs.services

MainBarButton {
    id: root

    visible: GlobalStates.isLaptop

    readonly property real level: (typeof Power !== "undefined" && Power.percentage !== undefined)
                                    ? Power.percentage / 100.0
                                    : 0.78

    onActivated: {
        // TODO: spawn battery / power overlay window.
    }

    // rounded outline
    Rectangle {
        id: capsule
        Layout.preferredWidth:  Theme.ui.mainBarBatteryWidth
        Layout.preferredHeight: Theme.ui.mainBarBatteryHeight
        radius: 3
        color: "transparent"
        border.width: Theme.ui.mainBarHairWidth
        border.color: root.hovered ? Colors.fgSurface : Colors.inkDim
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // inner clipping bounds (inset by 1px to sit inside the border)
        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: 1
            clip: true

            // slanted fill polygon: top-right further LEFT than bottom-right (backward lean),
            // matching the validated HTML preview.
            Shape {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: inner.width * root.level

                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                ShapePath {
                    strokeColor: "transparent"
                    fillColor: Colors.barAccent
                    startX: 0
                    startY: 0
                    PathLine { x: Math.max(0, parent.width - Theme.ui.mainBarBatterySlant); y: 0 }
                    PathLine { x: parent.width; y: inner.height }
                    PathLine { x: 0;            y: inner.height }
                    PathLine { x: 0;            y: 0 }
                }
            }
        }
    }

    Text {
        text: Math.round(root.level * 100) + "%"
        color: root.hovered ? Colors.fgSurface : Colors.inkDim
        font.family: Theme.font.family.departureMono
        font.pixelSize: 13
    }
}
```

If the implementer confirms `QtQuick.Shapes` is unavailable (it's a separate Qt6 module), fall back to a plain `Rectangle` fill without the slant and add `// TODO: reintroduce slanted fill via Shape when QtQuick.Shapes is available`. Do **not** silently change the visual.

- [ ] **Step 8: Syntax check `BatteryButton.qml`**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/BatteryButton.qml`

Expected: warnings only (unresolved `Power`/`GlobalStates` are expected).

- [ ] **Step 9: Write `NotificationButton.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    readonly property int unread: (typeof Notifications !== "undefined"
                                   && Notifications.popups !== undefined)
                                    ? Notifications.popups.length
                                    : 3  // preview default

    onActivated: {
        // TODO: toggle the existing GlobalStates.rightPanelOpen (or a dedicated
        // notificationCenterOpen flag) once the right-panel surface renders the list.
    }

    contentPadX: 9

    Image {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize
        source: "../../assets/icons/bell.svg"
        sourceSize.width: Theme.ui.mainBarIconSize * 2
        sourceSize.height: Theme.ui.mainBarIconSize * 2
        smooth: true
    }

    Rectangle {
        Layout.preferredHeight: 18
        Layout.preferredWidth: Math.max(18, countLabel.implicitWidth + 10)
        radius: 2
        color: Colors.barAccent
        visible: root.unread > 0
        border.width: 1
        border.color: Qt.alpha("#ffffff", 0.15)

        Text {
            id: countLabel
            anchors.centerIn: parent
            text: root.unread
            color: "#0a0a0a"
            font.family: Theme.font.family.departureMono
            font.pixelSize: 10
            font.weight: Font.Bold
        }
    }
}
```

- [ ] **Step 10: Syntax check `NotificationButton.qml`**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/mainbar/NotificationButton.qml`

Expected: warnings only.

---

## Task 10: Rewrite `modules/MainBar.qml` to compose the sub-components

**Files:**
- Modify: `modules/MainBar.qml`

- [ ] **Step 1: Overwrite the file entirely**

Replace the current placeholder-label version with:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services
import qs.modules.mainbar

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:mainbar"

            anchors {
                bottom: true
                left: true
                right: true
            }

            implicitHeight: Theme.ui.mainBarHeight
            exclusiveZone: Preferences.focusedMode ? 0 : implicitHeight
            visible: !Preferences.focusedMode

            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Colors.barBg

                // top hairline
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }

                // soft grey sliver on top-left (mirrors the HTML gradient ribbon)
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 220
                    height: Theme.ui.mainBarHairWidth
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.alpha(Colors.barAccent, 0.55) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // ─── LEFT GROUP ─────────────────────────
                    RowLayout {
                        spacing: 0
                        Layout.fillHeight: true

                        // sub-group: live dot + clock
                        RowLayout {
                            spacing: 10
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX

                            LiveDot {}
                            ClockView {}
                        }

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        // sub-group: workspaces
                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX
                            Workspaces {}
                        }
                    }

                    // ─── CENTER GROUP: dock ────────────────
                    Item { Layout.fillWidth: true; Layout.fillHeight: true
                        Dock {
                            anchors.centerIn: parent
                        }
                    }

                    // ─── RIGHT GROUP ───────────────────────
                    RowLayout {
                        spacing: 0
                        Layout.fillHeight: true

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        // sub-group: status cluster
                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX

                            NetworkButton     {}
                            BrightnessButton  {}
                            VolumeButton      {}
                            BatteryButton     {}
                        }

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        // sub-group: notification
                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX
                            NotificationButton {}
                        }
                    }
                }
            }
        }
    }
}
```

Notable imports: `import qs.modules.mainbar` — Quickshell auto-discovers the subdirectory as a module. No `qmldir` file needed.

- [ ] **Step 2: Syntax check**

Run: `/usr/lib/qt6/bin/qmllint /home/davidas/.config/quickshell/modules/MainBar.qml`

Expected: warnings only. No errors.

---

## Task 11: End-to-end user verification

**Files:** none (runtime-only)

Subagents cannot visually verify a Wayland shell. Hand these steps to the user. Each step is a concrete observable.

- [ ] **Step 1: Kill any stale quickshell instance**

Run: `qs kill || pkill -f quickshell || true`

- [ ] **Step 2: Launch the new bar**

Run: `qs -p /home/davidas/.config/quickshell shell.qml`

Expected: shell starts cleanly. Any errors in stderr are real — fix inline before proceeding.

- [ ] **Step 3: Visual checks on the bottom bar**

From left to right, the user should see:

1. Pulsing lime dot, then `HH:MM` in DepartureMono with the colon blinking, then a hairline, then the date in uppercase dim grey.
2. Hairline divider.
3. Row of 5 workspace tiles (32×32), one filled with a thin grey border + wash + larger numeral (the "focused" one), all with a small dot in the top-right if occupied.
4. Hairline divider.
5. Center area: 6 dock tiles (34×34) — Firefox / Terminal / VS Code / Slack / Discord / Spotify. Firefox shows the focused treatment (accent border + wider underline); Slack shows a small grey unread badge `2` in the top-right.
6. Hairline divider.
7. Status cluster: `ethernet` icon + `eth0`, brightness sun icon + `%`, speaker icon + `%`, slanted-fill battery capsule + `%`.
8. Hairline divider.
9. Bell icon + grey count pill (`3` from the default preview value).

- [ ] **Step 4: Hover behavior**

Hover each status button. Expected: background tints faintly, hairline border appears, label brightens from `#8f8f8f` to `#e6e0e9`.

- [ ] **Step 5: Click behavior**

Click each status button (network, brightness, volume, battery, notification) and each dock tile. Expected: cursor changes to pointer, visible hover state updates — **and nothing else happens**. This is intentional: the `activated` signal fires but the handlers are stubbed. Confirm no QML errors appear in stderr on click.

- [ ] **Step 6: Focused-mode toggle**

If the user has a UI toggle for `Preferences.focusedMode`, flip it. Expected: entire bar disappears (visibility false) and its exclusive zone releases. Flip back — bar returns.

- [ ] **Step 7: IPC side panels still work**

Run in another terminal: `qs ipc call leftpanel toggle`, then `qs ipc call rightpanel toggle`. Expected: the side panels from the earlier scaffold still slide in correctly — the main bar changes must not break them.

- [ ] **Step 8: Stop the shell**

Ctrl-C in the launch terminal.

- [ ] **Step 9: Summarise the change set to the user**

The following files were created or modified in this plan. Do **not** run `git commit`. Report the list and let the user stage/commit when they choose:

```
 M common/Colors.qml
 M common/Theme.qml
 M modules/MainBar.qml
?? assets/icons/
?? modules/mainbar/
 (moved) docs/superpowers/previews/icons/  →  assets/icons/
```

---

## Notes for the executor

- **No commits:** the user's `feedback_no_autocommits.md` memory is explicit. Do not run `git add` / `git commit` at any point.
- **No test harness:** QML display code, no unit-test framework. Per-task verification is `qmllint` only. Full rendering check happens once, in Task 11.
- **Do not launch `qs` per-task:** it spawns a visible shell on the user's live Wayland session and conflicts with any other running instance. Full launch is reserved for Task 11 with the user present.
- **Service bindings are best-effort:** `ClockView`, `Workspaces`, `BrightnessButton`, `VolumeButton`, `BatteryButton`, `NotificationButton` each have a fallback literal value that matches the HTML preview so the bar renders even if a service lacks the expected property. Every such fallback sits behind a `typeof … !== "undefined"` guard so the real service value takes precedence whenever it exists. Do **not** break this pattern — it keeps the scaffold booting while the services evolve.
- **QtQuick.Shapes availability:** `BatteryButton` requires the `QtQuick.Shapes` QML module for the slanted-fill polygon. On Arch / standard Qt6 installs this is present. If `qmllint` complains the module is missing, the fallback noted in Task 9 Step 7 applies.
- **SVG tinting:** `Image` in QML renders SVGs at the SVG's own stroke color (which is literal `currentColor` → CSS default → black at paint time). The icons will appear **black** initially — this is expected. Tinting via `MultiEffect` or `ShaderEffect` is a follow-up enhancement, not scope for this plan. The user has already validated the bar's layout and structure in HTML; the QML pass is about geometry and wiring, not final pixel polish.
- **Overlay-spawning stubs:** every `onActivated:` currently contains a `TODO` comment pointing at where the overlay hook-up goes. This is the mechanism the user asked to leave blank. Do not delete the handlers — even empty, they demonstrate that the click wiring is live.
