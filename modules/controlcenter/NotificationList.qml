import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    spacing: 8
    implicitHeight: header.implicitHeight + 8 + Math.min(list.contentHeight, 420) + (Notifs.count === 0 ? 120 : 0)

    RowLayout {
        id: header
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: Notifs.count > 0 ? `通知 (${Notifs.count})` : "通知"
            font.pixelSize: Theme.fontSize.large
            font.weight: Font.DemiBold
        }

        IconButton {
            icon: Notifs.dnd ? "notifications_off" : "notifications_active"
            iconSize: 18
            toggled: Notifs.dnd
            onClicked: Notifs.toggleDnd()
        }

        Rectangle {
            visible: Notifs.count > 0
            implicitWidth: clearRow.implicitWidth + 20
            implicitHeight: 32
            radius: 16
            color: Theme.layer1

            Row {
                id: clearRow
                anchors.centerIn: parent
                spacing: 4
                MaterialIcon {
                    icon: "clear_all"
                    size: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: "全部清除"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            StateLayer {
                onClicked: Notifs.clearAll()
            }
        }
    }

    ListView {
        id: list

        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: Notifs.count > 0
        clip: true
        spacing: 8
        model: ScriptModel {
            values: Notifs.list
        }
        boundsBehavior: Flickable.StopAtBounds

        delegate: NotificationCard {
            required property var modelData
            width: list.width
            wrapper: modelData
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.anim.normal }
        }
        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: Theme.anim.fast }
        }
        displaced: Transition {
            NumberAnimation { property: "y"; duration: Theme.anim.normal; easing.type: Easing.OutCubic }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: Notifs.count === 0
        spacing: 6

        Item { Layout.fillHeight: true }
        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            icon: "notifications_paused"
            size: 44
            color: Theme.outline
        }
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "没有新通知"
            color: Theme.outline
        }
        Item { Layout.fillHeight: true }
    }
}
