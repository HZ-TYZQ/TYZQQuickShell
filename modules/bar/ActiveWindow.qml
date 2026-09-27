import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

RowLayout {
    id: root

    readonly property var win: Niri.focusedWindow
    readonly property var entry: win ? DesktopEntries.heuristicLookup(win.app_id) : null

    spacing: 8
    visible: win !== null
    opacity: visible ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.normal }
    }

    IconImage {
        Layout.preferredWidth: 18
        Layout.preferredHeight: 18
        source: Quickshell.iconPath(root.entry?.icon || root.win?.app_id || "application-x-executable", "application-x-executable")
        asynchronous: true
    }

    StyledText {
        Layout.fillWidth: true
        Layout.maximumWidth: 420
        text: root.win?.title || root.entry?.name || root.win?.app_id || ""
        color: Theme.fgVariant
        font.weight: Font.Medium
    }
}
