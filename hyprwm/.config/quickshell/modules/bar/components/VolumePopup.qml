import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell.Io
import "../../../components/effects"
import "../../../services" as QsServices

FocusScope {
    id: popupPanel

    property bool shouldShow: false
    signal closeRequested()

    readonly property var audio: QsServices.Audio
    readonly property var pywal: QsServices.Pywal

    readonly property color cSurface: pywal.surface
    readonly property color cSurfaceContainer: pywal.surfaceContainer
    readonly property color cSurfaceContainerHigh: pywal.surfaceContainerHigh
    readonly property color cPrimary: pywal.primary
    readonly property color cOnSurface: pywal.foreground
    readonly property color cOnSurfaceVariant: pywal.onSurfaceMuted

    Process {
        id: settingsProcess
        command: ["pavucontrol"]
        onStarted: popupPanel.closeRequested()
    }

    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    focus: true

    Keys.onEscapePressed: closeRequested()

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: cSurface

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header with mute toggle
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 12
                    color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: audio.muted ? "󰝟" : (audio.percentage > 66 ? "󰕾" : (audio.percentage > 33 ? "󰖀" : "󰕿"))
                        font.family: "Material Design Icons"
                        font.pixelSize: 18
                        color: cPrimary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Volume"
                        font.family: "Inter"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: cOnSurface
                    }

                    Text {
                        text: audio.muted ? "Muted" : audio.percentage + "%"
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: cOnSurfaceVariant
                    }
                }

                // Mute toggle button
                Rectangle {
                    width: 44; height: 24; radius: 12
                    color: audio.muted ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.15) : cPrimary
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: 18; height: 18; radius: 9
                        anchors.verticalCenter: parent.verticalCenter
                        x: audio.muted ? 3 : parent.width - width - 3
                        color: "#ffffff"
                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audio.toggleMute()
                    }
                }
            }

            // Volume Slider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 16
                color: cSurfaceContainerHigh
                clip: true

                Slider {
                    id: slider
                    anchors.fill: parent
                    anchors.margins: 16
                    from: 0; to: 100; value: audio.percentage; live: true
                    enabled: !audio.muted
                    onMoved: audio.setVolume(value / 100)

                    background: Rectangle {
                        x: slider.leftPadding; y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        implicitWidth: 200; implicitHeight: 8
                        width: slider.availableWidth; height: implicitHeight
                        radius: 4
                        color: Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.1)

                        Rectangle {
                            width: slider.visualPosition * parent.width; height: parent.height; radius: 4
                            color: audio.muted ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.3) : cPrimary
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    // M3 Expressive Morphing Handle
                    handle: Rectangle {
                        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        property real targetHeight: slider.pressed ? 32 : 20
                        width: 20
                        height: targetHeight
                        radius: width / 2
                        color: cPrimary

                        Behavior on height { NumberAnimation { duration: 200; easing.bezierCurve: Material3Anim.emphasized } }
                    }
                }
            }

            // Quick volume buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [0, 25, 50, 75, 100]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 12
                        color: quickBtn.pressed ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.12) : quickBtn.containsMouse ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.08) : cSurfaceContainer
                        Behavior on color { ColorAnimation { duration: 150 } }
                        scale: quickBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.bezierCurve: Material3Anim.springGentle } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData === 0 ? "󰝟" : (modelData > 66 ? "󰕾" : (modelData > 33 ? "󰖀" : "󰕿"))
                            font.family: "Material Design Icons"
                            font.pixelSize: 16
                            color: modelData === audio.percentage ? cPrimary : cOnSurface
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        MouseArea {
                            id: quickBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !audio.muted || modelData === 0
                            onClicked: audio.setVolume(modelData / 100)
                        }
                    }
                }
            }

            // Audio settings button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 12
                color: settingsArea.pressed ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.12) : settingsArea.containsMouse ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.08) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                scale: settingsArea.pressed ? 0.97 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.bezierCurve: Material3Anim.springGentle } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰒓"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: cOnSurfaceVariant
                    }

                    Text {
                        text: "Audio Settings"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: cOnSurfaceVariant
                    }
                }

                MouseArea {
                    id: settingsArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        settingsProcess.running = true
                    }
                }
            }
        }
    }
}