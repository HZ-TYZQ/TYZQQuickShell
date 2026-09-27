import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    property var expanded: null

    spacing: 12
    implicitHeight: 56 + 12 + Math.min(list.contentHeight, 480) + 12 + 40

    Component.onCompleted: Net.setScanning(true)
    Component.onDestruction: Net.setScanning(false)

    PageHeader {
        title: "Wi-Fi"

        StyledSwitch {
            anchors.verticalCenter: parent.verticalCenter
            checked: Net.wifiEnabled
            onToggled: Net.toggleWifi()
        }
    }

    ListView {
        id: list

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 60
        clip: true
        spacing: 6
        model: Net.wifiEnabled ? Net.networks : []
        boundsBehavior: Flickable.StopAtBounds

        StyledText {
            anchors.centerIn: parent
            visible: list.count === 0
            text: Net.wifiEnabled ? "正在扫描…" : "Wi-Fi 已关闭"
            color: Theme.outline
        }

        delegate: Rectangle {
            id: item

            required property var modelData
            readonly property bool open: root.expanded === modelData
            readonly property bool busy: modelData.state === ConnectionState.Connecting || modelData.stateChanging
            property string error: ""

            width: list.width
            implicitHeight: col.implicitHeight + 20
            radius: Theme.radius.normal
            color: modelData.connected ? Qt.alpha(Theme.primary, 0.16) : Theme.layer1

            Connections {
                target: item.modelData
                function onConnectionFailed(reason) {
                    item.error = reason === ConnectionFailReason.NoSecrets ? "密码错误或需要密码" : "连接失败";
                    root.expanded = item.modelData;
                }
                function onConnectedChanged() {
                    if (item.modelData.connected) {
                        item.error = "";
                        if (root.expanded === item.modelData)
                            root.expanded = null;
                    }
                }
            }

            StateLayer {
                onClicked: mouse => {
                    const n = item.modelData;
                    if (mouse.button === Qt.RightButton && n.known) {
                        n.forget();
                    } else if (n.connected) {
                        root.expanded = item.open ? null : n;
                    } else if (n.known || !Net.isSecure(n)) {
                        n.connect();
                    } else {
                        root.expanded = item.open ? null : n;
                    }
                }
            }

            ColumnLayout {
                id: col

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MaterialIcon {
                        icon: Net.wifiIcon(Net.strength(item.modelData))
                        fill: 1
                        color: item.modelData.connected ? Theme.primary : Theme.fg
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            Layout.fillWidth: true
                            text: item.modelData.name
                            font.weight: item.modelData.connected ? Font.DemiBold : Font.Normal
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: item.error || (item.busy ? "连接中…" : item.modelData.connected ? "已连接" : item.modelData.known ? "已保存" : Net.isSecure(item.modelData) ? "加密" : "开放")
                            font.pixelSize: Theme.fontSize.small
                            color: item.error ? Theme.error : Theme.fgVariant
                        }
                    }
                    MaterialIcon {
                        visible: Net.isSecure(item.modelData)
                        icon: "lock"
                        size: 16
                        color: Theme.fgVariant
                    }
                }

                // Connected: actions
                RowLayout {
                    Layout.fillWidth: true
                    visible: item.open && item.modelData.connected
                    spacing: 8

                    Item { Layout.fillWidth: true }
                    TextButton {
                        text: "忘记"
                        onClicked: item.modelData.forget()
                    }
                    TextButton {
                        text: "断开连接"
                        primary: true
                        onClicked: item.modelData.disconnect()
                    }
                }

                // Password entry
                RowLayout {
                    Layout.fillWidth: true
                    visible: item.open && !item.modelData.connected
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 36
                        radius: 18
                        color: Theme.layer2

                        TextInput {
                            id: psk
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            color: Theme.fg
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontSize.normal
                            clip: true
                            focus: item.open
                            onAccepted: connectBtn.clicked()

                            StyledText {
                                anchors.fill: parent
                                visible: !psk.text
                                text: "输入密码"
                                color: Theme.outline
                            }
                        }
                    }
                    TextButton {
                        id: connectBtn
                        text: "连接"
                        primary: true
                        onClicked: {
                            if (psk.text.length > 0) {
                                item.error = "";
                                item.modelData.connectWithPsk(psk.text);
                            }
                        }
                    }
                }
            }
        }
    }

    TextButton {
        Layout.alignment: Qt.AlignRight
        icon: "settings"
        text: "网络设置"
        onClicked: {
            Ui.close();
            Quickshell.execDetached(["sh", "-c", "command -v nm-connection-editor >/dev/null && exec nm-connection-editor || exec kitty nmtui"]);
        }
    }
}
