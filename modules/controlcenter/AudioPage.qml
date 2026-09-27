import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    spacing: 12

    PageHeader {
        title: "声音"
    }

    StyledText {
        text: "输出"
        font.weight: Font.DemiBold
        color: Theme.primary
    }
    StyledSlider {
        Layout.fillWidth: true
        icon: Audio.icon
        value: Audio.volume
        accent: Audio.muted ? Theme.outline : Theme.primary
        onMoved: Audio.setVolume(value)
        onIconClicked: Audio.toggleMute()
    }
    Repeater {
        model: Audio.sinks
        delegate: DeviceRow {
            required property var modelData
            node: modelData
            icon: modelData.properties["device.icon-name"]?.includes("headset") ? "headphones" : "speaker"
            selected: Audio.sink === modelData
            onClicked: Audio.setDefaultSink(modelData)
        }
    }

    StyledText {
        Layout.topMargin: 6
        text: "输入"
        font.weight: Font.DemiBold
        color: Theme.primary
    }
    StyledSlider {
        Layout.fillWidth: true
        icon: Audio.micMuted ? "mic_off" : "mic"
        value: Audio.micVolume
        accent: Audio.micMuted ? Theme.outline : Theme.primary
        onMoved: Audio.setMicVolume(value)
        onIconClicked: Audio.toggleMicMute()
    }
    Repeater {
        model: Audio.sources
        delegate: DeviceRow {
            required property var modelData
            node: modelData
            icon: "mic"
            selected: Audio.source === modelData
            onClicked: Audio.setDefaultSource(modelData)
        }
    }

    // Per-application volume
    StyledText {
        Layout.topMargin: 6
        visible: streams.count > 0
        text: "应用"
        font.weight: Font.DemiBold
        color: Theme.primary
    }
    Repeater {
        id: streams
        model: Pipewire.nodes.values.filter(n => n.isStream && n.isSink && n.audio)

        delegate: ColumnLayout {
            id: stream
            required property var modelData
            Layout.fillWidth: true
            spacing: 4

            PwObjectTracker {
                objects: [stream.modelData]
            }
            StyledText {
                Layout.fillWidth: true
                text: (stream.modelData.properties["application.name"] ?? stream.modelData.name) + (stream.modelData.properties["media.name"] ? " — " + stream.modelData.properties["media.name"] : "")
                font.pixelSize: Theme.fontSize.small
                color: Theme.fgVariant
            }
            StyledSlider {
                Layout.fillWidth: true
                implicitHeight: 32
                icon: stream.modelData.audio?.muted ? "volume_off" : "music_note"
                value: stream.modelData.audio?.volume ?? 0
                onMoved: if (stream.modelData.audio) stream.modelData.audio.volume = value
                onIconClicked: if (stream.modelData.audio) stream.modelData.audio.muted = !stream.modelData.audio.muted
            }
        }
    }

    component DeviceRow: Rectangle {
        id: row
        property var node
        property string icon
        property bool selected
        signal clicked

        Layout.fillWidth: true
        implicitHeight: 44
        radius: Theme.radius.normal
        color: selected ? Qt.alpha(Theme.primary, 0.16) : Theme.layer1

        StateLayer {
            onClicked: row.clicked()
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12
            MaterialIcon {
                icon: row.icon
                size: 18
                color: row.selected ? Theme.primary : Theme.fg
            }
            StyledText {
                Layout.fillWidth: true
                text: Audio.nodeName(row.node)
                font.weight: row.selected ? Font.DemiBold : Font.Normal
            }
            MaterialIcon {
                visible: row.selected
                icon: "check"
                size: 18
                color: Theme.primary
            }
        }
    }
}
