import QtQuick
import QtQuick.Controls

Item {
    id: root

    property int itemIndex: 0
    property string itemId: ""
    property string itemType: "text"
    property string format: "TEXT"
    property string dimensions: ""
    property string size: ""
    property string meta: ""
    property string preview: ""
    property string rawLine: ""
    property string thumb: ""
    property bool isSelected: false

    signal activated()
    signal clicked()

    width: Theme.cardWidth
    height: Theme.cardHeight

    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: Theme.cardRadius
        color: root.isSelected ? Theme.surface1 : (mouseArea.containsMouse ? Theme.surface0 : Theme.mantle)
        border.width: root.isSelected ? 2 : 1
        border.color: root.isSelected ? Theme.mauve : (mouseArea.containsMouse ? Theme.surface2 : Theme.surface0)

        scale: mouseArea.pressed ? 0.98 : (root.isSelected ? 1.02 : 1.0)
        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad }
        }

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Behavior on border.color {
            ColorAnimation { duration: Theme.animFast }
        }

        // Selection Accent Glow / Corner Indicator
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 6
            width: 8
            height: 8
            radius: 4
            color: Theme.mauve
            visible: root.isSelected
        }

        // Delegate Content by Type
        Loader {
            id: contentLoader
            anchors.fill: parent
            sourceComponent: (root.itemType === "image") ? imageComponent : textComponent
        }

        Component {
            id: imageComponent
            ImagePreview {
                thumbSource: root.thumb
                format: root.format
                dimensions: root.dimensions
                size: root.size
                metaText: root.meta
                isSelected: root.isSelected
            }
        }

        Component {
            id: textComponent
            TextPreview {
                textContent: root.preview
                metaText: root.meta
                isSelected: root.isSelected
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.clicked();
            }

            onDoubleClicked: {
                root.activated();
            }
        }
    }
}
