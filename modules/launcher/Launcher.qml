import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

// App launcher. Also: "=1+2" calculator, ">cmd" runs a shell command.
PanelPopup {
    id: root

    name: "launcher"
    overlay: true
    dim: true
    focusMode: WlrKeyboardFocus.Exclusive
    blurItem: card

    property string query: ""
    readonly property real contentHeight: mode === "apps" ? Math.max(80, Math.min(results.length, 7) * 60) : 72
    readonly property string mode: query.startsWith(">") ? "cmd" : (query.startsWith("=") || /^[\d\s.()]+[-+*/%^][\d\s.()+\-*/%^]*$/.test(query)) ? "calc" : "apps"
    readonly property string calcResult: {
        if (mode !== "calc")
            return "";
        const expr = query.replace(/^=/, "").replace(/\^/g, "**").trim();
        if (!/^[\d\s.+\-*/%()*]+$/.test(expr) || expr === "")
            return "";
        try {
            const r = Function(`"use strict"; return (${expr});`)();
            return Number.isFinite(r) ? String(Math.round(r * 1e10) / 1e10) : "";
        } catch (e) {
            return "";
        }
    }

    readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay)
    readonly property var results: {
        if (mode !== "apps")
            return [];
        const q = query.trim().toLowerCase();
        const usage = Config.options.appUsage ?? {};
        const scored = [];
        for (const e of apps) {
            const s = score(e, q);
            if (s > 0)
                scored.push({ entry: e, score: s + Math.min(60, (usage[e.id] ?? 0) * 4) });
        }
        scored.sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name));
        return scored.slice(0, 50).map(s => s.entry);
    }

    function score(e, q) {
        if (!q)
            return 1;
        const name = e.name.toLowerCase();
        if (name === q)
            return 1000;
        if (name.startsWith(q))
            return 800;
        if (name.split(/[\s\-_.]+/).some(w => w.startsWith(q)))
            return 600;
        if (name.includes(q))
            return 450;
        const extra = [e.genericName, e.id, ...(e.keywords ?? [])].join(" ").toLowerCase();
        if (extra.includes(q))
            return 300;
        if ((e.comment ?? "").toLowerCase().includes(q))
            return 150;
        // fuzzy subsequence
        let i = 0, gaps = 0, last = -1;
        for (let j = 0; j < name.length && i < q.length; j++) {
            if (name[j] === q[i]) {
                if (last >= 0)
                    gaps += j - last - 1;
                last = j;
                i++;
            }
        }
        return i === q.length ? Math.max(1, 100 - gaps * 5) : 0;
    }

    function launch(entry) {
        const usage = Object.assign({}, Config.options.appUsage ?? {});
        usage[entry.id] = (usage[entry.id] ?? 0) + 1;
        Config.options.appUsage = usage;
        if (entry.runInTerminal)
            Quickshell.execDetached(["kitty", "--", ...entry.command]);
        else
            entry.execute();
        Ui.close();
    }

    function accept() {
        if (mode === "cmd") {
            const cmd = query.slice(1).trim();
            if (cmd)
                Quickshell.execDetached(["sh", "-c", cmd]);
            Ui.close();
        } else if (mode === "calc") {
            if (calcResult)
                Quickshell.execDetached(["wl-copy", calcResult]);
            Ui.close();
        } else if (list.currentIndex >= 0 && results.length > 0) {
            launch(results[list.currentIndex]);
        }
    }

    onShownChanged: {
        if (shown) {
            search.text = "";
            search.forceActiveFocus();
            list.currentIndex = 0;
        }
    }

    Card {
        id: card

        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.16 + (1 - root.progress) * 30
        width: Math.min(640, parent.width - 40)
        height: 52 + 12 + root.contentHeight + padding * 2
        opacity: root.progress
        scale: 0.96 + 0.04 * root.progress
        padding: 14
        radius: 28

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            // Search box
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 52
                radius: 26
                color: Theme.layer2

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12

                    MaterialIcon {
                        icon: root.mode === "calc" ? "calculate" : root.mode === "cmd" ? "terminal" : "search"
                        size: 22
                        color: Theme.primary
                    }

                    TextInput {
                        id: search

                        Layout.fillWidth: true
                        color: Theme.fg
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSize.large + 2
                        selectionColor: Theme.primary
                        selectedTextColor: Theme.fgPrimary
                        clip: true
                        focus: true
                        onTextChanged: {
                            root.query = text;
                            list.currentIndex = 0;
                        }
                        onAccepted: root.accept()
                        Keys.onEscapePressed: Ui.close()
                        Keys.onDownPressed: list.incrementCurrentIndex()
                        Keys.onUpPressed: list.decrementCurrentIndex()
                        Keys.onTabPressed: list.incrementCurrentIndex()
                        Keys.onBacktabPressed: list.decrementCurrentIndex()
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_PageDown) {
                                list.currentIndex = Math.min(list.count - 1, list.currentIndex + 7);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_PageUp) {
                                list.currentIndex = Math.max(0, list.currentIndex - 7);
                                event.accepted = true;
                            }
                        }

                        StyledText {
                            anchors.fill: parent
                            visible: !search.text
                            text: "搜索应用，= 计算，> 运行命令"
                            color: Theme.outline
                            font.pixelSize: search.font.pixelSize
                        }
                    }
                }
            }

            Item {
                id: content

                Layout.fillWidth: true
                Layout.preferredHeight: root.contentHeight

                // Calculator / command preview
                Rectangle {
                    anchors.fill: parent
                    visible: root.mode !== "apps"
                    radius: Theme.radius.large
                    color: Theme.layer1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        spacing: 14

                        MaterialIcon {
                            icon: root.mode === "calc" ? "equal" : "play_arrow"
                            size: 26
                            color: Theme.primary
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            StyledText {
                                Layout.fillWidth: true
                                text: root.mode === "calc" ? (root.calcResult || "…") : (root.query.slice(1).trim() || "输入命令")
                                font.pixelSize: root.mode === "calc" ? Theme.fontSize.huge - 4 : Theme.fontSize.large
                                font.family: root.mode === "cmd" ? Theme.fontMono : Theme.fontSans
                                font.weight: Font.DemiBold
                            }
                            StyledText {
                                text: root.mode === "calc" ? "回车复制结果" : "回车在后台运行"
                                font.pixelSize: Theme.fontSize.small
                                color: Theme.fgVariant
                            }
                        }
                    }
                }

                ListView {
                    id: list

                    anchors.fill: parent
                    visible: root.mode === "apps"
                    clip: true
                    model: root.results
                    highlightMoveDuration: 120
                    highlightFollowsCurrentItem: true
                    boundsBehavior: Flickable.StopAtBounds

                    highlight: Rectangle {
                        radius: Theme.radius.large
                        color: Qt.alpha(Theme.primary, 0.18)
                    }

                    StyledText {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        text: "没有找到应用"
                        color: Theme.outline
                    }

                    delegate: Item {
                        id: row

                        required property var modelData
                        required property int index

                        width: list.width
                        height: 60

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: list.currentIndex = row.index
                            onClicked: root.launch(row.modelData)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 14

                            IconImage {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                source: Quickshell.iconPath(row.modelData.icon || "application-x-executable", "application-x-executable")
                                asynchronous: true
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                StyledText {
                                    Layout.fillWidth: true
                                    text: row.modelData.name
                                    font.pixelSize: Theme.fontSize.large
                                    font.weight: Font.Medium
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: row.modelData.comment || row.modelData.genericName || ""
                                    font.pixelSize: Theme.fontSize.small
                                    color: Theme.fgVariant
                                }
                            }
                            MaterialIcon {
                                visible: list.currentIndex === row.index
                                icon: "keyboard_return"
                                size: 18
                                color: Theme.primary
                            }
                        }
                    }
                }
            }
        }
    }
}
