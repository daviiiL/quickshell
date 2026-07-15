pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string label
    required property string icon
    property string meta: ""
    property bool active: false

    signal activated()

    readonly property bool hot: mouseArea.containsMouse
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    Layout.fillWidth: true
    Layout.preferredHeight: 32

    color: {
        if (root.active) return Colors.surfaceContainerLow;
        if (root.hot) return Qt.alpha(Colors.fgSurface, 0.025);
        return "transparent";
    }

    Behavior on color { ColorAnimation { duration: root.animMs } }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: root.active ? Colors.barAccent : "transparent"
        Behavior on color { ColorAnimation { duration: root.animMs } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 14
        spacing: 11

        Rectangle {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            radius: 3
            color: root.active ? Colors.surfaceContainerHigh : Colors.surfaceContainer
            border.color: root.active ? Colors.hairHot : Colors.hair
            border.width: Theme.ui.mainBarHairWidth
            Behavior on color { ColorAnimation { duration: root.animMs } }
            Behavior on border.color { ColorAnimation { duration: root.animMs } }

            MaterialSymbol {
                anchors.centerIn: parent
                icon: root.icon
                iconSize: 11
                fontColor: root.active ? Colors.fgSurface : Colors.inkDim
                Behavior on color { ColorAnimation { duration: root.animMs } }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            color: (root.active || root.hot) ? Colors.fgSurface : Colors.inkDim
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.sm
            elide: Text.ElideRight
            Behavior on color { ColorAnimation { duration: root.animMs } }
        }

        Text {
            visible: root.meta.length > 0
            text: root.meta.toUpperCase()
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 0.6
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
