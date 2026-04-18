pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Item {
    id: root

    required property var ap
    required property bool expanded
    required property real rowWidth

    signal expandRequested(var ap)
    signal collapseRequested()

    width: rowWidth
    implicitHeight: wifiRow.implicitHeight + entryWrap.height

    WifiRow {
        id: wifiRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        ap: root.ap
        onExpandRequested: (requestedAp) => root.expandRequested(requestedAp)
    }

    Item {
        id: entryWrap
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: wifiRow.bottom
        clip: true
        height: root.expanded && entryLoader.item
                    ? entryLoader.item.implicitHeight
                    : 0
        Behavior on height {
            NumberAnimation {
                duration: Theme.anim.durations.xs
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }

        Loader {
            id: entryLoader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            active: root.expanded
            sourceComponent: WifiPasswordEntry {
                ap: root.ap
                onCancelled: root.collapseRequested()
            }
        }
    }

    Connections {
        target: root.ap
        enabled: root.ap !== null
        function onActiveChanged() {
            if (root.ap.active && root.expanded) {
                root.collapseRequested();
            }
        }
        function onAskingPasswordChanged() {
            if (root.ap.askingPassword && !root.expanded) {
                root.expandRequested(root.ap);
            }
        }
    }
}
