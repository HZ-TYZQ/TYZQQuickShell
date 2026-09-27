import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Polkit
import qs.config
import qs.services
import qs.widgets

// Polkit authentication agent.
Scope {
    id: root

    PolkitAgent {
        id: agent
    }

    PanelWindow {
        id: win

        readonly property var flow: agent.flow
        property real progress: agent.isActive ? 1 : 0

        screen: Ui.activeScreen
        visible: agent.isActive || progress > 0.001
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell-polkit"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: agent.isActive ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        BackgroundEffect.blurRegion: Region {
            item: agent.isActive ? card : null
            radius: card.radius
        }

        Behavior on progress {
            NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutCubic }
        }

        onFlowChanged: {
            input.text = "";
            if (flow)
                input.forceActiveFocus();
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.45 * win.progress
        }

        Card {
            id: card

            anchors.centerIn: parent
            width: 440
            height: layout.implicitHeight + padding * 2
            padding: 24
            radius: 28
            opacity: win.progress
            scale: 0.92 + 0.08 * win.progress

            ColumnLayout {
                id: layout

                anchors.fill: parent
                spacing: 14

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 56
                    implicitHeight: 56
                    radius: 28
                    color: Theme.primaryContainer

                    IconImage {
                        anchors.centerIn: parent
                        visible: (win.flow?.iconName ?? "") !== ""
                        implicitSize: 32
                        source: Quickshell.iconPath(win.flow?.iconName ?? "", true)
                    }
                    MaterialIcon {
                        anchors.centerIn: parent
                        visible: (win.flow?.iconName ?? "") === ""
                        icon: "admin_panel_settings"
                        size: 30
                        fill: 1
                        color: Theme.fgPrimaryContainer
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "需要身份验证"
                    font.pixelSize: Theme.fontSize.title + 2
                    font.weight: Font.DemiBold
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: win.flow?.message ?? ""
                    wrapMode: Text.Wrap
                    color: Theme.fgVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "用户：" + (win.flow?.selectedIdentity?.displayName ?? SysInfo.user)
                    font.pixelSize: Theme.fontSize.small
                    color: Theme.outline
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    implicitHeight: 48
                    radius: 24
                    color: Theme.layer2
                    border.width: 2
                    border.color: win.flow?.supplementaryIsError ? Theme.error : input.activeFocus ? Theme.primary : "transparent"

                    TextInput {
                        id: input

                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: win.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                        color: Theme.fg
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSize.large
                        clip: true
                        focus: true
                        enabled: win.flow?.isResponseRequired ?? false
                        onAccepted: submitBtn.clicked()
                        Keys.onEscapePressed: win.flow?.cancelAuthenticationRequest()

                        StyledText {
                            anchors.fill: parent
                            visible: !input.text
                            text: (win.flow?.inputPrompt || "密码").replace(/[:：]\s*$/, "")
                            color: Theme.outline
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: text !== ""
                    horizontalAlignment: Text.AlignHCenter
                    text: win.flow?.supplementaryMessage ?? ""
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSize.small
                    color: win.flow?.supplementaryIsError ? Theme.error : Theme.fgVariant
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    spacing: 10

                    Item {
                        Layout.fillWidth: true
                    }
                    TextButton {
                        text: "取消"
                        onClicked: win.flow?.cancelAuthenticationRequest()
                    }
                    TextButton {
                        id: submitBtn
                        text: "验证"
                        primary: true
                        onClicked: {
                            if (win.flow?.isResponseRequired) {
                                win.flow.submit(input.text);
                                input.text = "";
                            }
                        }
                    }
                }
            }
        }
    }
}
