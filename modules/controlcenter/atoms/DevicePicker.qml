pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

// Device selector that expands its option list inline below the header (host GroupBox/Flickable clip floating popups).
Item {
    id: root

    required property string title
    property string currentLabel: ""
    property var options: []     // [{ label: string, value: var }]
    property var currentValue: null
    property bool showSeparator: false
    property bool expanded: false

    signal selected(var value)

    readonly property int animMs: Theme.anim.durations.xs * 0.6

    Layout.fillWidth: true
    implicitHeight: header.height + (root.expanded ? optionsCol.height : 0)
    clip: true

    Behavior on implicitHeight {
        NumberAnimation { duration: Theme.anim.durations.xs * 1.2; easing.type: Easing.OutCubic }
    }

    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 44

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            Text {
            text: root.title
            color: Colors.fgSurface
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.sm
            Layout.alignment: Qt.AlignVCenter
        }

            Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

            Text {
                Layout.maximumWidth: 240
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignRight
                text: root.currentLabel
                color: Colors.inkDim
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.sm
                elide: Text.ElideRight
            }

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                icon: "expand_more"
                iconSize: 16
                fontColor: Colors.inkFaint
                rotation: root.expanded ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: root.animMs } }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    Column {
        id: optionsCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom

        Repeater {
            model: root.options

            delegate: Rectangle {
                id: opt
                required property var modelData

                width: optionsCol.width
                height: 38
                color: optMouse.containsMouse ? Qt.alpha(Colors.fgSurface, 0.03) : "transparent"
                Behavior on color { ColorAnimation { duration: root.animMs } }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: opt.modelData?.label ?? ""
                        color: Colors.fgSurface
                        font.family: Theme.font.family.inter
                        font.pixelSize: Theme.font.size.sm
                        elide: Text.ElideRight
                    }

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        visible: (opt.modelData?.value?.id ?? -2) === (root.currentValue?.id ?? -1)
                        icon: "check"
                        iconSize: 14
                        fontColor: Colors.barAccent
                    }
                }

                MouseArea {
                    id: optMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selected(opt.modelData?.value);
                        root.expanded = false;
                    }
                }
            }
        }
    }

    // Anchored to header (not parent.bottom) so it doesn't slide during the expand animation.
    Rectangle {
        visible: root.showSeparator
        anchors.bottom: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }
}
