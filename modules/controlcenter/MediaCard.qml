import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

ClippingRectangle {
    id: root

    readonly property bool hasArt: art.status === Image.Ready

    implicitHeight: 108
    radius: Theme.radius.large
    color: Theme.layer1

    // Faded album art backdrop
    Image {
        id: art
        anchors.fill: parent
        source: Media.artUrl
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: 0.18
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 14

        ClippingRectangle {
            Layout.preferredWidth: 84
            Layout.preferredHeight: 84
            radius: Theme.radius.normal
            color: Theme.secondaryContainer

            Image {
                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(168, 168)
            }
            MaterialIcon {
                anchors.centerIn: parent
                visible: !root.hasArt
                icon: "music_note"
                size: 36
                color: Theme.fgSecondaryContainer
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                text: Media.title
                font.pixelSize: Theme.fontSize.large
                font.weight: Font.DemiBold
            }
            StyledText {
                Layout.fillWidth: true
                text: Media.artist
                color: Theme.fgVariant
            }

            Item {
                id: progress

                readonly property real len: Media.player?.length ?? 0
                Layout.fillWidth: true
                Layout.topMargin: 6
                implicitHeight: 4
                visible: (Media.player?.lengthSupported ?? false) && len > 0

                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: Qt.alpha(Theme.fg, 0.15)
                }
                Rectangle {
                    width: parent.width * Math.min(1, (Media.player?.position ?? 0) / Math.max(1, progress.len))
                    height: parent.height
                    radius: 2
                    color: Theme.primary
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    enabled: Media.player?.canSeek ?? false
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => Media.player.position = progress.len * Math.max(0, Math.min(1, (mouse.x - 6) / progress.width))
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: progress.visible ? `${Media.formatTime(Media.player.position)} / ${Media.formatTime(progress.len)}` : (Media.player?.identity ?? "")
                    font.pixelSize: Theme.fontSize.small
                    font.features: ({ "tnum": 1 })
                    color: Theme.fgVariant
                }
                IconButton {
                    visible: Media.players.length > 1
                    icon: "swap_horiz"
                    iconSize: 18
                    onClicked: Media.cycle()
                }
                IconButton {
                    icon: "skip_previous"
                    iconSize: 20
                    onClicked: Media.previous()
                }
                IconButton {
                    icon: Media.playing ? "pause" : "play_arrow"
                    iconSize: 22
                    toggled: true
                    onClicked: Media.toggle()
                }
                IconButton {
                    icon: "skip_next"
                    iconSize: 20
                    onClicked: Media.next()
                }
            }
        }
    }
}
