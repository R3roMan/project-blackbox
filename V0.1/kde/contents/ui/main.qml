import QtQuick
import org.kde.plasma.plasmoid

WallpaperItem {
    id: wallpaper

    Scene {
        anchors.fill: parent
        mode: wallpaper.configuration.Mode || "wallpaper"
        editsJson: wallpaper.configuration.RoomEdits || "{}"
        durationMs: wallpaper.configuration.DurationMs || 480
        ambientFps: wallpaper.configuration.AmbientFps || 24
        motionAllowed: wallpaper.configuration.MotionAllowed !== false
        exposed: wallpaper.visible

        onSettingsUpdated: {
            wallpaper.configuration.Mode = mode
            wallpaper.configuration.RoomEdits = editsJson
            wallpaper.configuration.DurationMs = durationMs
            wallpaper.configuration.AmbientFps = ambientFps
            wallpaper.configuration.MotionAllowed = motionAllowed
            wallpaper.configuration.writeConfig()
        }
    }
}
