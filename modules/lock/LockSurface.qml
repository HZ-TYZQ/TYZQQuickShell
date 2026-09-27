import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    required property var lock
    property real reveal: 0

    Component.onCompleted: reveal = 1
    Behavior on reveal {
        NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.OutCubic }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Blurred wallpaper
    Image {
        id: wall
        anchors.fill: parent
        source: "file://" + Config.options.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
        sourceSize: Qt.size(parent.width / 2, parent.height / 2)
    }
    MultiEffect {
        anchors.fill: parent
        source: wall
        blurEnabled: true
        blur: 1
        blurMax: 64
        brightness: -0.18
        saturation: 0.1
        opacity: root.reveal
    }
    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.surface, 0.25)
    }

    // Keyboard capture
    Item {
        anchors.fill: parent
        focus: true
        Component.onCompleted: forceActiveFocus()
        Keys.onPressed: event => {
            if (root.lock.busy)
                return;
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.lock.submit();
            } else if (event.key === Qt.Key_Backspace) {
                root.lock.buffer = event.modifiers & Qt.ControlModifier ? "" : root.lock.buffer.slice(0, -1);
            } else if (event.key === Qt.Key_Escape) {
                root.lock.buffer = "";
            } else if (event.text && event.text.charCodeAt(0) >= 32) {
                root.lock.buffer += event.text;
                root.lock.status = "";
            }
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.14
        spacing: 0
        opacity: root.reveal
        transform: Translate {
            y: (1 - root.reveal) * -40
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(clock.date, "HH:mm")
            font.pixelSize: 120
            font.weight: Font.Bold
            font.features: ({ "tnum": 1 })
            color: Theme.fgPrimaryContainer
        }
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.locale("zh_CN").toString(clock.date, "yyyy年M月d日 dddd")
            font.pixelSize: Theme.fontSize.title + 2
            font.weight: Font.Medium
            color: Theme.fg
        }
    }

    // Password area
    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * 0.12
        spacing: 16
        opacity: root.reveal

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 88
            implicitHeight: 88
            radius: 44
            color: Theme.primaryContainer
            border.width: 3
            border.color: Qt.alpha(Theme.primary, 0.6)

            StyledText {
                anchors.centerIn: parent
                text: SysInfo.user.charAt(0).toUpperCase()
                font.pixelSize: 40
                font.weight: Font.Bold
                color: Theme.fgPrimaryContainer
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: SysInfo.user
            font.pixelSize: Theme.fontSize.title
            font.weight: Font.DemiBold
        }

        Rectangle {
            id: field

            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 340
            implicitHeight: 52
            radius: 26
            color: Theme.panelBg
            border.width: 2
            border.color: root.lock.status && !root.lock.busy ? Theme.error : Qt.alpha(Theme.primary, root.lock.buffer ? 0.8 : 0.3)

            transform: Translate {
                id: shakeT
            }

            Behavior on border.color {
                ColorAnimation { duration: Theme.anim.fast }
            }

            SequentialAnimation {
                id: shake
                loops: 2
                NumberAnimation { target: shakeT; property: "x"; to: 24; duration: 50 }
                NumberAnimation { target: shakeT; property: "x"; to: -24; duration: 80 }
                NumberAnimation { target: shakeT; property: "x"; to: 0; duration: 50 }
            }
            Connections {
                target: root.lock
                function onFailed() {
                    shake.start();
                }
            }

            MaterialIcon {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                icon: root.lock.busy ? "hourglass_top" : "lock"
                color: Theme.primary
                fill: 1
            }

            Row {
                anchors.centerIn: parent
                spacing: 8
                visible: root.lock.buffer.length > 0

                Repeater {
                    model: Math.min(root.lock.buffer.length, 20)
                    delegate: Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: Theme.fg
                        NumberAnimation on scale {
                            from: 0
                            to: 1
                            duration: Theme.anim.fast
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }

            StyledText {
                anchors.centerIn: parent
                visible: root.lock.buffer.length === 0
                text: root.lock.status || "输入密码解锁"
                color: root.lock.status && !root.lock.busy ? Theme.error : Theme.outline
            }

            IconButton {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                icon: "arrow_forward"
                toggled: root.lock.buffer.length > 0
                onClicked: root.lock.submit()
            }
        }
    }

    // Bottom status / actions
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 28
        spacing: 12
        opacity: root.reveal

        Row {
            spacing: 14
            MaterialIcon {
                icon: Net.icon
                fill: 1
            }
            Row {
                visible: UPower.displayDevice?.isLaptopBattery ?? false
                spacing: 4
                MaterialIcon {
                    rotation: 90
                    icon: UPower.onBattery ? "battery_5_bar" : "battery_charging_full"
                    fill: 1
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round((UPower.displayDevice?.percentage ?? 0) * 100) + "%"
                    font.weight: Font.DemiBold
                }
            }
        }

        // Mini media controls
        Item {
            Layout.fillWidth: true
            implicitHeight: 44

            Rectangle {
                anchors.centerIn: parent
                visible: Media.active
                implicitWidth: mediaRow.implicitWidth + 24
                implicitHeight: 44
                radius: 22
                color: Theme.panelBg

                RowLayout {
                    id: mediaRow
                    anchors.centerIn: parent
                    spacing: 6
                    MaterialIcon {
                        icon: "music_note"
                        color: Theme.primary
                    }
                    StyledText {
                        Layout.maximumWidth: 280
                        text: Media.artist ? `${Media.title} · ${Media.artist}` : Media.title
                    }
                    IconButton {
                        icon: "skip_previous"
                        iconSize: 18
                        onClicked: Media.previous()
                    }
                    IconButton {
                        icon: Media.playing ? "pause" : "play_arrow"
                        iconSize: 18
                        onClicked: Media.toggle()
                    }
                    IconButton {
                        icon: "skip_next"
                        iconSize: 18
                        onClicked: Media.next()
                    }
                }
            }
        }

        IconButton {
            icon: "bedtime"
            baseColor: Theme.panelBg
            onClicked: Quickshell.execDetached(["systemctl", "suspend"])
        }
        IconButton {
            icon: "restart_alt"
            baseColor: Theme.panelBg
            onClicked: Quickshell.execDetached(["systemctl", "reboot"])
        }
        IconButton {
            icon: "power_settings_new"
            baseColor: Theme.panelBg
            iconColor: Theme.error
            onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
        }
    }
}
