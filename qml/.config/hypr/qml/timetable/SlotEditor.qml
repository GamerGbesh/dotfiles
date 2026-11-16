import QtQuick

// Modal card for changing a time slot's start/end, or removing it.
Rectangle {
    id: editor

    required property var store
    signal closed()

    property int index: -1
    property string error: ""

    visible: false
    color: Theme.backdrop
    radius: Theme.windowRadius

    function open(i) {
        index = i;
        startField.text = store.tt.slots[i].start;
        endField.text = store.tt.slots[i].end;
        error = "";
        visible = true;
        startField.focusInput();
    }

    function close() {
        visible = false;
        closed();
    }

    function save() {
        const err = store.setSlot(index, startField.text.trim(), endField.text.trim());
        if (err) error = err; else close();
    }

    function remove() {
        const err = store.removeSlot(index);
        if (err) error = err; else close();
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: editor.close()
        onWheel: wheel => wheel.accepted = true
    }

    Rectangle {
        anchors.centerIn: parent
        width: 360
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
                text: "Slot " + (editor.index + 1)
                font.family: Theme.font
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
            }

            Row {
                width: parent.width
                spacing: 12
                Field {
                    id: startField
                    width: (parent.width - 12) / 2
                    placeholder: "Start HH:MM"
                    onAccepted: editor.save()
                    onEscapePressed: editor.close()
                }
                Field {
                    id: endField
                    width: (parent.width - 12) / 2
                    placeholder: "End HH:MM"
                    onAccepted: editor.save()
                    onEscapePressed: editor.close()
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
                    icon: "󰆴"
                    label: "Remove"
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
}
