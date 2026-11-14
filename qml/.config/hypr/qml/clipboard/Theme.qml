import QtQuick
import Quickshell

pragma Singleton

Singleton {
    // Catppuccin Mocha Color Palette
    readonly property color rosewater: "#f5e0dc"
    readonly property color flamingo:  "#f2cdcd"
    readonly property color pink:      "#f5c2e7"
    readonly property color mauve:     "#cba6f7"
    readonly property color red:       "#f38ba8"
    readonly property color maroon:    "#eba0ac"
    readonly property color peach:     "#fab387"
    readonly property color yellow:    "#f9e2af"
    readonly property color green:     "#a6e3a1"
    readonly property color teal:      "#94e2d5"
    readonly property color sky:       "#89dceb"
    readonly property color sapphire:  "#74c7ec"
    readonly property color blue:      "#89b4fa"
    readonly property color lavender:  "#b4befe"

    readonly property color text:      "#cdd6f4"
    readonly property color subtext1:  "#bac2de"
    readonly property color subtext0:  "#a6adc8"
    readonly property color overlay2:  "#9399b2"
    readonly property color overlay1:  "#7f849c"
    readonly property color overlay0:  "#6c7086"
    readonly property color surface2:  "#585b70"
    readonly property color surface1:  "#45475a"
    readonly property color surface0:  "#313244"
    readonly property color base:      "#1e1e2e"
    readonly property color mantle:    "#181825"
    readonly property color crust:     "#11111b"

    // Semantic Colors
    readonly property color bgApp:        base
    readonly property color bgHeader:     mantle
    readonly property color bgCard:       surface0
    readonly property color bgCardHover:  surface1
    readonly property color bgCardActive: surface2
    readonly property color bgInput:      mantle
    readonly property color bgBadge:      mantle
    readonly property color bgBackdrop:   Qt.rgba(0.066, 0.066, 0.105, 0.65) // crust transparent

    readonly property color borderDim:    surface1
    readonly property color borderNormal: surface2
    readonly property color borderFocus:  mauve
    readonly property color borderActive: blue
    readonly property color textPrimary:  text
    readonly property color textMuted:    subtext0
    readonly property color textDim:      overlay1

    // Metrics
    readonly property int windowWidth:   920
    readonly property int windowHeight:  640
    readonly property int windowRadius:  16
    readonly property int borderWidth:   1

    readonly property int cardWidth:     204
    readonly property int cardHeight:    172
    readonly property int cardRadius:    12
    readonly property int cardSpacing:   12
    readonly property int gridColumns:   4

    // Typography
    readonly property string fontFamily:     "Inter, sans-serif"
    readonly property string fontFamilyMono: "JetBrains Mono, monospace"
    readonly property int fontSizeSmall:     11
    readonly property int fontSizeNormal:    13
    readonly property int fontSizeMedium:    14
    readonly property int fontSizeLarge:     16
    readonly property int fontSizeHeading:   18

    // Animation
    readonly property int animFast: 120
    readonly property int animNormal: 200
}
