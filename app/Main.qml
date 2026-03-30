import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import lumOS

Window {
    visible: true
    visibility: Window.FullScreen
    color: "#070b14"

    // ── Deep space background ────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#070b14"
    }

    // Primary glow — warm gold, top-left
    Rectangle {
        id: goldGlow
        width: 700; height: 700
        x: -200; y: -250
        radius: 350
        color: "#ffd700"
        opacity: 0.06
        layer.enabled: true
    }

    Rectangle {
        width: 500; height: 500
        x: -100; y: -150
        radius: 250
        color: "#ffd700"
        opacity: 0.05
    }

    Rectangle {
        width: 300; height: 300
        x: 0; y: -50
        radius: 150
        color: "#ffd700"
        opacity: 0.04
    }

    // Secondary glow — cool blue, bottom-right
    Rectangle {
        width: 600; height: 600
        x: parent.width - 300
        y: parent.height - 280
        radius: 300
        color: "#3060ff"
        opacity: 0.07
    }

    Rectangle {
        width: 400; height: 400
        x: parent.width - 200
        y: parent.height - 180
        radius: 200
        color: "#3060ff"
        opacity: 0.05
    }

    // Tertiary glow — teal, center-left
    Rectangle {
        width: 400; height: 400
        x: parent.width * 0.2
        y: parent.height * 0.4
        radius: 200
        color: "#00c8c8"
        opacity: 0.04
    }

    Rectangle {
        width: 250; height: 250
        x: parent.width * 0.2 + 75
        y: parent.height * 0.4 + 75
        radius: 125
        color: "#00c8c8"
        opacity: 0.03
    }

    // Animation on gold glow
    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        NumberAnimation {
            target: goldGlow
            property: "opacity"
            to: 0.03
            duration: 3000
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: goldGlow
            property: "opacity"
            to: 0.08
            duration: 3000
            easing.type: Easing.InOutSine
        }
    }

    // ── Content ──────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 28

        // ── Header ──────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            Column {
                spacing: 4
                Text {
                    text: "LUMINARY"
                    font.pixelSize: 11
                    font.letterSpacing: 6
                    font.weight: Font.Medium
                    color: "#ffd700"
                    opacity: 0.7
                }
                Text {
                    text: "Light Control"
                    font.pixelSize: 30
                    font.weight: Font.Bold
                    color: "#f0f4ff"
                    font.letterSpacing: -0.5
                }
            }

            Item { Layout.fillWidth: true }

            // All On button
            Rectangle {
                width: 130; height: 48
                radius: 8
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#ffd700" }
                    GradientStop { position: 1.0; color: "#ffb300" }
                }
                Text {
                    anchors.centerIn: parent
                    text: "ALL ON"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                    color: "#0a0800"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: parent.opacity = 0.75
                    onReleased: parent.opacity = 1.0
                    onClicked: RoomManager.turnAllOn()
                }
            }

            Item { width: 10 }

            // All Off button
            Rectangle {
                width: 130; height: 48
                radius: 8
                color: "transparent"
                border.color: "#2a3550"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "ALL OFF"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                    color: "#3d5070"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: parent.opacity = 0.75
                    onReleased: parent.opacity = 1.0
                    onClicked: RoomManager.turnAllOff()
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#ffffff0a"
        }

        // ── Room Cards ───────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            Repeater {
                model: RoomManager.rooms

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 20
                    clip: true
                    color: modelData.isOn ? "#110e00" : "#0b1120"
                    Behavior on color { ColorAnimation { duration: 500 } }

                    // Inner glow when ON
                    Rectangle {
                        visible: modelData.isOn
                        width: 220; height: 220
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: -80
                        radius: 110
                        opacity: 0.12
                        color: "#ffd700"
                    }

                    // Card border
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: modelData.isOn ? "#ffd70040" : "#1e293b"
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 400 } }
                    }

                    // Card content
                    Column {
                        anchors.fill: parent
                        anchors.margins: 28
                        spacing: 8

                        // Status indicator
                        Row {
                            spacing: 8
                            anchors.right: parent.right

                            Rectangle {
                                width: 8; height: 8
                                radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: modelData.isOn ? "#ffd700" : "#1e293b"
                                Behavior on color { ColorAnimation { duration: 300 } }

                                SequentialAnimation on opacity {
                                    running: modelData.isOn
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 900 }
                                    NumberAnimation { to: 1.0; duration: 900 }
                                }
                                opacity: modelData.isOn ? 1.0 : 0.3
                            }

                            Text {
                                text: modelData.isOn ? "ACTIVE" : "STANDBY"
                                font.pixelSize: 11
                                font.letterSpacing: 2
                                font.weight: Font.Medium
                                color: modelData.isOn ? "#ffd700" : "#2a3a55"
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }

                        Item { height: 28 }

                        // Light icon
                        Item {
                            width: 64; height: 64
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: 32
                                color: "transparent"
                                border.color: modelData.isOn ? "#ffd70060" : "#1e293b"
                                border.width: 2
                                Behavior on border.color { ColorAnimation { duration: 400 } }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 44; height: 44
                                radius: 22
                                color: modelData.isOn ? "#ffd700" : "#1a2540"
                                Behavior on color { ColorAnimation { duration: 400 } }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 16; height: 16
                                radius: 8
                                color: modelData.isOn ? "#fff8dc" : "#0f172a"
                                Behavior on color { ColorAnimation { duration: 400 } }
                            }
                        }

                        Item { height: 24 }

                        // Room name
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.name.toUpperCase()
                            font.pixelSize: 17
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            color: modelData.isOn ? "#f0e070" : "#3d5070"
                            Behavior on color { ColorAnimation { duration: 400 } }
                        }

                        Item { height: 6 }

                        // GPIO label
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "GPIO " + modelData.pin
                            font.pixelSize: 13
                            font.letterSpacing: 1
                            color: modelData.isOn ? "#ffd70050" : "#1e293b"
                            Behavior on color { ColorAnimation { duration: 400 } }
                        }

                        Item { height: 28 }

                        // Toggle button
                        Rectangle {
                            width: parent.width
                            height: 50
                            radius: 10
                            color: modelData.isOn ? "#ffd700" : "transparent"
                            border.color: modelData.isOn ? "#ffd700" : "#2a3a55"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 300 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.isOn ? "TURN OFF" : "TURN ON"
                                font.pixelSize: 15
                                font.letterSpacing: 3
                                font.weight: Font.Bold
                                color: modelData.isOn ? "#0a0800" : "#3d5070"
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPressed: parent.opacity = 0.75
                                onReleased: parent.opacity = 1.0
                                onClicked: RoomManager.toggle(modelData.index)
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Voice Overlay ────────────────────────────────────
    Rectangle {
        id: voiceOverlay
        anchors.fill: parent
        color: "#070b14"
        opacity: RoomManager.voiceActive ? 0.85 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutCubic } }

        // Intercept all touch/mouse when active
        MouseArea { anchors.fill: parent; enabled: RoomManager.voiceActive }
    }

    // ── Orb + label (sit above the dim layer) ────────────
    Item {
        anchors.centerIn: parent
        width: 320; height: 320
        opacity: RoomManager.voiceActive ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutCubic } }

        // Outermost ripple
        Rectangle {
            id: ripple1
            anchors.centerIn: parent
            width: 280; height: 280
            radius: 140
            color: "transparent"
            border.color: "#ffd700"
            border.width: 1
            opacity: 0

            SequentialAnimation on opacity {
                running: RoomManager.voiceActive
                loops: Animation.Infinite
                NumberAnimation { to: 0.18; duration: 900; easing.type: Easing.OutCubic }
                NumberAnimation { to: 0.0;  duration: 900; easing.type: Easing.InCubic }
            }
            SequentialAnimation on scale {
                running: RoomManager.voiceActive
                loops: Animation.Infinite
                NumberAnimation { to: 1.15; duration: 1800; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0;  duration: 0 }
            }
        }

        // Middle ripple — offset phase
        Rectangle {
            id: ripple2
            anchors.centerIn: parent
            width: 220; height: 220
            radius: 110
            color: "transparent"
            border.color: "#ffd700"
            border.width: 1.5
            opacity: 0

            SequentialAnimation on opacity {
                running: RoomManager.voiceActive
                loops: Animation.Infinite
                PauseAnimation   { duration: 300 }
                NumberAnimation { to: 0.30; duration: 800; easing.type: Easing.OutCubic }
                NumberAnimation { to: 0.0;  duration: 800; easing.type: Easing.InCubic }
            }
            SequentialAnimation on scale {
                running: RoomManager.voiceActive
                loops: Animation.Infinite
                PauseAnimation   { duration: 300 }
                NumberAnimation { to: 1.12; duration: 1600; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0;  duration: 0 }
            }
        }

        // Core orb
        Rectangle {
            id: coreOrb
            anchors.centerIn: parent
            width: 140; height: 140
            radius: 70
            color: "#1a1200"
            border.color: "#ffd700"
            border.width: 2

            // Inner warm fill that breathes
            Rectangle {
                anchors.centerIn: parent
                width: 100; height: 100
                radius: 50
                color: "#ffd700"
                opacity: 0.0

                SequentialAnimation on opacity {
                    running: RoomManager.voiceActive
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.10; duration: 900; easing.type: Easing.InOutSine }
                }
            }

            // Bright centre dot
            Rectangle {
                anchors.centerIn: parent
                width: 36; height: 36
                radius: 18
                color: "#ffd700"

                SequentialAnimation on opacity {
                    running: RoomManager.voiceActive
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.6; duration: 700; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                }
            }

            // Subtle scale breath on the whole orb
            SequentialAnimation on scale {
                running: RoomManager.voiceActive
                loops: Animation.Infinite
                NumberAnimation { to: 1.06; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.InOutSine }
            }
        }

        // Label below orb
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: coreOrb.bottom
            anchors.topMargin: 28
            spacing: 6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "LUMINA"
                font.pixelSize: 13
                font.letterSpacing: 8
                font.weight: Font.Bold
                color: "#ffd700"
                opacity: 0.9
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Listening..."
                font.pixelSize: 15
                font.letterSpacing: 1
                color: "#a0aec0"
            }
        }
    }
}