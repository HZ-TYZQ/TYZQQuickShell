import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.widgets

// Volume / brightness on-screen display.
Scope {
    id: root

    property string kind: "volume"
    property bool shown: false
    property bool armed: false

    function show(k) {
        if (!armed)
            return;
        kind = k;
        shown = true;
        hide.restart();
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: root.armed = true
    }
    Timer {
        id: hide
        interval: 1600
        onTriggered: root.shown = false
    }

    Connections {
        target: Audio.sink?.audio ?? null
        function onVolumeChanged() {
            root.show("volume");
        }
        function onMutedChanged() {
            root.show("volume");
        }
    }
    Connections {
        target: Audio.source?.audio ?? null
        function onMutedChanged() {
            root.show("mic");
        }
    }
    Connections {
        target: Brightness
        function onRawChanged() {
            root.show("brightness");
        }
    }

    PanelWindow {
        id: win

        property real progress: root.shown ? 1 : 0

        screen: Ui.activeScreen
        visible: progress > 0.001
        color: "transparent"
        anchors.bottom: true
        margins.bottom: 90
        implicitWidth: 340
        implicitHeight: 64
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        mask: Region {}

        BackgroundEffect.blurRegion: Region {
            item: root.shown ? card : null
            radius: card.radius
        }

        Behavior on progress {
            NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutCubic }
        }

        Card {
            id: card

            readonly property real value: root.kind === "brightness" ? Brightness.value : root.kind === "mic" ? Audio.micVolume : Audio.volume
            readonly property bool muted: root.kind === "volume" ? Audio.muted : root.kind === "mic" ? Audio.micMuted : false

            anchors.fill: parent
            radius: height / 2
            padding: 0
            opacity: win.progress
            scale: 0.9 + 0.1 * win.progress

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 22
                spacing: 14

                MaterialIcon {
                    icon: root.kind === "brightness" ? "brightness_6" : root.kind === "mic" ? (card.muted ? "mic_off" : "mic") : Audio.icon
                    size: 24
                    fill: 1
                    color: card.muted ? Theme.error : Theme.primary
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Theme.layer2

                    Rectangle {
                        width: parent.width * Math.min(1, card.value)
                        height: parent.height
                        radius: 4
                        color: card.muted ? Theme.outline : Theme.primary

                        Behavior on width {
                            NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.OutCubic }
                        }
                    }
                }

                StyledText {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: card.muted ? "静音" : Math.round(card.value * 100)
                    font.weight: Font.DemiBold
                    font.features: ({ "tnum": 1 })
                }
            }
        }
    }
}
