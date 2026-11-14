import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string textContent: ""
    property string metaText: ""
    property bool isSelected: false

    Rectangle {
        id: textFrame
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: metaBar.top
        anchors.margins: 8
        anchors.bottomMargin: 4
        radius: Theme.cardRadius - 4
        color: Theme.crust
        clip: true

        // Clean text container
        Item {
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 26 // Avoid overlapping top left badge

            Text {
                id: bodyText
                anchors.fill: parent
                text: root.textContent
                font.family: Theme.fontFamilyMono
                font.pixelSize: Theme.fontSizeNormal
                color: root.isSelected ? Theme.text : Theme.subtext1
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 5
                elide: Text.ElideRight
                lineHeight: 1.2
            }
        }

        // Top Left Badge
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 6
            height: 18
            width: typeLabel.implicitWidth + 10
            radius: 9
            color: Qt.rgba(0.066, 0.066, 0.105, 0.85)
            border.width: 1
            border.color: root.isSelected ? Theme.blue : Theme.surface1

            Text {
                id: typeLabel
                anchors.centerIn: parent
                text: "TXT"
                font.family: Theme.fontFamilyMono
                font.pixelSize: 9
                font.weight: Font.DemiBold
                color: root.isSelected ? Theme.blue : Theme.sapphire
            }
        }
    }

    // Metadata Footer Bar
    Item {
        id: metaBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 26

        Text {
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            text: root.metaText ? root.metaText : "Text"
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.fontSizeSmall
            color: root.isSelected ? Theme.text : Theme.textMuted
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
