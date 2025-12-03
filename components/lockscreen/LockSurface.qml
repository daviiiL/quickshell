import QtQuick
import Quickshell
import qs
import qs.common
import qs.services
import qs.components.widgets

MouseArea {
    id: root

    readonly property string username: {
        const user = Quickshell.env("USER");
        return user || "user";
    }

    function forceFieldFocus() {
        passwordField.textInput.forceActiveFocus();
    }

    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.AllButtons
    onPressed: mouse => {
        passwordField.textInput.forceActiveFocus();
    }
    Component.onCompleted: {
        forceFieldFocus();
    }
    Keys.onPressed: event => {
        const modifierKeys = [Qt.Key_Shift, Qt.Key_Control, Qt.Key_Alt, Qt.Key_Meta, Qt.Key_CapsLock, Qt.Key_NumLock, Qt.Key_ScrollLock, Qt.Key_AltGr, Qt.Key_Super_L, Qt.Key_Super_R];
        if (modifierKeys.includes(event.key)) {
            event.accepted = false;
            return;
        }
        Authentication.resetClearTimer();
        root.forceFieldFocus();
        event.accepted = false;
    }

    Connections {
        function onShouldReFocus() {
            root.forceFieldFocus();
        }

        target: Authentication
    }

    LockToolbar {
        id: mainToolbar

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 40
        }

        MaterialSymbol {
            visible: Authentication.fingerprintsConfigured
            icon: "fingerprint"
            fill: 1
            iconSize: Theme.font.size.xl
            fontColor: Colors.current.on_surface_variant
        }

        LockTextField {
            id: passwordField

            implicitWidth: 300
            placeholderText: GlobalStates.screenUnlockFailed ? "Incorrect password" : "Enter password"
        }

        LockButton {
            icon: "arrow_right_alt"
            isActive: true
            enabled: !Authentication.unlockInProgress && Authentication.currentPassword.length > 0
            onClicked: {
                Authentication.tryUnlock();
            }
        }
    }

    LockToolbar {
        id: leftToolbar

        implicitHeight: mainToolbar.height

        anchors {
            right: mainToolbar.left
            rightMargin: 10
            verticalCenter: mainToolbar.verticalCenter
        }

        Row {
            spacing: 8

            MaterialSymbol {
                icon: "account_circle"
                fill: 1
                iconSize: Theme.font.size.large
                fontColor: Colors.current.on_surface_variant
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.username
                color: Colors.current.on_surface
                font.pointSize: Theme.font.size.regular
                font.family: Theme.font.style.departureMono
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            spacing: 8

            MaterialSymbol {
                icon: "keyboard_alt"
                fill: 1
                iconSize: Theme.font.size.large
                fontColor: Colors.current.on_surface_variant
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: HyprlandXkb.currentLayoutCode
                color: Colors.current.on_surface_variant
                font.pointSize: Theme.font.size.regular
                font.family: Theme.font.style.departureMono
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
