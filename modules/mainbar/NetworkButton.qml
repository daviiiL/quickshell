pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    property var screen: null

    readonly property bool netOnline:   typeof Network !== "undefined" && Network !== null
    readonly property bool isEthernet:  netOnline && Network.ethernet && Network.ethernetConnected
    readonly property bool isWifiUp:    netOnline && !isEthernet && Network.wifiEnabled
    readonly property int  strength:    netOnline ? (Network.networkStrength ?? 0) : 0
    readonly property string wifiState: netOnline ? (Network.wifiStatus ?? "") : ""

    readonly property string iconSrc: {
        if (isEthernet)                    return "../../assets/icons/ethernet.svg";
        if (isWifiUp && strength > 66)     return "../../assets/icons/wifi-3.svg";
        if (isWifiUp && strength > 33)     return "../../assets/icons/wifi-2.svg";
        return "../../assets/icons/wifi-1.svg";
    }

    readonly property string connectionLabel: {
        if (isEthernet)                                return Network.ethernetDevice || "eth";
        if (isWifiUp && Network.networkName)           return Network.networkName;
        if (isWifiUp)                                  return "offline";
        if (netOnline && wifiState === "disabled")     return "off";
        if (netOnline && wifiState === "connecting")   return "…";
        return "—";
    }

    active: GlobalStates.networkOverlayOpen

    color: (root.active || root.hovered) ? Colors.surfaceContainerLow : Colors.surfaceContainer
    border.color: (root.active || root.hovered) ? Colors.hairHot : Colors.hair

    onActivated: {
        const name = root.screen?.name ?? "";
        if (GlobalStates.networkOverlayOpen && GlobalStates.networkOverlayScreen === name) {
            GlobalStates.networkOverlayOpen = false;
        } else {
            GlobalStates.networkOverlayScreen = name;
            GlobalStates.networkOverlayOpen = true;
        }
    }

    onXChanged:     Qt.callLater(_publishCenter)
    onWidthChanged: Qt.callLater(_publishCenter)
    Component.onCompleted: Qt.callLater(_publishCenter)

    function _publishCenter() {
        const g = root.mapToGlobal(root.width / 2, 0);
        console.log("[BTN]", Date.now(), "x=", root.x, "w=", root.width,
            "parentW=", root.parent?.width, "globalCx=", g ? g.x : "(null)",
            "screen=", root.screen?.name);
        if (g && g.x !== undefined && root.screen?.name)
            GlobalStates.setNetworkButtonCenter(root.screen.name, g.x);
    }

    Image {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize
        source: root.iconSrc
        sourceSize.width: Theme.ui.mainBarIconSize * 2
        sourceSize.height: Theme.ui.mainBarIconSize * 2
        smooth: true
        opacity: {
            if (root.hovered) return 1.0;
            if (!root.isEthernet && !root.isWifiUp) return 0.30;
            return 0.56;
        }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

    Text {
        text: root.connectionLabel
        color: root.hovered ? Colors.fgSurface : Colors.inkDim
        font.family: Theme.font.family.inter_medium
        font.weight: Font.Medium
        font.pixelSize: 15
        Layout.preferredWidth: 80
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    Text {
        readonly property bool showPct: root.isWifiUp && Network.active
        visible: showPct
        text: root.strength + "%"
        color: root.hovered ? Colors.fgSurface : Colors.inkDimmer
        font.family: Theme.font.family.inter_regular
        font.pixelSize: 11
        font.letterSpacing: 0.2
        Layout.preferredWidth: showPct ? 26 : 0
        Layout.alignment: Qt.AlignVCenter
        horizontalAlignment: Text.AlignRight
        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
