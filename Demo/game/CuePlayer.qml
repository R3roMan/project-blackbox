import QtQuick
import QtMultimedia
import "../ui" as Ui

Item {
    id: bank
    property bool allowed:true
    property int capacity:12
    property string defaultBus:"interface"
    property int sequence:0
    visible:false

    // Qt 6.12's SoundEffect backend can leave an invalid PipeWire notifier
    // behind. Reuse a bounded set of MediaPlayers for both cold and warm cues.
    function voiceFor(name, lane, interrupt) {
        const key=name+"|"+(lane || "")
        let idle=null
        let oldest=null
        for (let i=0; i<voices.count; ++i) {
            const voice=voices.itemAt(i)?.player
            if (!voice) continue
            if (voice.key===key) return voice
            if (!voice.busy && (!idle || voice.lastUse<idle.lastUse)) idle=voice
            if (!oldest || voice.lastUse<oldest.lastUse) oldest=voice
        }
        const voice=idle || (interrupt ? oldest : null)
        if (voice) {
            voice.cancel()
            voice.key=key
            voice.source=Qt.resolvedUrl("../audio/"+name+".wav")
            voice.lastUse=++sequence
        }
        return voice
    }

    function warm(name, lane, bus) {
        if (!allowed || !name || Ui.SoundMix.gain(bus || defaultBus)<=0) return
        return voiceFor(name,lane,false)
    }

    function play(name, volume, lane, bus) {
        const route=bus || defaultBus
        if (!allowed || !name || Ui.SoundMix.gain(route)<=0) return
        const voice=voiceFor(name,lane,true)
        if (!voice) return
        voice.gain=volume ?? .54
        voice.bus=route
        voice.lastUse=++sequence
        voice.pending=true
        voice.startWhenLoaded()
    }

    onAllowedChanged:if (!allowed) {
        for (let i=0; i<voices.count; ++i) voices.itemAt(i)?.player.cancel()
    }

    Repeater {
        id:voices
        model:bank.capacity
        Item {
            width:0
            height:0
            property alias player:sample
            MediaPlayer {
                id:sample
                property string key:""
                property real gain:.54
                property string bus:bank.defaultBus
                property int lastUse:0
                property bool pending:false
                readonly property bool busy:pending || playbackState===MediaPlayer.PlayingState
                audioOutput:AudioOutput {volume:sample.gain*Ui.SoundMix.gain(sample.bus)}

                function cancel() {
                    pending=false
                    if (playbackState!==MediaPlayer.StoppedState) stop()
                }

                function startWhenLoaded() {
                    if (!pending) return
                    if (mediaStatus===MediaPlayer.InvalidMedia || error!==MediaPlayer.NoError) {
                        pending=false
                    } else if (mediaStatus!==MediaPlayer.NoMedia && mediaStatus!==MediaPlayer.LoadingMedia) {
                        pending=false
                        if (bank.allowed && Ui.SoundMix.gain(bus)>0) {
                            if (position>0) position=0
                            play()
                        }
                    }
                }

                onMediaStatusChanged:startWhenLoaded()
                onErrorOccurred:pending=false
            }
        }
    }
}
