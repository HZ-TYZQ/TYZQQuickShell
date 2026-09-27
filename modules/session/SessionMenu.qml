import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.widgets

PanelPopup {
    id: root

    name: "session"
    overlay: true
    dim: true
    focusMode: WlrKeyboardFocus.Exclusive
    blurItem: keys
    blurRadius: 0

    property int current: 0

    readonly property var actions: [
        { icon: "lock", label: "锁定", key: "L", run: () => Ui.lock() },
        { icon: "bedtime", label: "睡眠", key: "S", run: () => {
                if (Config.options.lockBeforeSuspend)
                    Ui.lock();
                Quickshell.execDetached(["systemctl", "suspend"]);
            } },
        { icon: "logout", label: "注销", key: "E", run: () => Niri.action("quit", "--skip-confirmation") },
        { icon: "restart_alt", label: "重启", key: "R", run: () => Quickshell.execDetached(["systemctl", "reboot"]) },
        { icon: "power_settings_new", label: "关机", key: "P", run: () => Quickshell.execDetached(["systemctl", "poweroff"]) }
    ]

    function trigger(i) {
        const a = actions[i];
        Ui.close();
        a.run();
    }

    onShownChanged: if (shown) {
        current = 0;
        keys.forceActiveFocus();
    }

    Item {
        id: keys

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Ui.close()
        Keys.onLeftPressed: root.current = (root.current + root.actions.length - 1) % root.actions.length
        Keys.onRightPressed: root.current = (root.current + 1) % root.actions.length
        Keys.onTabPressed: root.current = (root.current + 1) % root.actions.length
        Keys.onReturnPressed: root.trigger(root.current)
        Keys.onEnterPressed: root.trigger(root.current)
        Keys.onPressed: event => {
            const i = root.actions.findIndex(a => a.key === event.text.toUpperCase());
            if (i >= 0) {
                root.trigger(i);
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 28
        opacity: root.progress
        scale: 0.94 + 0.06 * root.progress

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "再见，" + SysInfo.user
            font.pixelSize: Theme.fontSize.huge
            font.weight: Font.Bold
            color: "white"
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 18

            Repeater {
                model: root.actions

                delegate: ColumnLayout {
                    id: btn

                    required property var modelData
                    required property int index
                    readonly property bool selected: root.current === index

                    spacing: 10

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 104
                        implicitHeight: 104
                        radius: btn.selected ? 34 : 52
                        color: btn.selected ? (btn.index === 4 ? Theme.error : Theme.primary) : Theme.panelBg
                        border.width: 1
                        border.color: Qt.alpha(Theme.outlineVariant, 0.6)

                        Behavior on radius {
                            NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutCubic }
                        }
                        Behavior on color {
                            ColorAnimation { duration: Theme.anim.fast }
                        }

                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: btn.modelData.icon
                            size: 40
                            fill: btn.selected ? 1 : 0
                            color: btn.selected ? (btn.index === 4 ? Theme.fgError : Theme.fgPrimary) : Theme.fg
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.current = btn.index
                            onClicked: root.trigger(btn.index)
                        }
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: btn.modelData.label
                        font.pixelSize: Theme.fontSize.large
                        font.weight: Font.Medium
                        color: "white"
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: btn.modelData.key
                        font.pixelSize: Theme.fontSize.small
                        font.family: Theme.fontMono
                        color: Qt.alpha("white", 0.5)
                    }
                }
            }
        }
    }
}
