pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets
import qs.modules.controlcenter.atoms

Flickable {
    id: root

    contentWidth: width
    contentHeight: column.implicitHeight + column.anchors.topMargin + column.anchors.bottomMargin
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    function saveKey(text: string): void {
        if (text.trim() === Gemini.apiKey)
            return;
        keyError.text = "";
        Gemini.setApiKey(text, (ok, err) => {
            if (!ok)
                keyError.text = "Could not save the key: " + (err || "keyring error");
            keyField.text = Gemini.apiKey;
        });
    }

    Component.onCompleted: Secrets.refresh()

    component IconBtn: Rectangle {
        id: ib
        property string sym: ""
        property bool on: false
        signal clicked()
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        Layout.alignment: Qt.AlignVCenter
        radius: Theme.ui.radius.md
        color: ibArea.containsMouse ? Colors.surfaceContainerHigh : Colors.surfaceContainer
        border.width: Theme.ui.mainBarHairWidth
        border.color: ibArea.containsMouse ? Colors.hairHot : Colors.hair
        MaterialSymbol {
            anchors.centerIn: parent
            icon: ib.sym
            iconSize: 15
            fontColor: ibArea.containsMouse ? Colors.fgSurface : Colors.inkDim
        }
        MouseArea {
            id: ibArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ib.clicked()
        }
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 26
        anchors.rightMargin: 26
        anchors.topMargin: 22
        anchors.bottomMargin: 24
        spacing: 0

        GroupLabel { Layout.topMargin: 0; text: "API key" }

        GroupBox {
            NoteRow {
                visible: !Secrets.probing && !Secrets.available
                iconSymbol: "key_off"
                label: "No keyring available"
                sub: "Install and start gnome-keyring to store the API key"
            }

            NoteRow {
                visible: !Secrets.probing && Secrets.available && Secrets.locked
                iconSymbol: "lock"
                label: "Keyring locked"
                sub: "Unlock the login keyring to use your API key"
            }

            RowLayout {
                visible: Secrets.ready
                Layout.fillWidth: true
                Layout.margins: 12
                spacing: 8

                StyledTextField {
                    id: keyField
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    echoMode: revealBtn.on ? TextInput.Normal : TextInput.Password
                    text: Gemini.apiKey
                    enabled: !Gemini.keyLoading
                    placeholderText: "AIza…"
                    onEditingFinished: root.saveKey(text)
                }

                IconBtn {
                    sym: "content_paste"
                    onClicked: {
                        keyField.forceActiveFocus();
                        keyField.selectAll();
                        keyField.paste();
                        root.saveKey(keyField.text);
                    }
                }

                IconBtn {
                    id: revealBtn
                    sym: on ? "visibility_off" : "visibility"
                    onClicked: on = !on
                }
            }

            Text {
                id: keyError
                visible: text.length > 0
                Layout.fillWidth: true
                Layout.leftMargin: 14
                Layout.rightMargin: 14
                Layout.bottomMargin: 10
                text: ""
                color: Colors.error
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.caption
                wrapMode: Text.WordWrap
            }
        }

        GroupLabel { text: "Model" }

        GroupBox {
            StyledTextField {
                Layout.fillWidth: true
                Layout.margins: 12
                text: Preferences.geminiModel
                placeholderText: "gemini-2.5-flash"
                onEditingFinished: Preferences.setGeminiModel(text)
            }
        }

        GroupLabel { text: "Generation" }

        GroupBox {
            SliderRow {
                iconSymbol: "thermostat"
                label: "Temperature"
                value: Preferences.geminiTemperature / 2
                valueText: Preferences.geminiTemperature.toFixed(2)
                showSeparator: true
                onMoved: v => Preferences.setGeminiTemperature(v * 2)
            }

            StyledTextField {
                Layout.fillWidth: true
                Layout.margins: 12
                text: Preferences.geminiMaxTokens > 0 ? Preferences.geminiMaxTokens : ""
                placeholderText: "Max output tokens (blank = default)"
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator {
                    bottom: 0
                    top: 1000000
                }
                onEditingFinished: Preferences.setGeminiMaxTokens(parseInt(text) || 0)
            }
        }

        GroupLabel { text: "Tools" }

        GroupBox {
            ToggleRow {
                label: "Web search (Google grounding)"
                checked: Preferences.geminiWebSearch
                onToggled: Preferences.setGeminiWebSearch(!Preferences.geminiWebSearch)
            }
        }

        GroupLabel { text: "System prompt" }

        GroupBox {
            StyledTextField {
                Layout.fillWidth: true
                Layout.margins: 12
                text: Preferences.geminiSystemPrompt
                placeholderText: "Optional instruction for every reply"
                onEditingFinished: Preferences.setGeminiSystemPrompt(text)
            }
        }
    }
}
