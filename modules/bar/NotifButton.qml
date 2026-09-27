import QtQuick
import qs.config
import qs.services
import qs.widgets

IconButton {
    id: root

    icon: Notifs.dnd ? "notifications_off" : Notifs.count > 0 ? "notifications_unread" : "notifications"
    iconSize: 18
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Notifs.toggleDnd();
        else
            Ui.toggle("control");
    }

    Rectangle {
        visible: Notifs.count > 0 && !Notifs.dnd
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 3
        width: Math.max(14, badge.implicitWidth + 6)
        height: 14
        radius: 7
        color: Theme.primary

        StyledText {
            id: badge
            anchors.centerIn: parent
            text: Notifs.count > 99 ? "99+" : Notifs.count
            font.pixelSize: 9
            font.weight: Font.Bold
            color: Theme.fgPrimary
        }
    }
}
