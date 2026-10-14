pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "." as QsServices

// Brightness service backed by hyprsunset.
// There is no backlight device on this machine, so perceived
// brightness is adjusted through hyprsunset's gamma ramp
// (Hyprland >= 0.45). The level is persisted in settings.json
// because hyprsunset cannot report its current gamma.
Singleton {
    id: root

    property real brightness: QsServices.Settings.brightnessLevel
    property real maxBrightness: 1.0

    // Alias for easier access
    readonly property real level: brightness
    readonly property int percentage: Math.round(brightness * 100)

    function setBrightness(value) {
        // Clamp between 0 and 1
        const newValue = Math.max(0, Math.min(1, value))

        QsServices.Settings.brightnessLevel = newValue
        applyGamma(newValue)
    }

    function increaseBrightness() {
        setBrightness(brightness + 0.05)
    }

    function decreaseBrightness() {
        setBrightness(brightness - 0.05)
    }

    function applyGamma(value) {
        const gamma = String(Math.round(value * 100))
        // Prefer the running hyprsunset daemon via hyprctl IPC.
        gammaProc.exec(["hyprctl", "hyprsunset", "gamma", gamma])
    }

    // hyprctl IPC fails when the hyprsunset daemon isn't running —
    // in that case start it directly with the gamma override.
    Process {
        id: gammaProc
        onExited: code => {
            if (code !== 0) {
                Quickshell.execDetached([
                    "hyprsunset",
                    "--gamma",
                    String(Math.round(root.brightness * 100))
                ])
            }
        }
    }

    Component.onCompleted: {
        // hyprsunset does not persist gamma across restarts —
        // re-apply a non-default level once the shell starts.
        if (QsServices.Settings.brightnessLevel < 1.0) {
            applyGamma(QsServices.Settings.brightnessLevel)
        }
    }
}
