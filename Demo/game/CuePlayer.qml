import QtQuick
import QtMultimedia
import "../ui" as Ui

// Cold clips queue their first trigger. Frequently used clips stay decoded.
Item {
    id: bank
    property bool allowed:true
    property var clips:({})
    property int sequence:0
    property int capacity:36
    property string defaultBus:"interface"
    visible:false

    function warm(name, volume, lane, bus) {
        const key=name+"|"+(lane || "")
        let clip=clips[key]
        if (clip) return clip
        const keys=Object.keys(clips)
        if (keys.length>=capacity) {
            keys.sort(function(a,b) {return clips[a].lastUse-clips[b].lastUse})
            const evict=keys.find(function(old) {return !clips[old].playing && !clips[old].queuedAt}) || keys[0]
            clips[evict].destroy()
            delete clips[evict]
        }
        clip=voice.createObject(bank,{file:name,lastUse:++sequence,gain:volume ?? .54,bus:bus || defaultBus})
        clips[key]=clip
        return clip
    }

    function play(name, volume, lane, bus) {
        if (!allowed || !name) return
        const clip=warm(name,volume,lane,bus)
        if (volume!==undefined) clip.gain=volume
        if (bus) clip.bus=bus
        clip.lastUse=++sequence
        if (clip.status===SoundEffect.Ready) {
            clip.queuedAt=0
            clip.play()
        } else if (clip.status!==SoundEffect.Error) {
            clip.queuedAt=Date.now()
        }
    }

    onAllowedChanged:if (!allowed) {
        for (const key of Object.keys(clips)) {
            clips[key].queuedAt=0
            clips[key].stop()
        }
    }

    Component {
        id: voice
        SoundEffect {
            id:sample
            required property string file
            property real gain:.54
            property string bus:"interface"
            volume:sample.gain*Ui.SoundMix.gain(sample.bus)
            property real queuedAt:0
            property int lastUse:0
            source:Qt.resolvedUrl("../audio/"+file+".wav")
            onStatusChanged:{
                if (status===SoundEffect.Loading) return
                const elapsed=Date.now()-queuedAt
                if (status===SoundEffect.Ready && bank.allowed && queuedAt && elapsed<900) sample.play()
                queuedAt=0
            }
        }
    }
}
