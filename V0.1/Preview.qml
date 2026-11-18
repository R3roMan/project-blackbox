import QtQuick
import QtQuick.Controls
import QtCore
import "kde/contents/ui"

ApplicationWindow {
    id: window
    width: 1280
    height: 800
    minimumWidth: 650
    minimumHeight: 490
    title: "PROJECT BLACKBOX · Desktop simulation"
    visible: true
    color: "#080b13"

    Settings {
        id: preferences
        location: String(StandardPaths.writableLocation(StandardPaths.ConfigLocation)) + "/project-blackbox-preview.ini"
        category: "Wallpaper"
        property string mode: "wallpaper"
        property string roomEdits: "{}"
        property int durationMs: 480
        property int ambientFps: 24
        property bool motionAllowed: true
    }

    Scene {
        id: scene
        anchors.fill: parent
        preview: true
        exposed: window.visibility !== Window.Minimized && window.visible
        focus: true
        mode: preferences.mode
        editsJson: preferences.roomEdits
        durationMs: preferences.durationMs
        ambientFps: preferences.ambientFps
        motionAllowed: preferences.motionAllowed
        onSettingsUpdated: {
            preferences.mode = mode
            preferences.roomEdits = editsJson
            preferences.durationMs = durationMs
            preferences.ambientFps = ambientFps
            preferences.motionAllowed = motionAllowed
        }
    }
}
