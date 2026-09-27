import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    spacing: 12
    implicitHeight: 56 + 12 + Math.min(list.contentHeight, 480) + 12 + 40

    Component.onCompleted: Bt.setDiscovering(true)
    Component.onDestruction: Bt.setDiscovering(false)

    PageHeader {
        title: "蓝牙"

        StyledSwitch {
            anchors.verticalCenter: parent.verticalCenter
            checked: Bt.enabled
            onToggled: {
                Bt.toggle();
                if (!Bt.enabled)
                    discoverDelay.start();
            }
        }
    }

    Timer {
        id: discoverDelay
        interval: 1500
        onTriggered: Bt.setDiscovering(true)
    }

    ListView {
        id: list

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 60
        clip: true
        spacing: 6
        model: Bt.enabled ? Bt.devices.filter(d => d.paired || d.name !== d.address.replace(/:/g, "-")) : []
        boundsBehavior: Flickable.StopAtBounds

        StyledText {
            anchors.centerIn: parent
            visible: list.count === 0
            text: Bt.enabled ? "正在搜索设备…" : "蓝牙已关闭"
            color: Theme.outline
        }

        delegate: Rectangle {
            id: item

            required property var modelData
            readonly property var d: modelData
            readonly property bool busy: d.pairing || d.state === BluetoothDeviceState.Connecting || d.state === BluetoothDeviceState.Disconnecting

            width: list.width
            implicitHeight: 60
            radius: Theme.radius.normal
            color: d.connected ? Qt.alpha(Theme.primary, 0.16) : Theme.layer1

            StateLayer {
                onClicked: mouse => mouse.button === Qt.RightButton && item.d.paired ? item.d.forget() : Bt.activate(item.d)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                MaterialIcon {
                    icon: Bt.deviceIcon(item.d)
                    fill: item.d.connected ? 1 : 0
                    color: item.d.connected ? Theme.primary : Theme.fg
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        Layout.fillWidth: true
                        text: item.d.name || item.d.deviceName || item.d.address
                        font.weight: item.d.connected ? Font.DemiBold : Font.Normal
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: item.d.pairing ? "配对中…" : item.busy ? "处理中…" : item.d.connected ? "已连接" : item.d.paired ? "已配对" : "点击配对"
                        font.pixelSize: Theme.fontSize.small
                        color: Theme.fgVariant
                    }
                }
                Row {
                    visible: item.d.batteryAvailable
                    spacing: 2
                    MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "battery_full"
                        rotation: 90
                        size: 16
                        color: Theme.fgVariant
                    }
                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(item.d.battery * 100) + "%"
                        font.pixelSize: Theme.fontSize.small
                        color: Theme.fgVariant
                    }
                }
            }
        }
    }

    TextButton {
        Layout.alignment: Qt.AlignRight
        icon: "settings"
        text: "蓝牙设置"
        onClicked: {
            Ui.close();
            Quickshell.execDetached(["sh", "-c", "command -v blueman-manager >/dev/null && exec blueman-manager || exec kitty bluetoothctl"]);
        }
    }
}
