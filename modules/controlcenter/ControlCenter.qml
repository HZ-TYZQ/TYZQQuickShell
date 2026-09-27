import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets

PanelPopup {
    id: root

    name: "control"
    blurItem: card

    Card {
        id: card

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.gap - 4
        anchors.rightMargin: Theme.gap
        width: 420
        height: Math.min(root.height - Theme.gap * 2, (pages.item?.implicitHeight ?? 0) + padding * 2)
        opacity: root.progress
        transform: Translate {
            y: (1 - root.progress) * -24
        }

        Behavior on height {
            NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutCubic }
        }

        Loader {
            id: pages
            anchors.fill: parent
            sourceComponent: {
                switch (Ui.controlPage) {
                case "wifi": return wifiPage;
                case "bluetooth": return btPage;
                case "audio": return audioPage;
                case "wallpaper": return wallpaperPage;
                default: return mainPage;
                }
            }
        }
    }

    Component {
        id: mainPage
        MainPage {}
    }
    Component {
        id: wifiPage
        WifiPage {}
    }
    Component {
        id: btPage
        BluetoothPage {}
    }
    Component {
        id: audioPage
        AudioPage {}
    }
    Component {
        id: wallpaperPage
        WallpaperPage {}
    }
}
