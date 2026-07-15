pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Rectangle {
    id: root

    required property string text
    property string variant: "default"

    readonly property color textColor: {
        switch (root.variant) {
        case "live": return Colors.fgSurface;
        case "warn": return Colors.warning;
        case "err":  return Colors.error;
        default:     return Colors.inkDim;
        }
    }
    readonly property color dotColor: {
        switch (root.variant) {
        case "live": return Colors.live;
        case "warn": return Colors.busy;
        case "err":  return Colors.error;
        default:     return Colors.inkFaint;
        }
    }
    readonly property bool hasDot: root.variant !== "default"

    implicitWidth: row.implicitWidth + 16
    implicitHeight: 20
    radius: 2
    color: Colors.surfaceContainer
    border.color: root.variant === "live" ? Colors.hairHot : Colors.hair
    border.width: Theme.ui.mainBarHairWidth

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            visible: root.hasDot
            width: 5
            height: 5
            radius: width / 2
            color: root.dotColor
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text.toUpperCase()
            color: root.textColor
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xs
            font.weight: Font.Medium
            font.letterSpacing: 1.6
        }
    }
}
