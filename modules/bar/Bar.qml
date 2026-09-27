import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.widgets

PanelWindow {
    id: bar

    required property ShellScreen modelData
    readonly property int margin: 8

    screen: modelData
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight + margin
    exclusiveZone: Theme.barHeight + margin
    WlrLayershell.namespace: "quickshell-bar"
    WlrLayershell.layer: WlrLayer.Top

    BackgroundEffect.blurRegion: Region {
        item: bg
        radius: bg.radius
    }

    IdleInhibitor {
        window: bar
        enabled: Ui.caffeine
    }

    Rectangle {
        id: bg

        anchors.fill: parent
        anchors.topMargin: bar.margin
        anchors.leftMargin: bar.margin + 2
        anchors.rightMargin: bar.margin + 2
        radius: Theme.radius.full
        color: Theme.barBg
        border.width: 1
        border.color: Qt.alpha(Theme.outlineVariant, 0.5)

        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            LauncherButton {}
            Workspaces {
                screenName: bar.modelData.name
            }
            ActiveWindow {
                Layout.maximumWidth: Math.max(0, bg.width / 2 - center.width / 2 - x - 24)
            }
        }

        RowLayout {
            id: center
            anchors.centerIn: parent
            spacing: 8

            ClockButton {}
            MediaPill {}
        }

        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Tray {
                window: bar
            }
            KeyboardLayout {}
            StatusPill {}
            NotifButton {}
            IconButton {
                icon: "power_settings_new"
                iconSize: 18
                iconColor: Theme.error
                onClicked: Ui.toggle("session")
            }
        }
    }
}
