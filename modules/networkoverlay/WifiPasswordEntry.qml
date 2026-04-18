pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: root

    required property var ap

    signal cancelled

    readonly property bool busy: Network.wifiConnecting && Network.wifiConnectTarget === root.ap
    property bool submitted: false
    readonly property bool showError: submitted && !busy && root.ap?.askingPassword

    color: "transparent"
    implicitHeight: col.implicitHeight + 28

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "PASSWORD"
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 10
                font.letterSpacing: 1.8
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                id: inputWrap
                Layout.fillWidth: true
                Layout.preferredHeight: pwInput.implicitHeight + 6
                Layout.alignment: Qt.AlignVCenter

                TextInput {
                    id: pwInput
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    enabled: !root.busy
                    echoMode: TextInput.Password
                    passwordCharacter: "\u2022"
                    color: Colors.fgSurface
                    selectionColor: Colors.hairHot
                    selectedTextColor: Colors.fgSurface
                    font.family: Theme.font.family.inter_regular
                    font.pixelSize: 13
                    font.letterSpacing: 0.6
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "enter password"
                        color: Colors.inkFaint
                        font: pwInput.font
                        visible: pwInput.text.length === 0 && !pwInput.activeFocus
                    }

                    Keys.onEscapePressed: root.cancelled()
                    Keys.onReturnPressed: if (!connectBtn.disabledCombined) connectBtn.submit()
                    Keys.onEnterPressed:  if (!connectBtn.disabledCombined) connectBtn.submit()
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: pwInput.activeFocus ? Colors.hairHot : Colors.hair
                    Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }
                }
            }
        }

        Text {
            visible: root.showError
            Layout.fillWidth: true
            text: "COULDN'T CONNECT — CHECK PASSWORD"
            color: Colors.warning
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.letterSpacing: 1.4
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            Rectangle {
                id: cancelBtn
                Layout.preferredHeight: 26
                implicitWidth: cancelLabel.implicitWidth + 18
                radius: 3
                color: cancelMa.containsMouse ? Colors.surfaceContainerLow : "transparent"
                border.color: cancelMa.containsMouse ? Colors.hairHot : Colors.hair
                border.width: Theme.ui.mainBarHairWidth
                Behavior on color        { ColorAnimation { duration: Theme.anim.durations.xs } }
                Behavior on border.color { ColorAnimation { duration: Theme.anim.durations.xs } }

                Text {
                    id: cancelLabel
                    anchors.centerIn: parent
                    text: "CANCEL"
                    color: cancelMa.containsMouse ? Colors.fgSurface : Colors.inkDim
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 10
                    font.letterSpacing: 1.4
                    Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }
                }

                MouseArea {
                    id: cancelMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.cancelled()
                }
            }

            Rectangle {
                id: connectBtn
                readonly property bool disabledCombined: pwInput.text.length < 8 || root.busy
                Layout.preferredHeight: 26
                implicitWidth: connectLabel.implicitWidth + 18
                radius: 3
                color: bma.containsMouse && !connectBtn.disabledCombined
                        ? Colors.surfaceContainerLow
                        : "transparent"
                border.color: root.busy
                                ? Colors.hairHot
                                : (bma.containsMouse && !connectBtn.disabledCombined
                                    ? Colors.hairHot : Colors.hair)
                border.width: Theme.ui.mainBarHairWidth
                opacity: connectBtn.disabledCombined && !root.busy ? 0.4 : 1.0
                Behavior on color        { ColorAnimation { duration: Theme.anim.durations.xs } }
                Behavior on border.color { ColorAnimation { duration: Theme.anim.durations.xs } }
                Behavior on opacity      { NumberAnimation { duration: Theme.anim.durations.xs } }

                function submit() {
                    root.submitted = true;
                    Network.connectToWifiNetworkWithPassword(root.ap, pwInput.text);
                }

                Text {
                    id: connectLabel
                    anchors.centerIn: parent
                    text: root.busy ? "CONNECTING…" : "CONNECT"
                    color: bma.containsMouse && !connectBtn.disabledCombined
                            ? Colors.fgSurface
                            : Colors.inkDim
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 10
                    font.letterSpacing: 1.4
                    Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }
                }

                MouseArea {
                    id: bma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: connectBtn.disabledCombined ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onClicked: if (!connectBtn.disabledCombined) connectBtn.submit()
                }
            }
        }
    }

    onShowErrorChanged: {
        if (root.showError) {
            pwInput.clear();
            pwInput.forceActiveFocus();
        }
    }

    onApChanged: {
        pwInput.text = "";
        root.submitted = false;
    }

    Component.onCompleted: pwInput.forceActiveFocus()
}
