import "../../common"
import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    default property alias contentData: layout.data
    property int spacing: 10

    implicitWidth: layout.implicitWidth + 20
    implicitHeight: layout.implicitHeight + 20
    color: Colors.current.surface_container
    radius: Theme.rounding.regular
    scale: 0.9
    opacity: 0
    Component.onCompleted: {
        scaleAnimation.start();
        opacityAnimation.start();
    }

    NumberAnimation {
        id: scaleAnimation

        target: root
        property: "scale"
        from: 0.9
        to: 1
        duration: Theme.anim.durations.normal
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: opacityAnimation

        target: root
        property: "opacity"
        from: 0
        to: 1
        duration: Theme.anim.durations.normal
        easing.type: Easing.OutCubic
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: root.spacing
    }

}
