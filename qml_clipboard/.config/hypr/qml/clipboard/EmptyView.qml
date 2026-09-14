import QtQuick
import QtQuick.Controls

Item {
    id: root

    property bool isLoading: false
    property string errorMessage: ""
    property bool isSearchEmpty: false
    property string searchQuery: ""

    Column {
        anchors.centerIn: parent
        spacing: 12
        width: Math.min(parent.width - 40, 400)

        // Icon
        Rectangle {
            width: 56
            height: 56
            radius: 28
            color: Theme.surface0
            border.width: 1
            border.color: Theme.surface1
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                anchors.centerIn: parent
                text: root.isLoading ? "⏳" : (root.errorMessage ? "⚠" : (root.isSearchEmpty ? "🔍" : "📋"))
                font.pixelSize: 26
            }
        }

        // Main Message
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.isLoading ? "Loading clipboard history..." :
                  (root.errorMessage ? "Failed to load clipboard" :
                  (root.isSearchEmpty ? "No matching entries" : "Clipboard is empty"))
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.DemiBold
            color: Theme.text
            horizontalAlignment: Text.AlignHCenter
        }

        // Subtitle / Description
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.isLoading ? "Fetching entries from cliphist" :
                  (root.errorMessage ? root.errorMessage :
                  (root.isSearchEmpty ? "No items match \"" + root.searchQuery + "\"" : "Copy text or images to see them appear here"))
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            color: root.errorMessage ? Theme.red : Theme.subtext0
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            width: parent.width
        }
    }
}
