pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string label
    required property string icon
    required property string sub
    property bool danger: false

    signal activated()

    readonly property bool hot: mouseArea.containsMouse
    readonly property bool dangerHover: root.danger && root.hot
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    implicitHeight: 92
    radius: Theme.ui.radius.sm
    color: root.hot ? Qt.alpha(Colors.fgSurface, 0.04) : Colors.surfaceContainerLow
    border.color: {
        if (root.dangerHover) return Qt.alpha(Colors.error, 0.30);
        if (root.hot) return Colors.hairHot;
        return Colors.hair;
    }
    border.width: Theme.ui.mainBarHairWidth

    Behavior on color { ColorAnimation { duration: root.animMs } }
    Behavior on border.color { ColorAnimation { duration: root.animMs } }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 16
        anchors.bottomMargin: 12
        spacing: 6

        MaterialSymbol {
            icon: root.icon
            iconSize: 18
            fontColor: root.dangerHover ? Colors.error : Colors.fgSurface
            Behavior on color { ColorAnimation { duration: root.animMs } }
        }

        Item { Layout.fillHeight: true }

        Text {
            text: root.label.toUpperCase()
            color: {
                if (root.dangerHover) return Colors.error;
                if (root.hot) return Colors.fgSurface;
                return Colors.inkDim;
            }
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.weight: Font.Medium
            font.letterSpacing: 2.0
            Behavior on color { ColorAnimation { duration: root.animMs } }
        }

        Text {
            text: root.sub
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter
            font.pixelSize: 9
            font.letterSpacing: 0.2
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
