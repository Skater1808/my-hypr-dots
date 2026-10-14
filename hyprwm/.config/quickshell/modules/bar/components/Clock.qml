import QtQuick 6.10
import QtQuick.Layouts 6.10
import qs.services
import "../../../components/effects"

Item {
    id: root

    property var calendar
    property var controlCenter
    property var sidebar
    property var dashboard
    
    implicitWidth: clockRow.implicitWidth
    implicitHeight: clockRow.implicitHeight
    
    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8
        
        // Compact time display
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            
            // Hours
            Text {
                id: hoursText
                text: Time.format("hh")
                color: Pywal.foreground
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "Inter"
                font.letterSpacing: 0.3
            }
            
            // Animated colon separator
            Text {
                id: colonSeparator
                text: ":"
                color: Pywal.primary
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "Inter"
                opacity: 0.4
                
                // Blinks once per second via timer instead of continuous animation
                // to avoid constant GPU repaints
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: colonSeparator.opacity = colonSeparator.opacity === 1.0 ? 0.4 : 1.0
                }
            }
            
            // Minutes
            Text {
                id: minutesText
                text: Time.format("mm")
                color: Pywal.foreground
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "Inter"
                font.letterSpacing: 0.3
            }
        }
        
        }
}
