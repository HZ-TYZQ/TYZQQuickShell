import QtQuick
import qs.config
import qs.services
import qs.widgets

BarPill {
    id: root

    required property string screenName
    readonly property var workspaces: Niri.workspacesFor(screenName)

    hPadding: 8
    spacing: 4
    onWheel: wheel => Niri.action(wheel.angleDelta.y > 0 ? "focus-workspace-up" : "focus-workspace-down")

    Repeater {
        model: root.workspaces

        delegate: Item {
            id: ws

            required property var modelData
            readonly property bool active: modelData.is_active
            readonly property bool occupied: modelData.active_window_id !== null || Niri.windowsOn(modelData.id).length > 0

            width: active ? 30 : 14
            height: 20
            anchors.verticalCenter: parent?.verticalCenter

            Behavior on width {
                NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 4
                height: ws.active ? 10 : 8
                radius: height / 2
                color: ws.modelData.is_urgent ? Theme.error : ws.active ? Theme.primary : ws.occupied ? Qt.alpha(Theme.fgVariant, 0.75) : Qt.alpha(Theme.outline, 0.4)

                Behavior on color {
                    ColorAnimation { duration: Theme.anim.fast }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Niri.focusWorkspace(ws.modelData)
            }
        }
    }
}
