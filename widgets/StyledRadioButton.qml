pragma ComponentBehavior: Bound

import QtQuick

import qs.common

Item {
    id: root

    property bool checked: false
    property string text: ""

    property color indicatorColor: Colors.secondaryContainer
    property color checkColor: Colors.fgSecondaryContainer
    property color textColor: Colors.fgSurface

    signal clicked

    implicitWidth: indicator.width + (text.length > 0 ? label.width + 8 : 0)
    implicitHeight: 20

    MouseArea {
        id: rootMouseArea

        anchors.fill: parent
        hoverEnabled: false
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }

    Rectangle {
        id: indicator

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        implicitWidth: 20
        implicitHeight: 20
        color: root.indicatorColor
        radius: Theme.ui.radius.lg

        Canvas {
            id: checkIndicator
            anchors.fill: parent
            visible: root.checked

            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                const r = Math.min(width, height) * 0.3;
                const cx = width / 2;
                const cy = height / 2;

                ctx.beginPath();
                ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                ctx.fillStyle = root.checkColor;
                ctx.fill();
            }

            onVisibleChanged: requestPaint()
        }
    }

    Text {
        id: label

        anchors {
            top: root.top
            bottom: root.bottom
            left: indicator.right
            leftMargin: Theme.ui.padding.sm
        }

        verticalAlignment: Qt.AlignVCenter

        text: root.text
        visible: root.text.length > 0

        font {
            family: Theme.font.family.inter_regular
            pixelSize: Theme.font.size.lg
        }

        color: root.textColor
    }
}
