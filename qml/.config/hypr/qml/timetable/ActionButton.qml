import QtQuick

Rectangle {
    id: button

    property string label: ""
    property string icon: ""
    property color accent: Theme.text

    signal clicked()

    implicitWidth: content.implicitWidth + 24
    height: 36
    radius: 10
    color: mouse.pressed ? Theme.surface2 : mouse.containsMouse ? Theme.surface1 : Theme.surface0
    border.width: 1
    border.color: mouse.containsMouse ? accent : Theme.surface1
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6
        Text {
            visible: button.icon.length > 0
            text: button.icon
            font.family: Theme.font
            font.pixelSize: 15
            color: button.accent
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: button.label
            font.family: Theme.font
            font.pixelSize: Theme.fontNormal
            color: button.accent
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
