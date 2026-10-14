import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Wayland
import "../../config" as QsConfig
import "../../services" as QsServices
import "../../components"

PanelWindow {
    id: root

    property bool shouldShow: false

    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    readonly property var time: QsServices.Time

    readonly property color cSurface: pywal.surfaceContainerHighest
    readonly property color cSurfaceContainer: pywal.surfaceContainerHigh
    readonly property color cPrimary: pywal.primary
    readonly property color cText: pywal.foreground
    readonly property color cSubText: pywal.onSurfaceMuted
    readonly property color cBorder: pywal.outlineVariant

    // Visible month — starts at the current month, navigable with the arrows
    property date viewDate
    readonly property int viewYear: viewDate.getFullYear()
    readonly property int viewMonth: viewDate.getMonth()

    readonly property int todayDay: time.date.getDate()
    readonly property int todayMonth: time.date.getMonth()
    readonly property int todayYear: time.date.getFullYear()

    readonly property int firstWeekday: (new Date(viewYear, viewMonth, 1).getDay() + 6) % 7
    readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()
    readonly property int daysInPrevMonth: new Date(viewYear, viewMonth, 0).getDate()

    readonly property var cells: {
        const list = []
        for (let i = 0; i < 42; i++) {
            const dayNumber = i - root.firstWeekday + 1
            if (dayNumber < 1) {
                list.push({ day: root.daysInPrevMonth + dayNumber, current: false, today: false })
            } else if (dayNumber > root.daysInMonth) {
                list.push({ day: dayNumber - root.daysInMonth, current: false, today: false })
            } else {
                list.push({
                    day: dayNumber,
                    current: true,
                    today: dayNumber === root.todayDay
                        && viewMonth === root.todayMonth
                        && viewYear === root.todayYear
                })
            }
        }
        return list
    }

    function closeCalendar() {
        shouldShow = false
    }

    function showCalendar() {
        shouldShow = true
    }

    function prevMonth() {
        viewDate = new Date(viewYear, viewMonth - 1, 1)
    }

    function nextMonth() {
        viewDate = new Date(viewYear, viewMonth + 1, 1)
    }

    function jumpToToday() {
        viewDate = new Date(todayYear, todayMonth, 1)
    }

    onShouldShowChanged: {
        if (shouldShow) {
            // Snap back to the current month whenever it is opened
            viewDate = new Date(todayYear, todayMonth, 1)
        }
    }

    Component.onCompleted: {
        viewDate = new Date(todayYear, todayMonth, 1)
    }

    screen: Quickshell.screens[0]
    anchors {
        top: true
        left: true
    }
    margins {
        top: (config.bar.height ?? 34) + 22
        left: Math.max(0, Math.round((screen.width - root.implicitWidth) / 2))
    }
    implicitWidth: config.calendar.width
    implicitHeight: shouldShow || panel.opacity > 0 ? calendarColumn.implicitHeight + 40 : 0
    color: "transparent"
    visible: config.calendar.enabled && (shouldShow || panel.opacity > 0)

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    FocusScope {
        id: panel
        anchors.fill: parent
        property real revealOffset: shouldShow ? 0 : -20
        scale: shouldShow ? 1.0 : 0.97
        opacity: shouldShow ? 1.0 : 0.0
        focus: root.shouldShow
        transform: Translate { y: panel.revealOffset }

        Keys.onEscapePressed: root.closeCalendar()

        Behavior on scale {
            NumberAnimation { duration: 240; easing.bezierCurve: [0.22, 1.0, 0.36, 1.0] }
        }

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Behavior on revealOffset {
            NumberAnimation { duration: 260; easing.bezierCurve: [0.05, 0.7, 0.1, 1.0] }
        }

        AuroraSurface {
            anchors.fill: parent
            radius: 28
            color: root.cSurface
            strokeColor: root.cBorder
            accentColor: root.cPrimary
            elevation: 4
            highlighted: root.shouldShow

            ColumnLayout {
                id: calendarColumn
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Header: month navigation
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 18
                        color: prevMonthArea.containsMouse
                            ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.14)
                            : Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.05)

                        Text {
                            anchors.centerIn: parent
                            text: "󰄷"
                            font.family: "Material Design Icons"
                            font.pixelSize: 18
                            color: root.cText
                        }

                        MouseArea {
                            id: prevMonthArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.prevMonth()
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: `${["January", "February", "March", "April", "May", "June",
                                      "July", "August", "September", "October", "November",
                                      "December"][root.viewMonth]} ${root.viewYear}`
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: root.cText
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: time.format("dddd, d. MMMM")
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 11
                            color: root.cSubText
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 18
                        color: nextMonthArea.containsMouse
                            ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.14)
                            : Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.05)

                        Text {
                            anchors.centerIn: parent
                            text: "󰄸"
                            font.family: "Material Design Icons"
                            font.pixelSize: 18
                            color: root.cText
                        }

                        MouseArea {
                            id: nextMonthArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.nextMonth()
                        }
                    }
                }

                // Weekday labels
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    spacing: 4

                    Repeater {
                        model: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

                        Text {
                            required property var modelData
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: root.cSubText
                        }
                    }
                }

                // Day grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 4
                    columnSpacing: 4

                    Repeater {
                        model: root.cells

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 12
                            color: modelData.today
                                ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.20)
                                : modelData.current
                                    ? Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.04)
                                    : "transparent"
                            border.width: modelData.today ? 1 : 0
                            border.color: Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.45)

                            Text {
                                anchors.centerIn: parent
                                text: `${modelData.day}`
                                font.family: QsConfig.Config.appearance.fontFamily
                                font.pixelSize: 12
                                font.weight: modelData.today ? Font.Bold : Font.Medium
                                color: modelData.current ? root.cText : root.cSubText
                                opacity: modelData.current ? 1.0 : 0.45
                            }
                        }
                    }
                }

                // Footer: jump to today
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: todayBtnText.implicitWidth + 24
                        Layout.preferredHeight: 28
                        radius: 14
                        color: todayArea.containsMouse
                            ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.16)
                            : Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.08)

                        Text {
                            id: todayBtnText
                            anchors.centerIn: parent
                            text: "󰃞 Today"
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: root.cPrimary
                        }

                        MouseArea {
                            id: todayArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.jumpToToday()
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton)
                    root.closeCalendar()
            }
        }
    }
}
