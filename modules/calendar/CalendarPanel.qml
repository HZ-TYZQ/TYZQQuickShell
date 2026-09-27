import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets

PanelPopup {
    id: root

    name: "calendar"
    blurItem: card

    property int monthOffset: 0
    readonly property date today: clock.date
    readonly property date shownMonth: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)

    onShownChanged: if (shown) monthOffset = 0

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Card {
        id: card

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Theme.gap - 4
        width: 360
        height: layout.implicitHeight + padding * 2
        padding: 20
        opacity: root.progress
        transform: Translate {
            y: (1 - root.progress) * -24
        }

        ColumnLayout {
            id: layout

            anchors.fill: parent
            spacing: 14

            // Big clock
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    text: Qt.formatTime(clock.date, "HH:mm:ss")
                    font.pixelSize: 42
                    font.weight: Font.Bold
                    font.features: ({ "tnum": 1 })
                    color: Theme.primary
                }
                StyledText {
                    text: Qt.locale("zh_CN").toString(clock.date, "yyyy年M月d日 dddd")
                    font.pixelSize: Theme.fontSize.large
                    color: Theme.fgVariant
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.outlineVariant
            }

            // Month nav
            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: Qt.formatDate(root.shownMonth, "yyyy年 M月")
                    font.pixelSize: Theme.fontSize.large
                    font.weight: Font.DemiBold
                }
                IconButton {
                    visible: root.monthOffset !== 0
                    icon: "today"
                    iconSize: 18
                    onClicked: root.monthOffset = 0
                }
                IconButton {
                    icon: "chevron_left"
                    onClicked: root.monthOffset--
                }
                IconButton {
                    icon: "chevron_right"
                    onClicked: root.monthOffset++
                }
            }

            // Grid
            GridLayout {
                id: grid

                Layout.fillWidth: true
                columns: 7
                rowSpacing: 2
                columnSpacing: 2

                readonly property int firstWeekday: (root.shownMonth.getDay() + 6) % 7 // Monday = 0
                readonly property date gridStart: new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth(), 1 - firstWeekday)

                Repeater {
                    model: ["一", "二", "三", "四", "五", "六", "日"]
                    delegate: StyledText {
                        required property string modelData
                        required property int index
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.pixelSize: Theme.fontSize.small
                        font.weight: Font.DemiBold
                        color: index >= 5 ? Theme.tertiary : Theme.fgVariant
                    }
                }

                Repeater {
                    model: 42
                    delegate: Rectangle {
                        id: day

                        required property int index
                        readonly property date d: new Date(grid.gridStart.getFullYear(), grid.gridStart.getMonth(), grid.gridStart.getDate() + index)
                        readonly property bool inMonth: d.getMonth() === root.shownMonth.getMonth()
                        readonly property bool isToday: d.toDateString() === root.today.toDateString()

                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: 20
                        color: isToday ? Theme.primary : "transparent"

                        StyledText {
                            anchors.centerIn: parent
                            text: day.d.getDate()
                            font.weight: day.isToday ? Font.Bold : Font.Normal
                            color: day.isToday ? Theme.fgPrimary : !day.inMonth ? Qt.alpha(Theme.outline, 0.5) : (day.index % 7 >= 5) ? Theme.tertiary : Theme.fg
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel => root.monthOffset += wheel.angleDelta.y > 0 ? -1 : 1
        }
    }
}
