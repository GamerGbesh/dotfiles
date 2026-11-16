import QtQuick

// Weekly grid. Drag across empty cells to add a block, click a block to edit
// it, click a time header to edit or remove that slot.
Rectangle {
    id: panel

    required property var store
    signal closeRequested()

    readonly property var tt: store.tt
    readonly property var slots: tt.slots
    readonly property var days: tt.showWeekend ? [0, 1, 2, 3, 4, 5, 6] : [0, 1, 2, 3, 4]
    readonly property var dayNames: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // Live "now" markers, refreshed every 30s.
    property int today: 0
    property int nowSlot: -1

    // Drag selection.
    property int selDay: -1
    property int selA: -1
    property int selB: -1

    readonly property int pad: 20
    readonly property int dayColWidth: 72
    readonly property int headerHeight: 48
    readonly property real rowHeight: Math.max(64, Math.min(96, ((parent ? parent.height : 900) - 260) / days.length))
    readonly property real cellWidth: (width - 2 * pad - dayColWidth) / Math.max(1, slots.length)

    width: Math.min(parent ? parent.width - 80 : 1400, 1600)
    height: topBar.height + headerHeight + days.length * rowHeight + hint.height + 4 * pad
    radius: Theme.windowRadius
    color: Theme.base
    border.width: 1
    border.color: Theme.surface1
    clip: true

    focus: true
    Keys.onEscapePressed: back()

    function back() {
        if (editor.visible) editor.close();
        else if (slotEditor.visible) slotEditor.close();
        else closeRequested();
    }

    // Briefly show an error in the footer (e.g. can't remove a slot in use).
    property string notice: ""
    function notify(msg) {
        notice = msg || "";
        if (notice) noticeTimer.restart();
    }

    Timer {
        id: noticeTimer
        interval: 3500
        onTriggered: panel.notice = ""
    }

    function refreshNow() {
        const d = new Date();
        today = (d.getDay() + 6) % 7;
        const m = d.getHours() * 60 + d.getMinutes();
        nowSlot = slots.findIndex(s => store.toMin(s.start) <= m && m < store.toMin(s.end));
    }

    function slotAt(x) {
        return Math.max(0, Math.min(slots.length - 1, Math.floor(x / cellWidth)));
    }

    // Grow the selection from `a` toward `b`, stopping at the first occupied cell.
    function clampSel(day, a, b) {
        const step = b >= a ? 1 : -1;
        let s = a;
        while (s !== b && store.occupant(day, s + step, -1) < 0) s += step;
        return s;
    }

    function openNew(day, start, span) {
        editor.open(-1, { day: day, start: start, span: span, title: "", location: "", note: "", color: store.nextColor() });
    }

    function openEdit(index) {
        editor.open(index, tt.entries[index]);
    }

    onSlotsChanged: refreshNow()

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: panel.refreshNow()
    }

    // ---- Top bar -------------------------------------------------------

    Item {
        id: topBar
        x: panel.pad
        y: panel.pad
        width: panel.width - 2 * panel.pad
        height: 36

        Text {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            text: "󰃭"
            font.family: Theme.font
            font.pixelSize: 22
            color: Theme.mauve
        }

        // Click the title to rename it; Enter or clicking away saves, Esc reverts.
        Rectangle {
            id: titleBox
            readonly property bool editing: titleInput.activeFocus
            anchors.left: icon.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(titleInput.contentWidth + pencil.width + 30, buttons.x - x - 12)
            height: 36
            radius: 10
            color: editing ? Theme.mantle : titleMouse.containsMouse ? Theme.surface0 : "transparent"
            border.width: editing ? 2 : 0
            border.color: Theme.mauve
            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            MouseArea {
                id: titleMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                onClicked: { titleInput.forceActiveFocus(); titleInput.selectAll(); }
            }

            TextInput {
                id: titleInput
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: pencil.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: panel.tt.title
                font.family: Theme.font
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
                selectionColor: Theme.surface2
                selectByMouse: true
                clip: true
                onEditingFinished: {
                    panel.store.setTitle(text.trim() || "Timetable");
                    text = Qt.binding(() => panel.tt.title);
                    if (activeFocus) panel.forceActiveFocus();
                }
                Keys.onEscapePressed: { text = panel.tt.title; panel.forceActiveFocus(); }
            }

            Text {
                id: pencil
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: titleBox.editing ? "󰄬" : "󰏫"
                font.family: Theme.font
                font.pixelSize: 15
                color: titleBox.editing ? Theme.green : titleMouse.containsMouse ? Theme.mauve : Theme.overlay0
            }
        }

        Row {
            id: buttons
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            ActionButton {
                icon: panel.tt.showWeekend ? "󰄲" : "󰄱"
                label: "Weekend"
                accent: panel.tt.showWeekend ? Theme.mauve : Theme.subtext0
                onClicked: panel.store.setShowWeekend(!panel.tt.showWeekend)
            }
            ActionButton {
                icon: "󰍴"
                label: "Slot"
                onClicked: panel.notify(panel.store.removeSlot(panel.slots.length - 1))
            }
            ActionButton {
                icon: "󰐕"
                label: "Slot"
                onClicked: panel.store.addSlot()
            }
            ActionButton {
                icon: "󰅖"
                accent: Theme.red
                onClicked: panel.closeRequested()
            }
        }
    }

    // ---- Grid ----------------------------------------------------------

    Item {
        id: grid
        x: panel.pad
        y: topBar.y + topBar.height + panel.pad
        width: panel.width - 2 * panel.pad
        height: panel.headerHeight + panel.days.length * panel.rowHeight

        // Time header.
        Repeater {
            model: panel.slots
            delegate: Rectangle {
                id: head
                required property var modelData
                required property int index
                x: panel.dayColWidth + index * panel.cellWidth + 2
                width: panel.cellWidth - 4
                height: panel.headerHeight - 6
                radius: 8
                color: headMouse.containsMouse ? Theme.surface0 : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Column {
                    anchors.centerIn: parent
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: head.modelData.start
                        font.family: Theme.font
                        font.pixelSize: Theme.fontNormal
                        font.bold: true
                        color: head.index === panel.nowSlot ? Theme.mauve : Theme.text
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: head.modelData.end
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSmall
                        color: Theme.overlay1
                    }
                }

                MouseArea {
                    id: headMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: slotEditor.open(head.index)
                }
            }
        }

        // Day rows.
        Repeater {
            model: panel.days
            delegate: Item {
                id: dayRow
                required property int modelData
                required property int index
                readonly property int day: modelData
                readonly property bool isToday: day === panel.today

                y: panel.headerHeight + index * panel.rowHeight
                width: grid.width
                height: panel.rowHeight

                Rectangle {
                    width: panel.dayColWidth - 8
                    height: parent.height - 6
                    y: 3
                    radius: 10
                    color: dayRow.isToday ? Theme.tint(Theme.mauve, 0.15) : Theme.mantle
                    border.width: dayRow.isToday ? 1 : 0
                    border.color: Theme.mauve

                    Text {
                        anchors.centerIn: parent
                        text: panel.dayNames[dayRow.day]
                        font.family: Theme.font
                        font.pixelSize: Theme.fontMedium
                        font.bold: true
                        color: dayRow.isToday ? Theme.mauve : Theme.subtext0
                    }
                }

                Item {
                    id: cells
                    x: panel.dayColWidth
                    width: parent.width - panel.dayColWidth
                    height: parent.height

                    // Empty cell backgrounds.
                    Repeater {
                        model: panel.slots.length
                        delegate: Rectangle {
                            id: cell
                            required property int index
                            readonly property bool hovered: cellMouse.containsMouse && cellMouse.hoverSlot === index && !cellMouse.pressed
                            x: index * panel.cellWidth + 2
                            y: 3
                            width: panel.cellWidth - 4
                            height: cells.height - 6
                            radius: 8
                            color: hovered ? Theme.surface0
                                 : dayRow.isToday && index === panel.nowSlot ? Theme.tint(Theme.mauve, 0.10)
                                 : Theme.mantle
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                            Text {
                                anchors.centerIn: parent
                                visible: cell.hovered
                                text: "󰐕"
                                font.family: Theme.font
                                font.pixelSize: 16
                                color: Theme.overlay1
                            }
                        }
                    }

                    // Selection while dragging.
                    Rectangle {
                        visible: panel.selDay === dayRow.day
                        x: Math.min(panel.selA, panel.selB) * panel.cellWidth + 2
                        y: 3
                        width: (Math.abs(panel.selB - panel.selA) + 1) * panel.cellWidth - 4
                        height: cells.height - 6
                        radius: 10
                        color: Theme.tint(Theme.mauve, 0.22)
                        border.width: 2
                        border.color: Theme.mauve
                    }

                    MouseArea {
                        id: cellMouse
                        property int hoverSlot: -1
                        anchors.fill: parent
                        hoverEnabled: true
                        preventStealing: true
                        cursorShape: Qt.CrossCursor

                        onPositionChanged: mouse => {
                            hoverSlot = panel.slotAt(mouse.x);
                            if (pressed && panel.selDay === dayRow.day)
                                panel.selB = panel.clampSel(dayRow.day, panel.selA, hoverSlot);
                        }
                        onExited: hoverSlot = -1
                        onPressed: mouse => {
                            panel.forceActiveFocus();
                            const s = panel.slotAt(mouse.x);
                            if (panel.store.occupant(dayRow.day, s, -1) >= 0) { mouse.accepted = false; return; }
                            panel.selDay = dayRow.day;
                            panel.selA = s;
                            panel.selB = s;
                        }
                        onReleased: {
                            if (panel.selDay !== dayRow.day) return;
                            const a = Math.min(panel.selA, panel.selB);
                            const span = Math.abs(panel.selB - panel.selA) + 1;
                            panel.selDay = -1;
                            panel.openNew(dayRow.day, a, span);
                        }
                        onCanceled: panel.selDay = -1
                    }

                    // Blocks.
                    Repeater {
                        model: panel.store.entriesFor(panel.tt, dayRow.day)
                        delegate: EntryBlock {
                            required property var modelData
                            entry: modelData
                            x: modelData.start * panel.cellWidth + 2
                            y: 3
                            width: modelData.span * panel.cellWidth - 4
                            height: cells.height - 6
                            live: dayRow.isToday && panel.nowSlot >= modelData.start && panel.nowSlot < modelData.start + modelData.span
                            onClicked: panel.openEdit(modelData.index)
                        }
                    }
                }
            }
        }
    }

    Text {
        id: hint
        x: panel.pad
        y: grid.y + grid.height + panel.pad
        width: panel.width - 2 * panel.pad
        text: panel.notice || "Drag across empty cells to add  ·  Click a block to edit  ·  Click a time to edit the slot  ·  Click the title to rename  ·  Esc to close"
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        color: panel.notice ? Theme.red : Theme.overlay0
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    // ---- Dialogs -------------------------------------------------------

    EntryEditor {
        id: editor
        anchors.fill: parent
        store: panel.store
        onClosed: panel.forceActiveFocus()
    }

    SlotEditor {
        id: slotEditor
        anchors.fill: parent
        store: panel.store
        onClosed: panel.forceActiveFocus()
    }
}
