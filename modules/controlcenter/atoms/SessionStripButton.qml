pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string label
    required property string icon
    property bool danger: false
    property bool confirm: false

    signal activated()

    property bool armed: false

    readonly property bool hot: mouseArea.containsMouse
    readonly property bool alert: root.armed || (root.danger && root.hot)
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    Layout.fillWidth: true
    implicitHeight: 56
    radius: Theme.ui.radius.sm
    color: root.hot ? Qt.alpha(Colors.fgSurface, 0.04) : Colors.surfaceContainerLow
    border.color: root.alert ? Qt.alpha(Colors.error, 0.45) : (root.hot ? Colors.hairHot : Colors.hair)
    border.width: Theme.ui.mainBarHairWidth

    Behavior on color { ColorAnimation { duration: root.animMs } }
    Behavior on border.color { ColorAnimation { duration: root.animMs } }

    Timer {
        id: disarm
        interval: 3000
        onTriggered: root.armed = false
    }

    function trigger(): void {
        if (root.confirm && !root.armed) {
            root.armed = true;
            disarm.restart();
            return;
        }
        root.armed = false;
        disarm.stop();
        root.activated();
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 5

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            icon: root.armed ? "warning" : root.icon
            iconSize: 16
            fontColor: root.alert ? Colors.error : Colors.fgSurface
            Behavior on color { ColorAnimation { duration: root.animMs } }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.armed ? "Confirm" : root.label
            color: root.alert ? Colors.error : (root.hot ? Colors.fgSurface : Colors.inkDim)
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.caption
            font.weight: Font.Medium
            Behavior on color { ColorAnimation { duration: root.animMs } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.trigger()
    }
}
