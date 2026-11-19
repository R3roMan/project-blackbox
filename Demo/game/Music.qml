import QtQuick
import QtMultimedia
import "../ui" as Ui

Item {
    id: music
    objectName: "blackboxMusic"
    required property bool enabledSound
    required property bool activeWindow
    required property string track
    required property bool quiet
    property string variation: ""

    visible: false
    readonly property string score: !track.length || track === "home" ? track
        : quiet ? track + "-pause" : variation.length ? track + "-" + variation : track
    readonly property bool listening: enabledSound && activeWindow && score.length > 0 && Ui.SoundMix.gain("music")>0

    function sync() {
        if (listening)
            player.play()
        else
            player.pause()
    }

    onListeningChanged: sync()
    onScoreChanged: sync()

    MediaPlayer {
        id: player
        objectName: "musicPlayer"
        source: music.score.length ? Qt.resolvedUrl("../audio/music/" + music.score + ".ogg") : ""
        loops: MediaPlayer.Infinite
        audioOutput: AudioOutput {
            volume:(music.track==="book" ? (music.quiet ? .08 : .21)
                : music.track==="witch" ? .29 : music.quiet ? .12 : music.track==="home" ? .38 : .32)*Ui.SoundMix.gain("music")
            Behavior on volume { NumberAnimation { duration: 220 } }
        }
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.LoadedMedia || mediaStatus === MediaPlayer.BufferedMedia)
                music.sync()
        }
    }
}
