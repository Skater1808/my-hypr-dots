import Quickshell
import QtQuick

Scope {
    id: root
    
    required property var pywal
    property var bar
    
    VolumeOSD {
        pywal: root.pywal
        bar: root.bar
    }
    
    BrightnessOSD {
        pywal: root.pywal
    }
}
