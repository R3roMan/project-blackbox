import QtQuick
import QtQml.Models
import QtMultimedia

Item {
    id: audio
    required property bool allowed
    required property string weaponId
    property bool continuous: false
    property bool sustainWeapon: false
    property bool inBattle: false
    property bool bossWarning: false
    property bool soulDrain:false
    property string weather: "clear"
    visible: false
    property bool alternate: false

    readonly property var cues: ({
        warning:"alarm", damage:"hurt", wave:"alarm", clear:"clear", seal:"seal", roar:"roar",
        arrive:"arrive", shift:"shift", turn:"turn", shieldBlock:"shield-block", shieldBreak:"shield-break", shieldRefill:"shield-refill",
        pet:"pet", brood:"brood", boss:"boss", throwGrenade:"throw", detonation:"detonation", frost:"frost",
        breath:"breath", burn:"burn", distortion:"distortion", gift:"gift", curse:"curse", buy:"buy", empty:"empty",
        spinup:"spinup", refresh:"refresh", boon:"boon", shade:"shade", mega:"mega", electric:"electric",
        arrival:"arrival", moveBoss:"move-boss", tube:"tube", wreck:"wreck", shipFinal:"ship-final",
        intercept:"intercept", dodge:"dodge", turret:"turret", cannon:"cannon", loss:"loss", bolt:"alien-fire",
        meteor:"meteor-hit", smoke:"ninja-smoke", sealStep:"seal-step", starCharge:"star-charge", misfire:"misfire",
        poisonCloud:"poison-cloud", poisonImpact:"poison-impact", poisonBurst:"poison-burst",
        slimeSpit:"slime-spit", slimeImpact:"slime-impact", spinShard:"spin-shard",
        axeThrow:"fire-tomahawk", axeImpact:"axe-impact", playerDodge:"player-dodge", overheat:"overheat",
        bayonet:"bayonet", sawRev:"saw-rev", beamWarn:"beam-warn", beamFire:"beam-fire",
        combo:"combo-cut", staffCast:"staff-cast", staffImpact:"staff-impact", goldRay:"gold-ray",
        goldWarn:"gold-warn", coinReturn:"coin-return", flask:"flask-release",
        "summon-humontafagus":"summon-humontafagus", "summon-mastafangenbus":"summon-mastafangenbus",
        "summon-gigafinterus":"summon-gigafinterus", "summon-lucifoverus":"summon-lucifoverus",
        "summon-hasasasa":"summon-hasasasa", "summon-stinkaturumus":"summon-stinkaturumus",
        goreHit:"gore-hit", goreKill:"gore-kill", goreHeavy:"gore-heavy", deathCoin:"death-coin",
        distantCry:"distant-cry", distantEcho:"distant-echo", distantMetal:"distant-metal",
        fieldGuard:"field-guard", fieldBlock:"field-block", fieldCritical:"field-critical",
        landedCritical:"critical-landed", magnetFire:"magnet-fire", snakeBolt:"snake-bolt",
        sniperShift:"sniper-shift", sniperFire:"sniper-fire", feedBite:"feeding-bite", feedWindup:"feeding-windup",
        blackHoleOpen:"black-hole-open", voidStorm:"void-storm", voidFire:"void-fire", inferno:"inferno",
        bladeSplit:"blade-split", sawSplit:"saw-split", plasmaSplit:"plasma-split",
        "summon-voidGlitch":"summon-voidGlitch", beamStart:"beam-start",
        "summon-reapfast":"summon-reapfast", bossSiren:"boss-warning",
        "leviathan-suction":"leviathan-suction", "leviathan-bubbles":"leviathan-bubbles",
        "leviathan-charge":"leviathan-charge", "leviathan-roar":"leviathan-roar",
        leviathanReady:"leviathan-ready", leviathanBite:"leviathan-bite", bubbleBurst:"bubble-burst",
        tentacleGrab:"tentacle-grab", tentacleBite:"tentacle-bite", voidArrival:"void-arrival",
        voidShatter:"void-shatter", voidBrood:"void-brood", voidPush:"void-push", voidIntrusion:"void-intrusion",
        lureStart:"lure-start", lureBreak:"lure-break", inkWindup:"ink-windup", inkFire:"ink-fire",
        endmeBreak:"endme-break", faeelBite:"faeel-bite", orbBolt:"orb-bolt", returnBolt:"return-bolt",
        petBetray:"pet-betray", angelArrival:"angel-arrival", alienArrival:"alien-arrival",
        lalaLaugh:"lala-laugh", winterArrival:"winter-arrival", winterPulse:"winter-pulse",
        bloodMoonArrival:"blood-moon-arrival",bloodBolt:"blood-bolt",bloodDrain:"blood-drain",stoneBreak:"stone-break",
        rainArrival:"rain-arrival",nightArrival:"night-arrival",meteorArrival:"meteor-arrival",thunderStrike:"thunder-strike",
        windArrival:"wind-arrival",windGust:"wind-gust",glitchArrival:"glitch-arrival",aimMiss:"aim-miss",
        parryBlock:"parry-block",boneShatter:"bone-shatter",colourSpill:"colour-spill",soulTaken:"soul-taken",
        fangCrack:"fang-crack",fangLaunch:"fang-launch","leviathan-fangs":"leviathan-fangs",
        "death-humontafagus":"death-humontafagus","death-mastafangenbus":"death-mastafangenbus",
        "death-gigafinterus":"death-gigafinterus","death-lucifoverus":"death-lucifoverus",
        "death-hasasasa":"death-hasasasa","death-stinkaturumus":"death-stinkaturumus",
        "death-voidGlitch":"death-voidGlitch","death-reapfast":"death-reapfast",
        harvesterCry:"harvester-cry",soulRelease:"soul-release",crufiWeep:"crufi-weep",crufiScream:"crufi-scream",
        hurtHellborne:"hurt-hellborne",hurtSpace:"hurt-space",hurtVoid:"hurt-void",tutorialGood:"tutorial-good",tutorialRewind:"tutorial-rewind",tutorialMolt:"tutorial-molt",spray:"spray",cough:"cough","summon-oblogabgalus":"summon-oblogabgalus"
    })
    readonly property var voices: Array.from(new Set(Object.values(cues)))

    function play(cue) {
        if (!allowed)
            return
        if (cue === "fire") {
            alternate = !alternate
            const voice = alternate ? fireOne : fireTwo
            if (voice.status === SoundEffect.Ready)
                voice.play()
            return
        }
        if (cue === "reload") {
            if (reload.status === SoundEffect.Ready)
                reload.play()
            return
        }
        const index = voices.indexOf(cues[cue])
        const voice = index >= 0 ? effects.objectAt(index) : null
        if (voice && voice.status === SoundEffect.Ready)
            voice.play()
    }

    function syncLoop(voice, active) {
        if (allowed && active && voice.status === SoundEffect.Ready) {
            if (!voice.playing)
                voice.play()
        } else if (voice.playing) {
            voice.stop()
        }
    }

    function syncWeather() {
        syncLoop(battle,inBattle)
        syncLoop(rain,inBattle && (weather === "rain" || weather === "thunder"))
        syncLoop(fireWeather,inBattle && weather === "inferno")
        syncLoop(winter,inBattle && weather === "winter")
        syncLoop(incursion,inBattle && weather === "incursion")
        syncLoop(wind,inBattle && weather === "windy")
        syncLoop(glitch,inBattle && weather === "glitch")
        syncLoop(siren,bossWarning)
        syncLoop(souls,soulDrain)
    }

    onContinuousChanged: {
        syncLoop(stream,continuous)
        if (continuous && weaponId !== "chainsaw")
            play("beamStart")
    }
    onWeatherChanged: syncWeather()
    onInBattleChanged: syncWeather()
    onBossWarningChanged: syncWeather()
    onSoulDrainChanged:syncWeather()
    onAllowedChanged: {
        syncLoop(stream,continuous)
        syncWeather()
        if (!allowed) {
            fireOne.stop()
            fireTwo.stop()
            reload.stop()
            for (let i = 0; i < effects.count; i += 1) {
                const voice = effects.objectAt(i) as SoundEffect
                if (voice)
                    voice.stop()
            }
        }
    }

    SoundEffect {
        id:souls
        source:Qt.resolvedUrl("../audio/harvester-loop.wav")
        loops:SoundEffect.Infinite
        volume:.37
        onStatusChanged:audio.syncLoop(souls,audio.soulDrain)
    }
    SoundEffect {
        id: wind
        source: Qt.resolvedUrl("../audio/wind-loop.wav")
        loops: SoundEffect.Infinite
        volume: .37
        onStatusChanged: audio.syncLoop(wind,audio.inBattle && audio.weather === "windy")
    }
    SoundEffect {
        id: glitch
        source: Qt.resolvedUrl("../audio/glitch-loop.wav")
        loops: SoundEffect.Infinite
        volume: .28
        onStatusChanged: audio.syncLoop(glitch,audio.inBattle && audio.weather === "glitch")
    }
    SoundEffect {
        id: fireOne
        source: Qt.resolvedUrl("../audio/fire-" + audio.weaponId + ".wav")
        volume: .69
    }
    SoundEffect {
        id: stream
        source: audio.sustainWeapon ? fireOne.source : ""
        loops: SoundEffect.Infinite
        volume: audio.weaponId === "chainsaw" ? .48 : .36
        onStatusChanged: audio.syncLoop(stream,audio.continuous)
    }
    SoundEffect {
        id: rain
        source: Qt.resolvedUrl("../audio/rain-loop.wav")
        loops: SoundEffect.Infinite
        volume: .25
        onStatusChanged: audio.syncLoop(rain,audio.inBattle && audio.weather === "rain")
    }
    SoundEffect {
        id: fireWeather
        source: Qt.resolvedUrl("../audio/inferno-loop.wav")
        loops: SoundEffect.Infinite
        volume: .45
        onStatusChanged: audio.syncLoop(fireWeather,audio.inBattle && audio.weather === "inferno")
    }
    SoundEffect {
        id: winter
        source: Qt.resolvedUrl("../audio/winter-loop.wav")
        loops: SoundEffect.Infinite
        volume: .29
        onStatusChanged: audio.syncLoop(winter,audio.inBattle && audio.weather === "winter")
    }
    SoundEffect {
        id: incursion
        source: Qt.resolvedUrl("../audio/void-loop.wav")
        loops: SoundEffect.Infinite
        volume: .37
        onStatusChanged: audio.syncLoop(incursion,audio.inBattle && audio.weather === "incursion")
    }
    SoundEffect {
        id: siren
        source: Qt.resolvedUrl("../audio/boss-siren-loop.wav")
        loops: SoundEffect.Infinite
        volume: .27
        onStatusChanged: audio.syncLoop(siren,audio.bossWarning)
    }
    SoundEffect {
        id: battle
        source: Qt.resolvedUrl("../audio/combat-loop.wav")
        loops: SoundEffect.Infinite
        volume: .22
        onStatusChanged: audio.syncLoop(battle,audio.inBattle)
    }
    SoundEffect {
        id: fireTwo
        source: fireOne.source
        volume: .69
    }
    SoundEffect {
        id: reload
        source: Qt.resolvedUrl("../audio/reload-" + audio.weaponId + ".wav")
        volume: .55
    }
    Instantiator {
        id: effects
        model: audio.voices
        delegate: SoundEffect {
            required property string modelData
            source: Qt.resolvedUrl("../audio/" + modelData + ".wav")
            volume: modelData.startsWith("distant-") ? .24
                : modelData === "arrive" || modelData === "pet" || modelData === "gore-hit" ? .19
                : modelData.startsWith("summon-") || modelData.startsWith("death-") ? .57 : .44
        }
    }
}
