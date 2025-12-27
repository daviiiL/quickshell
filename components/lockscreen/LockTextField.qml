import QtQuick
import qs.common
import qs.services

Rectangle {
    id: root
    radius: Theme.ui.radius.lg

    property alias text: textInput.text
    property alias placeholderText: placeholder.text
    property alias textInput: textInput
    property bool shake: false

    implicitWidth: 300
    implicitHeight: 40
    color: Colors.current.surface_container

    SequentialAnimation {
        id: shakeAnimation

        running: root.shake
        onFinished: {
            root.shake = false;
        }

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
    }

    TextInput {
        id: textInput

        anchors.fill: parent
        anchors.margins: 10
        echoMode: TextInput.Password
        color: Colors.current.primary
        font.pointSize: Theme.font.size.md
        font.family: Theme.font.family.inter_regular
        verticalAlignment: TextInput.AlignVCenter
        focus: true
        selectByMouse: true

        clip: true

        onTextChanged: {
            Authentication.currentPassword = text;
        }
        Keys.onReturnPressed: {
            if (text.length > 0)
                Authentication.tryUnlock();
        }
        Keys.onEscapePressed: {
            textInput.text = "";
            Authentication.clearPassword();
        }

        Connections {
            function onCurrentPasswordChanged() {
                if (Authentication.currentPassword === "")
                    textInput.text = "";
            }

            target: Authentication
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
        function onFailed() {
            root.shake = true;
        }

        target: Authentication
    }
}
