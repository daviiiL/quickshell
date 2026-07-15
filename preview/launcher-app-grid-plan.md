# App Launcher Grid Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the app launcher a grid empty-state — when the search field is empty, show a tabbed grid (`Pinned & Frequent` + `All Apps`) instead of nothing; typing still restores the existing fuzzy results list unchanged.

**Architecture:** The `AppLauncher` service becomes the single data source (search results + `pinnedApps`/`frequentApps`/`allApps` + `launch()`/`togglePin()`). `Preferences` gains two persisted JSON-string fields backing launch frecency and pins. Two new components under `components/applauncher/` (`AppGridCell`, `AppGrid`) render the empty-state; `AppLauncherPanel` swaps between the grid and the existing results list based on `AppLauncher.query`.

**Tech Stack:** QML (Quickshell), `Quickshell.Io.JsonAdapter` for persistence, `DesktopEntries`/`AppSearch` for the app catalogue.

---

## How to run & verify (read first)

This project has **no automated test suite, linter, or formatter** (see `CLAUDE.md`). The dev loop is: edit a `.qml`, then re-run / hot-reload Quickshell and observe. Each task below therefore ends with a concrete **manual verification** instead of `pytest`.

- **Run the shell:** from the repo root, `qs` (or `quickshell`). If a shell is already running it hot-reloads on file save. Keep the launching terminal visible — QML errors/warnings print to stderr there.
- **Open the launcher:** `qs ipc call appLauncher toggle` (or your bound key).
- **Inspect persistence:** `cat ~/.cache/quickshell_preferences.json | python3 -m json.tool`.
- **"Expected: no errors"** means: after reload, the launching terminal shows no new `QML ...: ` warnings/errors mentioning `AppLauncher`, `AppGrid`, `AppGridCell`, or `Preferences`.

Commit after every task. Commit message trailer for every commit:

```
Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## File structure

**Create:**
- `components/applauncher/AppGridCell.qml` — one app cell: icon tile + name, pin dot, hover pin button, selection visuals. Emits `launch()`, `togglePin()`, `hovered()`.
- `components/applauncher/AppGrid.qml` — empty-state view: tab strip, Pinned/Frequent sections (or All grid), 2D keyboard navigation, scroll-to-selected. Reads lists from `AppLauncher`.

**Modify:**
- `services/Preferences.qml` — add persisted `appUsageJson`/`pinnedAppsJson` (strings) + `appUsage`/`pinnedApps` (parsed `var`) + helpers `recordLaunch`, `isPinned`, `setPinned`.
- `services/AppLauncher.qml` — add `allApps`/`pinnedApps`/`frequentApps`, `frecencyScore`, `isPinned`, `togglePin`, `launch`; route `results[].execute` through `launch`.
- `modules/AppLauncherPanel.qml` — insert `AppGrid` into `contentColumn` (visible when query empty), wire focus/keys, make the footer context-aware, reset grid on close.

**Unchanged:** `components/applauncher/AppLauncherItem.qml` — its `onClicked` calls `item.execute()`, which now routes through `AppLauncher.launch`, so search launches feed frecency for free.

---

## Task 1: Persist launch usage and pins in Preferences

**Files:**
- Modify: `services/Preferences.qml`

- [ ] **Step 1: Add the root-level state properties**

In `services/Preferences.qml`, after the `property bool focusedMode` line (currently line 15), add:

```qml
    property var appUsage: ({})    // { [appId]: { count: int, last: epochMillis } }
    property var pinnedApps: []     // ordered list of appId strings
```

- [ ] **Step 2: Add the persistence helper functions**

Immediately before the `Io.JsonAdapter { id: defaultAdapter` block (currently line 81), add:

```qml
    function recordLaunch(appId: string): void {
        if (!appId)
            return;
        const usage = Object.assign({}, root.appUsage);
        const prev = usage[appId] || { "count": 0, "last": 0 };
        usage[appId] = { "count": prev.count + 1, "last": Date.now() };
        root.appUsage = usage;
        defaultAdapter.appUsageJson = JSON.stringify(usage);
    }

    function isPinned(appId: string): bool {
        return root.pinnedApps.indexOf(appId) !== -1;
    }

    function setPinned(appId: string, pinned: bool): void {
        if (!appId)
            return;
        const list = root.pinnedApps.slice();
        const idx = list.indexOf(appId);
        if (pinned && idx === -1)
            list.push(appId);
        else if (!pinned && idx !== -1)
            list.splice(idx, 1);
        else
            return;
        root.pinnedApps = list;
        defaultAdapter.pinnedAppsJson = JSON.stringify(list);
    }
```

- [ ] **Step 3: Add the adapter (persisted) properties**

Inside the `Io.JsonAdapter { id: defaultAdapter ... }` block, after `property bool focusedMode` (currently line 89), add:

```qml
        property string appUsageJson: "{}"
        property string pinnedAppsJson: "[]"
```

- [ ] **Step 4: Hydrate root state in `onLoaded`**

Inside `prefFileView.onLoaded`, after `root.focusedMode = defaultAdapter.focusedMode;` (currently line 110) and before `root.isLoaded = true;`, add:

```qml
            try { root.appUsage = JSON.parse(defaultAdapter.appUsageJson || "{}"); }
            catch (e) { root.appUsage = ({}); }
            try { root.pinnedApps = JSON.parse(defaultAdapter.pinnedAppsJson || "[]"); }
            catch (e) { root.pinnedApps = []; }
```

- [ ] **Step 5: Set first-run defaults in `onLoadFailed`**

Inside `prefFileView.onLoadFailed`, after `root.focusedMode = false;` (currently line 127) and before `root.isLoaded = true;`, add:

```qml
            defaultAdapter.appUsageJson = "{}";
            defaultAdapter.pinnedAppsJson = "[]";
            root.appUsage = ({});
            root.pinnedApps = [];
```

- [ ] **Step 6: Verify**

Reload the shell. Expected: no errors.
Run: `cat ~/.cache/quickshell_preferences.json | python3 -m json.tool`
Expected: the JSON now contains `"appUsageJson": "{}"` and `"pinnedAppsJson": "[]"`.

- [ ] **Step 7: Commit**

```bash
git add services/Preferences.qml
git commit -m "feat(launcher): persist app launch usage and pins in Preferences"
```

---

## Task 2: Grow AppLauncher into the launcher data source

**Files:**
- Modify: `services/AppLauncher.qml`

- [ ] **Step 1: Replace the file contents**

Replace the entire contents of `services/AppLauncher.qml` with:

```qml
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.common
import qs.services

Singleton {
    id: root

    property string query: ""

    // ── Search results (unchanged behaviour; launch now records usage) ──
    property list<var> results: {
        if (root.query === "")
            return [];

        return AppSearch.fuzzyQuery(root.query).map(entry => ({
            "name": entry.name,
            "iconName": entry.icon,
            "comment": entry.description || "",
            "entry": entry,
            "execute": () => root.launch(entry)
        }));
    }

    // ── Grid data sources ──
    readonly property var allApps: AppSearch.list
        .slice()
        .sort((a, b) => (a.name || "").localeCompare(b.name || ""))

    readonly property var pinnedApps: {
        const byId = {};
        for (const e of AppSearch.list)
            byId[e.id] = e;
        return (Preferences.pinnedApps || []).map(id => byId[id]).filter(e => !!e);
    }

    readonly property var frequentApps: {
        const usage = Preferences.appUsage || {};
        const pinned = Preferences.pinnedApps || [];
        const now = Date.now();
        return AppSearch.list
            .filter(e => usage[e.id] && usage[e.id].count > 0 && pinned.indexOf(e.id) === -1)
            .map(e => ({ "entry": e, "score": root.frecencyScore(usage[e.id], now) }))
            .sort((a, b) => (b.score - a.score) || (a.entry.name || "").localeCompare(b.entry.name || ""))
            .slice(0, 8)
            .map(o => o.entry);
    }

    function frecencyScore(rec, now): real {
        const days = (now - (rec.last || 0)) / 86400000;
        let w = 1;
        if (days <= 1)
            w = 4;
        else if (days <= 3)
            w = 3;
        else if (days <= 7)
            w = 2;
        else if (days <= 30)
            w = 1.5;
        return (rec.count || 0) * w;
    }

    function isPinned(entry): bool {
        return entry ? Preferences.isPinned(entry.id) : false;
    }

    function togglePin(entry): void {
        if (!entry)
            return;
        Preferences.setPinned(entry.id, !Preferences.isPinned(entry.id));
    }

    function launch(entry): void {
        if (!entry)
            return;
        Preferences.recordLaunch(entry.id);
        if (!entry.runInTerminal) {
            entry.execute();
            return;
        }
        const terminalCmd = Quickshell.env("TERMINAL") || "kitty";
        Quickshell.execDetached(["bash", "-c", `${terminalCmd} -e '${StringUtils.shellSingleQuoteEscape(entry.command.join(" "))}'`]);
    }
}
```

- [ ] **Step 2: Verify search still works and now records usage**

Reload the shell. Open the launcher, type a query, press Enter on a result to launch an app. Expected: app launches, no errors.
Run: `cat ~/.cache/quickshell_preferences.json | python3 -m json.tool`
Expected: `appUsageJson` is no longer `"{}"` — it contains a key for the launched app's id with `"count": 1`.

- [ ] **Step 3: Commit**

```bash
git add services/AppLauncher.qml
git commit -m "feat(launcher): add pinned/frequent/all lists, frecency, and launch()"
```

---

## Task 3: Build the AppGridCell component

**Files:**
- Create: `components/applauncher/AppGridCell.qml`

- [ ] **Step 1: Create the cell**

Create `components/applauncher/AppGridCell.qml` with:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property var item        // DesktopEntry
    property bool selected: false
    property bool pinned: false

    signal launch()
    signal togglePin()
    signal hovered()

    property string itemName: item?.name ?? ""
    property string iconName: item?.icon ?? ""

    radius: Theme.ui.radius.md
    color: selected ? Colors.surfaceContainerLow : "transparent"
    border.width: 1
    border.color: selected ? Colors.hairHot : "transparent"

    Behavior on color        { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }

    // accent edge when selected
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height - 16
        radius: 2
        color: Colors.fgSurface
        visible: root.selected
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - 12
        spacing: 8

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 44
            height: 44
            radius: 8
            color: (root.selected || cellMouse.containsMouse) ? Colors.surfaceContainerHigh : Colors.surfaceContainerLow
            border.width: 1
            border.color: (root.selected || cellMouse.containsMouse) ? Colors.hairHot : Colors.hair

            Behavior on color        { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
            Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }

            Image {
                anchors.centerIn: parent
                width: 22
                height: 22
                sourceSize.width: 22
                sourceSize.height: 22
                source: Quickshell.iconPath(root.iconName, "application-x-executable")
                smooth: true
                asynchronous: true
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.itemName
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.font.family.inter
            font.pixelSize: 12
            color: Colors.fgSurface
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    // pin dot — shown for pinned apps when the pin button is not being hovered
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 7
        anchors.rightMargin: 9
        width: 5
        height: 5
        radius: 2.5
        color: Colors.fgSurface
        opacity: root.pinned && !pinBtn.containsMouse ? 0.75 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    // whole-cell interaction: left-click launch, right-click pin, hover select
    MouseArea {
        id: cellMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: if (containsMouse) root.hovered()
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.togglePin();
            else
                root.launch();
        }
    }

    // hover pin button — declared last so it sits above cellMouse
    MouseArea {
        id: pinBtn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 2
        anchors.rightMargin: 2
        width: 24
        height: 24
        hoverEnabled: true
        visible: cellMouse.containsMouse || pinBtn.containsMouse
        cursorShape: Qt.PointingHandCursor
        onClicked: root.togglePin()

        MaterialSymbol {
            anchors.centerIn: parent
            icon: root.pinned ? "keep" : "keep_off"
            iconSize: 13
            fill: root.pinned ? 1 : 0
            fontColor: pinBtn.containsMouse ? Colors.fgSurface : Qt.alpha(Colors.fgSurface, 0.5)
        }
    }
}
```

- [ ] **Step 2: Verify it parses**

Reload the shell. Expected: no errors. (The cell isn't shown yet — this only confirms it compiles. It will render in Task 4.)

- [ ] **Step 3: Commit**

```bash
git add components/applauncher/AppGridCell.qml
git commit -m "feat(launcher): add AppGridCell component"
```

---

## Task 4: Build AppGrid and show it in the empty state

**Files:**
- Create: `components/applauncher/AppGrid.qml`
- Modify: `modules/AppLauncherPanel.qml`

- [ ] **Step 1: Create AppGrid (render only; keyboard nav added in Task 5)**

Create `components/applauncher/AppGrid.qml` with:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.services
import qs.widgets

FocusScope {
    id: root

    property string currentTab: "pinfreq"   // "pinfreq" | "all"
    property int selectedIndex: 0
    property real maxGridHeight: 400

    signal requestFocusSearch()
    signal typed(string text)

    readonly property int sidePad: 14
    readonly property int cellSpacing: 4
    readonly property real cellW: (width - 2 * sidePad - 3 * cellSpacing) / 4
    readonly property int cellH: 92

    // flat app list for the active tab: pinfreq = pinned then frequent
    readonly property var gridApps: currentTab === "all"
        ? AppLauncher.allApps
        : AppLauncher.pinnedApps.concat(AppLauncher.frequentApps)

    implicitHeight: tabStrip.height + flick.height

    function reset() {
        currentTab = "pinfreq";
        selectedIndex = 0;
        flick.contentY = 0;
    }

    function enterFromTop() {
        selectedIndex = 0;
        root.forceActiveFocus();
    }

    function doLaunch(entry) {
        if (!entry)
            return;
        GlobalStates.appLauncherOpen = false;
        Qt.callLater(() => AppLauncher.launch(entry));
    }

    function switchTab(tab) {
        if (root.currentTab === tab)
            return;
        root.currentTab = tab;
        root.selectedIndex = 0;
        flick.contentY = 0;
    }

    // ── Tab strip ──
    RowLayout {
        id: tabStrip
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.sidePad
        anchors.topMargin: 12
        spacing: 4

        component TabButton: Rectangle {
            property string tab: ""
            property string label: ""
            Layout.preferredHeight: 32
            Layout.preferredWidth: tabText.implicitWidth + 24
            color: "transparent"

            Text {
                id: tabText
                anchors.centerIn: parent
                text: parent.label
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 11
                font.letterSpacing: 1.2
                color: root.currentTab === parent.tab ? Colors.fgSurface : Qt.alpha(Colors.fgSurface, 0.42)
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                height: 2
                color: Colors.fgSurface
                visible: root.currentTab === parent.tab
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.switchTab(parent.tab)
            }
        }

        TabButton { tab: "pinfreq"; label: "PINNED & FREQUENT" }
        TabButton { tab: "all"; label: "ALL APPS" }
        Item { Layout.fillWidth: true }
    }

    // ── Scrollable grid area ──
    Flickable {
        id: flick
        anchors.top: tabStrip.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 6
        height: Math.min(gridColumn.implicitHeight, root.maxGridHeight)
        contentWidth: width
        contentHeight: gridColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: gridColumn
            width: flick.width
            spacing: 0

            // empty hint (default tab, nothing pinned and nothing launched yet)
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 120 : 0
                visible: root.currentTab === "pinfreq"
                    && AppLauncher.pinnedApps.length === 0
                    && AppLauncher.frequentApps.length === 0

                Text {
                    anchors.centerIn: parent
                    width: parent.width - 60
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Pin apps or launch a few — they'll show up here.\nPress Tab for All Apps."
                    font.family: Theme.font.family.inter
                    font.pixelSize: 12
                    color: Qt.alpha(Colors.fgSurface, 0.42)
                }
            }

            // PINNED section
            GridSection {
                visible: root.currentTab === "pinfreq" && AppLauncher.pinnedApps.length > 0
                label: "PINNED"
                model: AppLauncher.pinnedApps
                baseIndex: 0
            }

            // FREQUENT section
            GridSection {
                visible: root.currentTab === "pinfreq" && AppLauncher.frequentApps.length > 0
                label: "FREQUENT"
                model: AppLauncher.frequentApps
                baseIndex: AppLauncher.pinnedApps.length
            }

            // ALL section (no label)
            GridSection {
                visible: root.currentTab === "all"
                label: ""
                model: AppLauncher.allApps
                baseIndex: 0
            }
        }
    }

    // a labeled 4-column grid of cells; baseIndex offsets the flat selection index
    component GridSection: ColumnLayout {
        property string label: ""
        property var model: []
        property int baseIndex: 0
        Layout.fillWidth: true
        spacing: 0

        Text {
            visible: parent.label !== ""
            Layout.fillWidth: true
            Layout.leftMargin: root.sidePad + 4
            Layout.topMargin: 12
            Layout.bottomMargin: 8
            text: parent.label
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.letterSpacing: 2.0
            color: Qt.alpha(Colors.fgSurface, 0.32)
        }

        Grid {
            Layout.fillWidth: true
            Layout.leftMargin: root.sidePad
            Layout.rightMargin: root.sidePad
            columns: 4
            columnSpacing: root.cellSpacing
            rowSpacing: root.cellSpacing

            Repeater {
                model: parent.parent.model
                AppGridCell {
                    required property int index
                    required property var modelData
                    width: root.cellW
                    height: root.cellH
                    item: modelData
                    selected: root.selectedIndex === (parent.parent.baseIndex + index)
                    pinned: AppLauncher.isPinned(modelData)
                    onHovered: root.selectedIndex = parent.parent.baseIndex + index
                    onLaunch: root.doLaunch(modelData)
                    onTogglePin: AppLauncher.togglePin(modelData)
                }
            }
        }
    }
}
```

- [ ] **Step 2: Add the import to AppLauncherPanel (already present — confirm)**

Confirm `modules/AppLauncherPanel.qml` line 13 reads `import qs.components.applauncher`. It does — no change needed.

- [ ] **Step 3: Insert AppGrid into `contentColumn`**

In `modules/AppLauncherPanel.qml`, locate the `ListView { id: resultsList` block (currently starts line 311). Immediately **before** it, insert:

```qml
                    AppGrid {
                        id: appGrid
                        Layout.fillWidth: true
                        visible: AppLauncher.query.length === 0
                        Layout.preferredHeight: visible ? implicitHeight : 0
                        maxGridHeight: Math.round(panel.height * 0.56)

                        onRequestFocusSearch: searchField.forceActiveFocus()
                        onTyped: t => {
                            searchField.forceActiveFocus();
                            searchField.text += t;
                        }
                    }
```

- [ ] **Step 4: Reset the grid when the launcher closes**

In `modules/AppLauncherPanel.qml`, in `onVisibleChanged` (currently line 490), inside the `else` branch (after `resultsList.currentIndex = 0;`, currently line 498), add:

```qml
                    appGrid.reset();
```

- [ ] **Step 5: Verify rendering, mouse launch, and pinning**

Reload the shell. Open the launcher (empty field). Expected: no errors, and the grid appears below the search field with a `PINNED & FREQUENT` / `ALL APPS` tab strip.
- Click `ALL APPS` → grid switches to the full A–Z list and scrolls.
- Left-click an app → it launches and the launcher closes.
- Reopen, **right-click** an app → it gains a pin dot and moves to a `PINNED` section.
- Hover an app → a pin icon appears top-right; click it to unpin.
Run: `cat ~/.cache/quickshell_preferences.json | python3 -m json.tool`
Expected: `pinnedAppsJson` contains the pinned app id; launched apps appear in `appUsageJson`.

- [ ] **Step 6: Commit**

```bash
git add components/applauncher/AppGrid.qml modules/AppLauncherPanel.qml
git commit -m "feat(launcher): grid empty-state with pinned/frequent/all tabs"
```

---

## Task 5: Keyboard navigation and focus integration

**Files:**
- Modify: `components/applauncher/AppGrid.qml`
- Modify: `modules/AppLauncherPanel.qml`

- [ ] **Step 1: Add the row model + navigation functions to AppGrid**

In `components/applauncher/AppGrid.qml`, add these inside the `FocusScope` (place after the `gridApps` property, before `implicitHeight:`):

```qml
    // rows[] = array of rows; each row = array of flat indices into gridApps.
    // Each section starts on a fresh row, so column math is exact.
    readonly property var rows: {
        const out = [];
        const pushSection = (start, count) => {
            for (let i = 0; i < count; i += 4) {
                const row = [];
                for (let j = i; j < Math.min(i + 4, count); j++)
                    row.push(start + j);
                out.push(row);
            }
        };
        if (root.currentTab === "all") {
            pushSection(0, AppLauncher.allApps.length);
        } else {
            const p = AppLauncher.pinnedApps.length;
            const f = AppLauncher.frequentApps.length;
            pushSection(0, p);
            pushSection(p, f);
        }
        return out;
    }

    function locate(idx) {
        for (let r = 0; r < root.rows.length; r++) {
            const c = root.rows[r].indexOf(idx);
            if (c !== -1)
                return { "r": r, "c": c };
        }
        return { "r": 0, "c": 0 };
    }

    function navigate(dir) {
        if (root.rows.length === 0)
            return;
        const pos = root.locate(root.selectedIndex);
        const r = pos.r;
        const c = pos.c;
        if (dir === "left") {
            if (c > 0)
                root.selectedIndex = root.rows[r][c - 1];
        } else if (dir === "right") {
            if (c < root.rows[r].length - 1)
                root.selectedIndex = root.rows[r][c + 1];
        } else if (dir === "up") {
            if (r === 0) {
                root.requestFocusSearch();
                return;
            }
            const pr = root.rows[r - 1];
            root.selectedIndex = pr[Math.min(c, pr.length - 1)];
        } else if (dir === "down") {
            if (r < root.rows.length - 1) {
                const nr = root.rows[r + 1];
                root.selectedIndex = nr[Math.min(c, nr.length - 1)];
            }
        }
        root.ensureVisible();
    }

    function cellItemFor(idx) {
        // Walk the rendered GridSections to find the delegate at this flat index.
        const sections = [pinnedSection, freqSection, allSection];
        for (const s of sections) {
            if (!s.visible)
                continue;
            const local = idx - s.baseIndex;
            if (local >= 0 && local < s.repeater.count)
                return s.repeater.itemAt(local);
        }
        return null;
    }

    function ensureVisible() {
        const it = root.cellItemFor(root.selectedIndex);
        if (!it)
            return;
        const p = it.mapToItem(gridColumn, 0, 0);
        const top = p.y;
        const bot = top + it.height;
        if (top < flick.contentY)
            flick.contentY = top;
        else if (bot > flick.contentY + flick.height)
            flick.contentY = bot - flick.height;
    }
```

- [ ] **Step 2: Give each GridSection an id + expose its Repeater**

In `components/applauncher/AppGrid.qml`, the `component GridSection: ColumnLayout {` declaration: add a `property alias repeater: rep` and give the `Repeater` `id: rep`. Replace the `Repeater {` line inside `GridSection` with:

```qml
            Repeater {
                id: rep
                model: parent.parent.model
```

And add this line directly under `spacing: 0` at the top of the `GridSection` component body:

```qml
        property alias repeater: rep
```

Then give the three section instances ids. Replace the three section instantiations (`GridSection { ... }`) so they read:

```qml
            GridSection {
                id: pinnedSection
                visible: root.currentTab === "pinfreq" && AppLauncher.pinnedApps.length > 0
                label: "PINNED"
                model: AppLauncher.pinnedApps
                baseIndex: 0
            }

            GridSection {
                id: freqSection
                visible: root.currentTab === "pinfreq" && AppLauncher.frequentApps.length > 0
                label: "FREQUENT"
                model: AppLauncher.frequentApps
                baseIndex: AppLauncher.pinnedApps.length
            }

            GridSection {
                id: allSection
                visible: root.currentTab === "all"
                label: ""
                model: AppLauncher.allApps
                baseIndex: 0
            }
```

- [ ] **Step 3: Add the key handler to AppGrid**

In `components/applauncher/AppGrid.qml`, add a `Keys.onPressed` handler to the root `FocusScope`. Place it right after the `function switchTab(...)` block:

```qml
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Left) {
            root.navigate("left");
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            root.navigate("right");
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            root.navigate("up");
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            root.navigate("down");
            event.accepted = true;
        } else if (event.key === Qt.Key_Tab) {
            root.switchTab(root.currentTab === "pinfreq" ? "all" : "pinfreq");
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.doLaunch(root.gridApps[root.selectedIndex]);
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            GlobalStates.appLauncherOpen = false;
            event.accepted = true;
        } else if (event.text.length > 0 && event.text.match(/\S/)) {
            root.typed(event.text);
            event.accepted = true;
        }
    }
```

- [ ] **Step 4: Route the search field's Down key into the grid**

In `modules/AppLauncherPanel.qml`, find the searchField `Keys.onPressed` handler (currently line 270). Replace the first branch:

```qml
                                    if (event.key === Qt.Key_Down && resultsList.count > 0) {
                                        resultsList.forceActiveFocus();
                                        resultsList.currentIndex = 0;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
```

with:

```qml
                                    if (event.key === Qt.Key_Down && AppLauncher.query.length === 0) {
                                        appGrid.enterFromTop();
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Down && resultsList.count > 0) {
                                        resultsList.forceActiveFocus();
                                        resultsList.currentIndex = 0;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
```

- [ ] **Step 5: Verify keyboard flow**

Reload the shell. Open the launcher (empty field).
- Press **Down** → selection highlight enters the grid at the first cell.
- **←/→** move within a row; **↑/↓** move between rows, including crossing from the Pinned section into Frequent.
- **↑** from the top row → focus returns to the search field (caret visible).
- **Tab** toggles `Pinned & Frequent` ↔ `All Apps`.
- In `All Apps`, hold **↓** → selection scrolls the list to stay visible.
- **Enter** launches the highlighted app; **Esc** closes the launcher.
- Start **typing** while the grid is focused → focus jumps to the search field, the character is appended, and the results list takes over.
Expected: all of the above, no errors.

- [ ] **Step 6: Commit**

```bash
git add components/applauncher/AppGrid.qml modules/AppLauncherPanel.qml
git commit -m "feat(launcher): 2D keyboard navigation and search/grid focus handoff"
```

---

## Task 6: Context-aware footer

**Files:**
- Modify: `modules/AppLauncherPanel.qml`

- [ ] **Step 1: Make the footer's left label reflect grid vs search**

In `modules/AppLauncherPanel.qml`, find the footer's left `Text` (currently lines 421-430, the one whose `text:` begins `AppLauncher.query.length >= 1 && resultsList.count > 0`). Replace its `text:` binding with:

```qml
                                text: AppLauncher.query.length >= 1
                                    ? (resultsList.count > 0
                                        ? `${resultsList.count} ${resultsList.count === 1 ? "MATCH" : "MATCHES"}`
                                        : "NO MATCHES")
                                    : (appGrid.currentTab === "all"
                                        ? `${AppLauncher.allApps.length} APPLICATIONS`
                                        : "PINNED & FREQUENT")
```

- [ ] **Step 2: Show navigation hints in grid mode too**

In the same file, find the navigate-hint `RowLayout` whose child currently reads `visible: AppLauncher.query.length >= 1 && resultsList.count > 0` (currently line 441). Replace that `visible:` line with:

```qml
                                    visible: AppLauncher.query.length === 0 || resultsList.count > 0
```

Then, inside that same `RowLayout` (the one containing the `↑` `↓` `FooterKbd`s and the `NAVIGATE` `Text`), add two `FooterKbd`s for the grid's horizontal arrows immediately after the existing `FooterKbd { label: "↓" }` (currently line 444):

```qml
                                    FooterKbd { label: "←"; visible: AppLauncher.query.length === 0 }
                                    FooterKbd { label: "→"; visible: AppLauncher.query.length === 0 }
```

- [ ] **Step 3: Add a Tab/switch hint shown only in grid mode**

In the same file, immediately after the navigate-hint `RowLayout` closes (before the `RowLayout` containing `FooterKbd { label: "↵" }`, currently line 455), insert:

```qml
                                RowLayout {
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 6
                                    visible: AppLauncher.query.length === 0

                                    FooterKbd { label: "TAB" }
                                    Text {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "SWITCH"
                                        font.family: Theme.font.family.inter_medium
                                        font.pixelSize: 10
                                        font.letterSpacing: 1.8
                                        color: Qt.alpha(Colors.fgSurface, 0.42)
                                    }
                                }
```

- [ ] **Step 4: Verify footer**

Reload the shell. Open the launcher (empty field).
Expected: footer left reads `PINNED & FREQUENT`; right shows `← ↑ ↓ → NAVIGATE`, `TAB SWITCH`, `↵ LAUNCH`, `ESC CLOSE`.
- Switch to `All Apps` → left reads `N APPLICATIONS`.
- Type a query → left shows the match count, the `←/→` and `TAB` hints disappear, and `↑ ↓ NAVIGATE` remains (as today).
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add modules/AppLauncherPanel.qml
git commit -m "feat(launcher): context-aware footer for grid and search modes"
```

---

## Self-review (completed by plan author)

**Spec coverage:**
- Tabbed empty-state (Pinned & Frequent + All) → Task 4.
- Cell = icon + name, 4-col → Task 3 + Task 4 (`columns: 4`, `cellW`).
- Pin via right-click AND hover button → Task 3 (`cellMouse` right-click + `pinBtn`).
- Frecency from tracked launch counts → Task 1 (`recordLaunch`) + Task 2 (`frecencyScore`, `frequentApps`).
- Search overrides grid unchanged → Task 4 (`visible: AppLauncher.query.length === 0`), existing `resultsList` untouched.
- Keyboard model (Down-into-grid, 2D arrows, section crossing, Up-to-field, Tab, Enter, Esc, type-to-search) → Task 5.
- Persistence following root+adapter pattern, reassign-don't-mutate → Task 1.
- Edge/empty states (no pins / no usage / fully empty hint) → Task 4 (section `visible` bindings + empty hint Item).
- Context footer → Task 6.
- Reset on close → Task 4 Step 4.

**Placeholder scan:** none — every code step contains complete code.

**Type consistency:** `recordLaunch`/`isPinned`/`setPinned` (Preferences) ↔ `launch`/`isPinned`/`togglePin` (AppLauncher) ↔ `AppGridCell` signals `launch`/`togglePin`/`hovered` ↔ `AppGrid` `enterFromTop`/`reset`/`switchTab`/`navigate`/`doLaunch`/`requestFocusSearch`/`typed` ↔ `AppLauncherPanel` (`appGrid.enterFromTop`, `appGrid.reset`, `onRequestFocusSearch`, `onTyped`) — all consistent.

**Known QML risk to watch during execution:** nested `parent.parent` references inside the `GridSection` component (Repeater delegate → Grid → ColumnLayout) can resolve unexpectedly. If `model`/`baseIndex` don't bind, give the `GridSection` root an `id` (e.g. `section`) and reference `section.model` / `section.baseIndex` instead of `parent.parent.*`. The `cellItemFor` helper already references sections by id, so this only affects the delegate bindings.
