import "../../common"
import "../../services"
import QtQuick
import QtQuick.Controls
import Quickshell

Rectangle {
    id: root

    property alias text: textInput.text
    property alias placeholderText: placeholder.text
    property alias textInput: textInput
    property bool shake: false

    implicitWidth: 300
    implicitHeight: 40
    color: Colors.current.surface_container
    radius: Theme.rounding.regular

    SequentialAnimation {
        id: shakeAnimation
        running: root.shake
        NumberAnimation {
            target: root
            property: "x"
            from: root.x
            to: root.x + 10
            duration: 50
        }
        NumberAnimation {
            target: root
            property: "x"
            from: root.x + 10
            to: root.x - 10
            duration: 100
        }
        NumberAnimation {
            target: root
            property: "x"
            from: root.x - 10
            to: root.x + 10
            duration: 100
        }
        NumberAnimation {
            target: root
            property: "x"
            from: root.x + 10
            to: root.x
            duration: 50
        }
        onFinished: {
            root.shake = false;
        }
    }

    TextInput {
        id: textInput
        anchors.fill: parent
        anchors.margins: 10
        echoMode: TextInput.Password
        color: Colors.current.primary
        font.pointSize: Theme.font.size.regular
        font.family: Theme.font.style.departureMono
        verticalAlignment: TextInput.AlignVCenter
        focus: true
        selectByMouse: true

        onTextChanged: {
            Authentication.currentPassword = text;
        }

        Connections {
            target: Authentication
            function onCurrentPasswordChanged() {
                if (Authentication.currentPassword === "") {
                    textInput.text = "";
                }
            }
        }

        Keys.onReturnPressed: {
            if (text.length > 0) {
                Authentication.tryUnlock();
            }
        }

        Keys.onEscapePressed: {
            textInput.text = "";
            Authentication.clearPassword();
        }
    }

    Text {
        id: placeholder
        anchors.fill: textInput
        text: "Password"
        color: Colors.current.on_surface_variant
        font: textInput.font
        verticalAlignment: Text.AlignVCenter
        visible: textInput.text.length === 0
        opacity: 0.5
    }

    Connections {
        target: Authentication
        function onFailed() {
            root.shake = true;
        }
    }
}
