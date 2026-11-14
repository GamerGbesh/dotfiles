import QtQuick
import Quickshell

pragma Singleton

// Catppuccin Mocha, matching the clipboard picker.
Singleton {
    readonly property color mauve:    "#cba6f7"
    readonly property color red:      "#f38ba8"
    readonly property color peach:    "#fab387"
    readonly property color yellow:   "#f9e2af"
    readonly property color green:    "#a6e3a1"
    readonly property color blue:     "#89b4fa"
    readonly property color lavender: "#b4befe"

    readonly property color text:     "#cdd6f4"
    readonly property color subtext0: "#a6adc8"
    readonly property color overlay1: "#7f849c"
    readonly property color overlay0: "#6c7086"
    readonly property color surface2: "#585b70"
    readonly property color surface1: "#45475a"
    readonly property color surface0: "#313244"
    readonly property color base:     "#1e1e2e"
    readonly property color mantle:   "#181825"
    readonly property color crust:    "#11111b"

    readonly property color backdrop: Qt.rgba(0.066, 0.066, 0.105, 0.65)

    readonly property int windowWidth:  560
    readonly property int windowHeight: 600
    readonly property int windowRadius: 16
    readonly property int radius:       12

    readonly property string font: "CaskaydiaCove Nerd Font"
    readonly property int fontSmall:  11
    readonly property int fontNormal: 13
    readonly property int fontMedium: 14
    readonly property int fontLarge:  18

    readonly property int animFast: 120
}
