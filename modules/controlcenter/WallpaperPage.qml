import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    spacing: 12
    implicitHeight: 56 + 12 + Math.min(grid.contentHeight, 520)

    PageHeader {
        title: "壁纸"

        IconButton {
            icon: "shuffle"
            onClicked: {
                if (folder.count > 0)
                    Config.options.wallpaper = folder.get(Math.floor(Math.random() * folder.count), "filePath");
            }
        }
    }

    FolderListModel {
        id: folder
        folder: "file://" + Config.wallpaperDir
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
    }

    GridView {
        id: grid

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        cellWidth: width / 2
        cellHeight: cellWidth * 0.625 + 28
        model: folder
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
            id: cell

            required property string filePath
            required property string fileBaseName
            readonly property bool current: Config.options.wallpaper === filePath

            width: grid.cellWidth
            height: grid.cellHeight

            ClippingRectangle {
                id: thumb
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 4
                height: width * 0.625
                radius: Theme.radius.normal
                color: Theme.layer1
                border.width: cell.current ? 3 : 0
                border.color: Theme.primary

                Image {
                    anchors.fill: parent
                    source: "file://" + cell.filePath
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize: Qt.size(360, 225)
                }
                StateLayer {
                    onClicked: Config.options.wallpaper = cell.filePath
                }
            }

            StyledText {
                anchors.top: thumb.bottom
                anchors.left: thumb.left
                anchors.right: thumb.right
                anchors.topMargin: 4
                horizontalAlignment: Text.AlignHCenter
                text: cell.fileBaseName.replace(/\|/g, " · ")
                font.pixelSize: Theme.fontSize.small
                color: cell.current ? Theme.primary : Theme.fgVariant
            }
        }
    }
}
