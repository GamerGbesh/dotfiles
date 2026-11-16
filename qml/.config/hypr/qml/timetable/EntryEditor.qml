import QtQuick

// Modal card for creating or editing a block.
Rectangle {
    id: editor

    required property var store
    signal closed()

    property int index: -1
    property int day: 0
    property int start: 0
    property int span: 1
    property string colorName: "mauve"
    property string error: ""

    readonly property var slots: store.tt.slots
    readonly property var dayNames: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    readonly property int endSlot: start + span - 1

    visible: false
    color: Theme.backdrop
    radius: Theme.windowRadius

    function open(idx, e) {
        index = idx;
        day = e.day;
        start = e.start;
        span = e.span;
        colorName = e.color || "mauve";
        titleField.text = e.title || "";
        locationField.text = e.location || "";
        noteField.text = e.note || "";
        error = "";
        visible = true;
        titleField.focusInput();
    }

    function close() {
        visible = false;
        closed();
    }

    function save() {
        const err = store.saveEntry(index, {
            day: day, start: start, span: span,
            title: titleField.text.trim(),
            location: locationField.text.trim(),
            note: noteField.text.trim(),
            color: colorName
        });
        if (err) error = err; else close();
    }

    function remove() {
        if (index >= 0) store.deleteEntry(index);
        close();
    }

    // Moving the start keeps the end where it is (unless start passes it).
    function setStart(s) {
        s = Math.max(0, Math.min(slots.length - 1, s));
        const end = Math.max(endSlot, s);
        start = s;
        span = end - s + 1;
        error = "";
    }

    function setEnd(e) {
        e = Math.max(start, Math.min(slots.length - 1, e));
        span = e - start + 1;
        error = "";
    }

    // Click outside the card to cancel; swallow everything else.
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: editor.close()
        onWheel: wheel => wheel.accepted = true
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 460
        height: body.implicitHeight + 40
        radius: Theme.windowRadius
        color: Theme.base
        border.width: 1
        border.color: Theme.surface1

        MouseArea { anchors.fill: parent }

        Column {
            id: body
            x: 20
            y: 20
            width: parent.width - 40
            spacing: 12

            Text {
                text: editor.index < 0 ? "New block" : "Edit block"
                font.family: Theme.font
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
            }

            Field {
                id: titleField
                width: parent.width
                placeholder: "Title (e.g. CPEN 429)"
                onAccepted: editor.save()
                onEscapePressed: editor.close()
                // Reuse the colour of an existing block with the same title.
                onTextChanged: {
                    if (editor.index >= 0) return;
                    const c = editor.store.colorForTitle(text);
                    if (c) editor.colorName = c;
                }
            }
            Field {
                id: locationField
                width: parent.width
                placeholder: "Location"
                onAccepted: editor.save()
                onEscapePressed: editor.close()
            }
            Field {
                id: noteField
                width: parent.width
                placeholder: "Note (lecturer, etc.)"
                onAccepted: editor.save()
                onEscapePressed: editor.close()
            }

            Label { text: "Day" }
            Row {
                spacing: 6
                Repeater {
                    model: 7
                    delegate: Chip {
                        required property int index
                        text: editor.dayNames[index]
                        selected: editor.day === index
                        onClicked: { editor.day = index; editor.error = ""; }
                    }
                }
            }

            Row {
                spacing: 16
                Column {
                    spacing: 6
                    Label { text: "Start" }
                    Stepper {
                        value: editor.slots[editor.start] ? editor.slots[editor.start].start : ""
                        onDecrement: editor.setStart(editor.start - 1)
                        onIncrement: editor.setStart(editor.start + 1)
                    }
                }
                Column {
                    spacing: 6
                    Label { text: "End" }
                    Stepper {
                        value: editor.slots[editor.endSlot] ? editor.slots[editor.endSlot].end : ""
                        onDecrement: editor.setEnd(editor.endSlot - 1)
                        onIncrement: editor.setEnd(editor.endSlot + 1)
                    }
                }
            }

            Label { text: "Colour" }
            Row {
                spacing: 8
                Repeater {
                    model: Theme.palette
                    delegate: Rectangle {
                        id: swatch
                        required property string modelData
                        width: 26
                        height: 26
                        radius: 13
                        color: Theme.accent(modelData)
                        border.width: editor.colorName === modelData ? 3 : 0
                        border.color: Theme.text
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: editor.colorName = swatch.modelData
                        }
                    }
                }
            }

            Text {
                width: parent.width
                visible: editor.error.length > 0
                text: editor.error
                font.family: Theme.font
                font.pixelSize: Theme.fontNormal
                color: Theme.red
                wrapMode: Text.WordWrap
            }

            Item {
                width: parent.width
                height: 36

                ActionButton {
                    visible: editor.index >= 0
                    icon: "󰆴"
                    label: "Delete"
                    accent: Theme.red
                    onClicked: editor.remove()
                }
                Row {
                    anchors.right: parent.right
                    spacing: 8
                    ActionButton {
                        label: "Cancel"
                        accent: Theme.subtext0
                        onClicked: editor.close()
                    }
                    ActionButton {
                        icon: "󰄬"
                        label: "Save"
                        accent: Theme.green
                        onClicked: editor.save()
                    }
                }
            }
        }
    }

    component Label: Text {
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        color: Theme.overlay1
    }

    component Chip: Rectangle {
        id: chip
        property string text
        property bool selected
        signal clicked()
        width: 52
        height: 30
        radius: 8
        color: selected ? Theme.tint(Theme.mauve, 0.2) : chipMouse.containsMouse ? Theme.surface1 : Theme.surface0
        border.width: selected ? 1 : 0
        border.color: Theme.mauve
        Text {
            anchors.centerIn: parent
            text: chip.text
            font.family: Theme.font
            font.pixelSize: Theme.fontNormal
            color: chip.selected ? Theme.mauve : Theme.text
        }
        MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    component Stepper: Rectangle {
        id: stepper
        property string value
        signal decrement()
        signal increment()
        width: 150
        height: 36
        radius: 10
        color: Theme.surface0
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅁"
            font.family: Theme.font
            font.pixelSize: 16
            color: decMouse.containsMouse ? Theme.mauve : Theme.subtext0
            MouseArea {
                id: decMouse
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: stepper.decrement()
            }
        }
        Text {
            anchors.centerIn: parent
            text: stepper.value
            font.family: Theme.font
            font.pixelSize: Theme.fontMedium
            font.bold: true
            color: Theme.text
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅂"
            font.family: Theme.font
            font.pixelSize: 16
            color: incMouse.containsMouse ? Theme.mauve : Theme.subtext0
            MouseArea {
                id: incMouse
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: stepper.increment()
            }
        }
        // Scroll to step too.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel => wheel.angleDelta.y > 0 ? stepper.decrement() : stepper.increment()
        }
    }
}
