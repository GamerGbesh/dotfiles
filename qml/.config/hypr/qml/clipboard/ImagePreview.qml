import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string thumbSource: ""
    property string format: "PNG"
    property string dimensions: ""
    property string size: ""
    property string metaText: ""
    property bool isSelected: false

    Rectangle {
        id: imageFrame
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: metaBar.top
        anchors.margins: 8
        anchors.bottomMargin: 4
        radius: Theme.cardRadius - 4
        color: Theme.crust
        clip: true

        // Subtle checkerboard pattern for transparency visibility
        Canvas {
            anchors.fill: parent
            opacity: 0.15
            onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = Theme.surface1;
                var size = 16;
                for (var x = 0; x < width; x += size) {
                    for (var y = 0; y < height; y += size) {
                        if ((Math.floor(x / size) + Math.floor(y / size)) % 2 === 0) {
                            ctx.fillRect(x, y, size, size);
                        }
                    }
                }
            }
        }

        // The Actual Image Thumbnail
        Image {
            id: thumbImage
            anchors.fill: parent
            anchors.margins: 4
            source: root.thumbSource ? ("file://" + root.thumbSource) : ""
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: true
            mipmap: true
            smooth: true

            opacity: (status === Image.Ready) ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Theme.animFast }
            }
        }

        // Loading Placeholder
        Item {
            anchors.centerIn: parent
            visible: !root.thumbSource || thumbImage.status === Image.Loading

            Column {
                anchors.centerIn: parent
                spacing: 6

                Rectangle {
                    width: 36
                    height: 36
                    radius: 8
                    color: Theme.surface1
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "🖼"
                        font.pixelSize: 18
                    }
                }

                Text {
                    text: root.thumbSource ? "Loading..." : "Thumbnailing..."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textMuted
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // Error Fallback
        Item {
            anchors.centerIn: parent
            visible: root.thumbSource && thumbImage.status === Image.Error

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "⚠"
                    font.pixelSize: 18
                    color: Theme.peach
                }

                Text {
                    text: "Image unavailable"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textDim
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // Format Badge (Top Left Pill)
        Rectangle {
            z: 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 6
            height: 18
            width: fmtLabel.implicitWidth + 10
            radius: 9
            color: Qt.rgba(0.066, 0.066, 0.105, 0.85) // Dark translucent
            border.width: 1
            border.color: root.isSelected ? Theme.mauve : Theme.surface1

            Text {
                id: fmtLabel
                anchors.centerIn: parent
                text: root.format
                font.family: Theme.fontFamilyMono
                font.pixelSize: 9
                font.weight: Font.DemiBold
                color: root.isSelected ? Theme.mauve : Theme.lavender
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
            text: root.metaText ? root.metaText : (root.format + (root.dimensions ? " · " + root.dimensions : ""))
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.fontSizeSmall
            color: root.isSelected ? Theme.text : Theme.textMuted
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
