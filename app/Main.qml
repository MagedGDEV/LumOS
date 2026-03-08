import QtQuick
import QtQuick.Window

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    title: "LumOS"
    color: "#0a0e1a"

    Text {
        anchors.centerIn: parent
        text: "Hello World"
        font.pixelSize: 48
        font.letterSpacing: 6
        font.weight: Font.Bold
        color: "#ffffff"
    }
}