import QtQuick
import "../ui" as Ui

Item {
    id: audio
    required property bool allowed
    required property string weaponId
    property bool continuous: false
    property bool sustainWeapon: false
    property bool inBattle: false
    property bool bossWarning: false
    property bool soulDrain:false
    property bool flooded:false
    property string weather: "clear"
    property bool windy: weather==="windy"
    property bool inAbyss:false
    readonly property bool weatherActive:allowed && inBattle
    readonly property real ambience:Ui.SoundMix.gain("ambience")
    visible: false
    property bool alternate: false

    readonly property var cues: ({
        playerDeath:"player-death",veilBolt:"attack-veilskate",warning:"alarm", damage:"hurt", wave:"alarm", clear:"clear", seal:"seal", roar:"roar",
        takeoverWarn:"takeover-warn",takeoverTick:"takeover-tick",takeoverFinal:"takeover-final",takeoverSeal:"takeover-seal",
        coinArrival:"coin-arrival",gemArrival:"gem-arrival",continueGame:"continue-game",newGame:"new-game",
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
        distantSnigger:"distant-snigger", distantLaugh:"distant-laugh", distantBreath:"distant-breath",
        deathGroan:"demon-groan", deathRasp:"demon-rasp",
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
    CuePlayer {id:oneShots;allowed:audio.allowed;defaultBus:"effects"}

    function warmWeapon() {
        if (!weaponId || !allowed) return
        if (!sustainWeapon) {
            oneShots.warm("fire-"+weaponId,"a")
            oneShots.warm("fire-"+weaponId,"b")
        }
        oneShots.warm("reload-"+weaponId)
    }

    function play(cue) {
        if (!allowed) return
        if (cue==="fire") {
            alternate=!alternate
            oneShots.play("fire-"+weaponId,.78,alternate ? "a" : "b")
        } else if (cue==="reload") {
            oneShots.play("reload-"+weaponId,.63)
        } else if (cue.startsWith("ability:")) {
            oneShots.play("ability-"+cue.slice(8),.64)
        } else if (cue.startsWith("attack:")) {
            oneShots.play("attack-"+cue.slice(7),.68)
        } else {
            const file=cues[cue]
            if (!file) return
            oneShots.play(file,file.startsWith("distant-") ? (inAbyss ? .52 : .42)
                : file.startsWith("demon-") ? .46
                : ["arrive","pet","gore-hit","coin-arrival"].includes(file) ? .24
                : file.startsWith("summon-") || file.startsWith("death-") || ["clear","loss","takeover-warn","player-death"].includes(file) ? .76 : .53,
                "",file.startsWith("distant-") || ["rain-arrival","night-arrival","wind-arrival"].includes(file)
                    ? "ambience" : ["buy","new-game","continue-game","flask-release","refresh","coin-arrival","gem-arrival"].includes(file)
                    ? "interface" : "effects")
        }
    }

    onWeaponIdChanged:warmWeapon()
    onSustainWeaponChanged:warmWeapon()
    Component.onCompleted:warmWeapon()

    onContinuousChanged:if (continuous && weaponId !== "chainsaw") play("beamStart")
    onAllowedChanged:if (allowed) warmWeapon()

    LoopPlayback {
        clip:"harvester-loop"; active:audio.allowed && audio.soulDrain; gain:.37*audio.ambience
    }
    LoopPlayback {
        clip:"wind-loop"; active:audio.weatherActive && audio.windy; gain:.37*audio.ambience
    }
    LoopPlayback {
        clip:"glitch-loop"; active:audio.allowed && audio.inBattle && audio.weather==="glitch"; gain:.28*audio.ambience
    }
    LoopPlayback {
        clip:"fire-"+audio.weaponId
        active:audio.allowed && audio.continuous && audio.sustainWeapon
        gain:(audio.weaponId==="chainsaw" ? .57 : .49)*Ui.SoundMix.gain("effects")
    }
    LoopPlayback {
        clip:"rain-loop"
        active:audio.weatherActive && (audio.weather==="rain" || audio.weather==="thunder")
        gain:(audio.inAbyss ? .17 : .25)*audio.ambience
    }
    LoopPlayback {
        clip:"inferno-loop"; active:audio.weatherActive && audio.weather==="inferno"; gain:.45*audio.ambience
    }
    LoopPlayback {
        clip:"winter-loop"; active:audio.weatherActive && audio.weather==="winter"; gain:.29*audio.ambience
    }
    LoopPlayback {
        clip:"abyss-bubble-loop"; active:audio.allowed && audio.inBattle && audio.flooded; gain:.37*audio.ambience
    }
    LoopPlayback {
        clip:"boss-siren-loop"; active:audio.allowed && audio.bossWarning; gain:.27*audio.ambience
    }
}
