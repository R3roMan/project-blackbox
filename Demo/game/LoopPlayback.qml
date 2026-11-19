import QtQuick
import QtMultimedia

MediaPlayer {
    id:loop
    required property string clip
    required property bool active
    required property real gain
    readonly property bool listening:active && gain>0 && clip.length>0
    source:listening ? Qt.resolvedUrl("../audio/"+clip+".wav") : ""
    autoPlay:true
    loops:MediaPlayer.Infinite
    audioOutput:AudioOutput {volume:loop.listening ? loop.gain : 0}
}
