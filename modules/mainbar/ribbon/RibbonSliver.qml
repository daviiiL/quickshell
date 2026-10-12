pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Rectangle {
    id: root

    required property string tone
    property string iconSource: ""
    property bool urgent: false
    property bool wide: false

    readonly property bool hovered: area.containsMouse
    readonly property bool isFocus: tone === "focus"
    readonly property bool isOn:    tone === "on"

    signal activated()
    signal hoverChanged(bool on)

    height: Theme.ui.mainBarRibbonHeight
    radius: Theme.ui.mainBarRibbonRadius
    border.width: root.isFocus ? 0 : Theme.ui.mainBarHairWidth
    border.color: (root.isOn || root.hovered) ? Colors.hairHot : Colors.hair
    color: {
        if (root.isFocus) return Colors.barAccent;
        if (root.isOn)    return Colors.surfaceContainerHigh;
        if (root.hovered) return Colors.surfaceContainer;
        return "transparent";
    }

    Behavior on color        { ColorAnimation  { duration: Theme.anim.durations.xs * 0.75 } }
    Behavior on border.color { ColorAnimation  { duration: Theme.anim.durations.xs * 0.75 } }
    Behavior on width        { NumberAnimation { duration: Theme.anim.durations.expressiveFastSpatial; easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial } }
    Behavior on x            { NumberAnimation { duration: Theme.anim.durations.expressiveFastSpatial; easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial } }

    readonly property int iconPx: root.wide ? Theme.ui.mainBarRibbonIconWide : Theme.ui.mainBarRibbonIcon

    Image {
        visible: root.iconSource !== ""
        anchors.centerIn: parent
        width: root.iconPx
        height: root.iconPx
        source: root.iconSource
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        smooth: true
        asynchronous: true
        opacity: (root.isFocus || root.hovered) ? 1.0 : (root.isOn ? 0.9 : 0.5)
        Behavior on opacity { NumberAnimation { duration: Theme.anim.durations.xs * 0.75 } }
    }

    Rectangle {
        visible: root.iconSource === ""
        anchors.centerIn: parent
        width: Theme.ui.mainBarRibbonFallbackDot
        height: width
        radius: width / 2
        color: root.isFocus ? Colors.barBg : Colors.inkDim
    }

    Rectangle {
        visible: root.urgent
        readonly property int inset: root.isFocus
            ? Theme.ui.mainBarRibbonUrgentDotOffset + 1
            : -Theme.ui.mainBarRibbonUrgentDotOffset
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: inset
        anchors.topMargin: inset
        width: Theme.ui.mainBarRibbonUrgentDot
        height: width
        radius: width / 2
        color: root.isFocus ? Colors.barBg : Colors.barAccent
        border.width: root.isFocus ? 0 : Theme.ui.mainBarHairWidth
        border.color: Colors.barBg
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
        onContainsMouseChanged: root.hoverChanged(containsMouse)
    }
}
