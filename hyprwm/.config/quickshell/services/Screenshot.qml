pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "../config" as QsConfig
import "." as QsServices

// Screenshot/Screen Recording Service
// Screenshots are handled by omasnap, which presents
// its capture overlay (region/window/fullscreen),
// copies the result and shows a preview on its own.
Singleton {
    id: root

    property bool isRecording: false
    property string lastRecordingPath: ""
    property string screenshotsDir: QsConfig.Config.paths.screenshotsDir

    Component.onCompleted: {
        // Create screenshots directory if it doesn't exist
        mkdirProc.running = true
    }

    Process {
        id: mkdirProc
        command: ["mkdir", "-p", root.screenshotsDir]
    }

    function takeScreenshot(mode: string) {
        // mode: "screen", "window", "region"
        const target = mode === "screen" ? "fullscreen"
            : mode === "window" ? "windows"
            : mode === "region" ? "region"
            : "smart"
        snapProc.exec(["omasnap", target])
    }

    Process {
        id: snapProc
        onExited: code => {
            if (code !== 0) {
                QsServices.Logger.error("Screenshot", `omasnap failed with code: ${code}`)
            }
        }
    }

    function startRecording() {
        if (isRecording) return

        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
        const filename = `recording-${timestamp}.mp4`
        const filepath = `${screenshotsDir}/${filename}`
        root.lastRecordingPath = filepath

        recordProc.exec([
            "wf-recorder",
            "-f", filepath,
            "-c", "h264_vaapi",
            "-d", "/dev/dri/renderD128"
        ])

        root.isRecording = true
        QsServices.Logger.info("Screenshot", "Recording started")
    }

    Process {
        id: recordProc
        onExited: code => {
            root.isRecording = false
            if (code === 0) {
                QsServices.Logger.info("Screenshot", `Recording saved: ${root.lastRecordingPath}`)
                notifyProc.exec([
                    "notify-send",
                    "-i", "video-x-generic",
                    "Screen recording saved",
                    root.lastRecordingPath
                ])
            }
        }
    }

    function stopRecording() {
        if (!isRecording) return

        stopRecordProc.running = true
        // isRecording will be set to false when the recording process finishes
    }

    Process {
        id: stopRecordProc
        command: ["pkill", "-SIGINT", "wf-recorder"]
    }

    function openScreenshotsFolder() {
        openProc.exec(["xdg-open", screenshotsDir])
    }

    Process {
        id: openProc
    }
}
