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

        Text {
            text: "AI Assistant"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xxl
            font.weight: Font.Medium
        }

        Text {
            Layout.topMargin: 4
            Layout.bottomMargin: 18
            text: "GEMINI · KEY · MODEL · GENERATION"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 2.4
        }

        GroupLabel { text: "API KEY" }

        GroupBox {
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 12
                spacing: 8

                StyledTextField {
                    id: keyField
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    echoMode: revealBtn.on ? TextInput.Normal : TextInput.Password
                    text: Preferences.geminiApiKey
                    placeholderText: "AIza…"
                    onEditingFinished: {
                        Preferences.setGeminiApiKey(text);
                        text = Preferences.geminiApiKey;
                    }
                }

                IconBtn {
                    sym: "content_paste"
                    onClicked: {
                        keyField.forceActiveFocus();
                        keyField.selectAll();
                        keyField.paste();
                        Preferences.setGeminiApiKey(keyField.text);
                        keyField.text = Preferences.geminiApiKey;
                    }
                }

                IconBtn {
                    id: revealBtn
                    sym: on ? "visibility_off" : "visibility"
                    onClicked: on = !on
                }
            }
        }

        GroupLabel { text: "MODEL" }

        GroupBox {
            StyledTextField {
                Layout.fillWidth: true
                Layout.margins: 12
                text: Preferences.geminiModel
                placeholderText: "gemini-2.5-flash"
                onEditingFinished: Preferences.setGeminiModel(text)
            }
        }

        GroupLabel { text: "GENERATION" }

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

        GroupLabel { text: "TOOLS" }

        GroupBox {
            ToggleRow {
                label: "Web search (Google grounding)"
                checked: Preferences.geminiWebSearch
                onToggled: Preferences.setGeminiWebSearch(!Preferences.geminiWebSearch)
            }
        }

        GroupLabel { text: "SYSTEM PROMPT" }

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
