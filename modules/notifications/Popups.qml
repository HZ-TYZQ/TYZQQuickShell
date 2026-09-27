import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.widgets

// Notification toasts in the top-right corner.
PanelWindow {
    id: root

    screen: Ui.activeScreen
    visible: Notifs.popups.length > 0 && Ui.panel !== "control" && !Ui.locked
    color: "transparent"
    anchors {
        top: true
        right: true
        bottom: true
    }
    margins.top: 2
    implicitWidth: 400
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    mask: Region {
        item: list.contentItem
    }

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: Theme.gap
        anchors.topMargin: 4
        spacing: 8
        interactive: false
        model: ScriptModel {
            values: Notifs.popups
        }

        delegate: NotificationCard {
            required property var modelData
            width: list.width
            wrapper: modelData
            isPopup: true
        }

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.anim.normal }
                NumberAnimation { property: "x"; from: 80; to: 0; duration: Theme.anim.slow; easing.type: Easing.OutBack; easing.overshoot: 0.8 }
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: Theme.anim.fast }
                NumberAnimation { property: "x"; to: 120; duration: Theme.anim.normal; easing.type: Easing.InCubic }
            }
        }
        displaced: Transition {
            NumberAnimation { property: "y"; duration: Theme.anim.normal; easing.type: Easing.OutCubic }
        }
    }
}
