import QtQuick

// One occupied range in a day row.
Rectangle {
    id: block

    property var entry: ({})
    property bool live: false
    signal clicked()

    readonly property color accent: Theme.accent(entry.color)

    radius: 10
    color: Qt.tint(Theme.mantle, Theme.tint(accent, mouse.containsMouse ? 0.28 : 0.18))
    border.width: live ? 2 : 1
    border.color: live ? accent : Theme.tint(accent, 0.45)
    clip: true
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Rectangle {
        width: 4
        height: parent.height - 16
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        radius: 2
        color: block.accent
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 28
        spacing: 2

        Text {
            width: parent.width
            text: block.entry.title || ""
            font.family: Theme.font
            font.pixelSize: Theme.fontMedium
            font.bold: true
            color: block.accent
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            visible: text.length > 0
            text: block.entry.location || ""
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            color: Theme.text
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            visible: text.length > 0
            text: block.entry.note || ""
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            color: Theme.subtext0
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: block.clicked()
    }
}
