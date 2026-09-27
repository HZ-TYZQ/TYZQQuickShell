import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.config

// Renders one notification wrapper (see services/Notifs.qml).
Rectangle {
    id: root

    required property var wrapper
    property bool isPopup: false
    // The wrapper and notification can be destroyed while the delegate is
    // still playing its remove transition, so every access is null-safe.
    readonly property Notification n: wrapper?.notification ?? null
    readonly property bool critical: n?.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: n?.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: n?.actions.filter(a => a.identifier !== "default") ?? []
    property bool expanded: false

    implicitHeight: layout.implicitHeight + 24
    radius: Theme.radius.large
    color: isPopup ? Theme.panelBg : Theme.layer1
    border.width: critical ? 1.5 : isPopup ? 1 : 0
    border.color: critical ? Theme.error : Qt.alpha(Theme.outlineVariant, 0.6)

    function timeText(t) {
        if (!t)
            return "";
        const diff = (clock.date - t) / 1000;
        if (diff < 60)
            return "刚刚";
        if (diff < 3600)
            return Math.floor(diff / 60) + " 分钟前";
        if (diff < 86400 && clock.date.getDate() === t.getDate())
            return Qt.formatTime(t, "HH:mm");
        return Qt.formatDateTime(t, "M/d HH:mm");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onContainsMouseChanged: {
            if (root.wrapper)
                root.wrapper.hovered = containsMouse;
        }
        onClicked: mouse => {
            if (!root.wrapper || !root.n)
                return;
            if (mouse.button === Qt.MiddleButton) {
                root.n.dismiss();
            } else if (root.defaultAction) {
                root.defaultAction.invoke();
            } else if (root.isPopup) {
                root.wrapper.popup = false;
            } else {
                root.expanded = !root.expanded;
            }
        }
    }

    RowLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 12

        // Image or app icon
        ClippingRectangle {
            id: avatar
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 21
            color: root.critical ? Theme.errorContainer : Theme.secondaryContainer

            readonly property string appIcon: root.n?.appIcon ? Quickshell.iconPath(root.n.appIcon, true) : ""

            Image {
                id: img
                anchors.fill: parent
                visible: status === Image.Ready
                source: root.n?.image ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(84, 84)
            }
            IconImage {
                anchors.centerIn: parent
                visible: !img.visible && avatar.appIcon !== ""
                implicitSize: 26
                source: avatar.appIcon
                asynchronous: true
            }
            MaterialIcon {
                anchors.centerIn: parent
                visible: !img.visible && avatar.appIcon === ""
                icon: root.critical ? "priority_high" : "notifications"
                size: 22
                fill: 1
                color: root.critical ? Theme.error : Theme.fgSecondaryContainer
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    Layout.fillWidth: true
                    text: (root.n?.appName || "通知") + "  ·  " + root.timeText(root.wrapper?.time)
                    font.pixelSize: Theme.fontSize.small
                    color: Theme.fgVariant
                }
                IconButton {
                    icon: "close"
                    iconSize: 16
                    implicitWidth: 24
                    implicitHeight: 24
                    opacity: hover.containsMouse || hovered ? 1 : 0.5
                    onClicked: root.n?.dismiss()
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.n?.summary ?? ""
                font.weight: Font.DemiBold
                font.pixelSize: Theme.fontSize.normal + 1
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }

            StyledText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.n?.body ?? ""
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                maximumLineCount: root.expanded ? 20 : 3
                color: Theme.fgVariant
                linkColor: Theme.primary
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 6
                visible: root.buttons.length > 0
                spacing: 6

                Repeater {
                    model: root.buttons

                    delegate: Rectangle {
                        id: btn
                        required property var modelData
                        implicitWidth: label.implicitWidth + 24
                        implicitHeight: 30
                        radius: 15
                        color: Theme.secondaryContainer

                        StyledText {
                            id: label
                            anchors.centerIn: parent
                            text: btn.modelData.text
                            font.weight: Font.Medium
                            color: Theme.fgSecondaryContainer
                        }
                        StateLayer {
                            onClicked: btn.modelData.invoke()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 6
                visible: root.n?.hasInlineReply ?? false
                implicitHeight: 34
                radius: 17
                color: Theme.layer2

                TextInput {
                    id: reply
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 40
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.fg
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontSize.normal
                    clip: true
                    onAccepted: if (text) root.n?.sendInlineReply(text)

                    StyledText {
                        anchors.fill: parent
                        visible: !parent.text
                        text: root.n?.inlineReplyPlaceholder || "回复…"
                        color: Theme.outline
                    }
                }
                IconButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "send"
                    iconSize: 16
                    onClicked: if (reply.text) root.n?.sendInlineReply(reply.text)
                }
            }
        }
    }
}
