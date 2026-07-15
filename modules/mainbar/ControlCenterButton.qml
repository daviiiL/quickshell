pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    readonly property string srcId: "mainbar"
    readonly property bool highlighted: hovered || active

    active: GlobalStates.controlCenterOpen

    onActivated: {
        if (GlobalStates.controlCenterOpen) GlobalStates.closeControlCenter();
        else GlobalStates.openControlCenter(srcId);
    }

    Item {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize

        Image {
            anchors.fill: parent
            source: Icons.tune
            sourceSize.width: Theme.ui.mainBarIconSize * 2
            sourceSize.height: Theme.ui.mainBarIconSize * 2
            smooth: true
            opacity: root.highlighted ? 1.0 : 0.56
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        }
    }

    Text {
        text: "Control Center"
        color: root.highlighted ? Colors.fgSurface : Colors.inkDim
        font.family: Theme.font.family.inter_medium
        font.weight: Font.Medium
        font.pixelSize: Theme.font.size.sm
        Layout.alignment: Qt.AlignVCenter
        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
