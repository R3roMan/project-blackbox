import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../native" as Native
import "../Demo/game" as Game
import "../Demo/ui" as Ui
import "../V0.1/kde/contents/ui" as Template
import "../Demo/game/Rules.js" as Rules
import "../Demo/game/Loadout.js" as Gear
import "../Demo/game/Progress.js" as Progress
import "../Demo/game/SaveData.js" as SaveData

Item {
    id:host
    objectName:"blackboxDesktopHost"
    property string screenName:Screen.name
    property bool claimed:false
    property string ownershipToken:Date.now().toString(36)+"-"+Math.random().toString(36)
    function claimVisible() {
        if(visible) claimed=Native.Desktop.claim(screenName,ownershipToken)
        else if(claimed) {
            if(battle.item)Native.Desktop.parkRun(SaveData.encodeRun(battle.item.run))
            Native.Desktop.release(ownershipToken);claimed=false
        }
    }
    onVisibleChanged:claimVisible()
    property bool bookOpen:false
    property string bookTab:"enemies"
    property var stored:JSON.parse(Native.Desktop.progress())
    property var records:stored.profile || stored
    property var discovered:stored.discoveries && stored.discoveries.enemies ? stored.discoveries : ({enemies:[],abilities:[]})
    function persist() {Native.Desktop.saveProgress(JSON.stringify({profile:records,discoveries:discovered}))}
    readonly property var options:Native.Desktop.config
    readonly property string mode:options.mode
    readonly property bool home:Native.Desktop.atHome && visible
    readonly property var backgrounds: {
        const map={}
        for(const front of ["front","left","right","up","down"]) if(options["wallpaper_"+front]) map[front]=options["wallpaper_"+front]
        return map
    }
    function report() {
        if(!claimed || !battle.item)return
        const game=battle.item,run=game.run
        const actives=run.slots.active.map(function(slot,i){return slot.item ? {title:Gear.activeAbilities[slot.item.id].title,id:slot.item.id,cooldown:Rules.activeCooldown(run,slot.item.id),duration:Rules.abilityRecovery(run,slot)} : {title:"Empty",cooldown:0,duration:1}})
        Native.Desktop.publish({atHome:host.home,visibilityReady:Native.Desktop.visibilityReady,wave:run.wave,phase:run.phase,hp:Math.ceil(run.health),maxHp:Gear.maxHealth(run),front:game.frontId,ammo:Gear.current(run).ammo,magazine:Rules.magazine(run),paused:game.paused,actives:actives,mode:mode,critical:Rules.criticalProfile(run,Gear.weapons[Gear.current(run).id]).chance,heat:run.desktop?.heat || 0,gpuPressure:run.desktop?.pressure || 0})
    }
    onHomeChanged:if(home && mode==="play" && battle.item)battle.item.keyTargetFocus()
    Component.onCompleted: {claimVisible();report()}
    Component.onDestruction: {if(claimed && battle.item)Native.Desktop.parkRun(SaveData.encodeRun(battle.item.run));Native.Desktop.release(ownershipToken)}
    Image {anchors.fill:parent;source:host.backgrounds.front || Qt.resolvedUrl("../V0.1/kde/contents/images/shrine.png");fillMode:Image.PreserveAspectCrop}
    Loader {
        anchors.fill:parent;active:host.claimed && ["idle","performance"].includes(host.mode);visible:active
        sourceComponent:Template.Scene {
            mode:host.mode==="performance" ? "performance" : "wallpaper"
            preview:false
            exposed:host.home
            enabled:host.home
            ambientFps:Math.min(24,host.options.frameLimit)
            motionAllowed:host.options.motion
            editsJson: {
                const map={front:"shrine",left:"media",right:"lab",up:"sky",down:"abyss"},edits={}
                for(const key of Object.keys(host.backgrounds)) edits[map[key]]={image:host.backgrounds[key]}
                return JSON.stringify(edits)
            }
        }
    }
    Loader {anchors.fill:parent;active:host.claimed && host.mode==="xd";sourceComponent:Game.Shrine3D {motion:host.home && host.options.motion}}
    Loader {
        id:battle
        anchors.fill:parent
        active:host.claimed
        visible:host.mode==="play" && !host.bookOpen
        sourceComponent:Game.PlayScene {
            id:game
            resumeState:Native.Desktop.parkedRun()
            artDirectory:Qt.resolvedUrl("../V0.1/kde/contents/images/")
            backgroundFiles:host.backgrounds
            allowed:host.home && host.mode==="play" && !host.bookOpen
            sound:host.options.sound
            motion:host.options.motion
            frameLimit:host.options.frameLimit
            graphicsDetail:host.options.gpuEffects && Native.Desktop.gpu>.8 ? 0 : host.options.detail
            wallpaperQuality:host.mode==="performance" ? 1080 : 0
            showTimer:host.options.showTimer
            unlockedGear:Progress.unlocked(host.records,host.options.achievementOverride)
            knownEnemies:host.discovered.enemies
            onSaveRequested:function(data){Native.Desktop.saveRun(data);game.saveNotice="Run saved in desktop settings"}
            onTimerRequested:function(value){Native.Desktop.setOption("showTimer",value)}
            onFrameLimitRequested:function(value){Native.Desktop.setOption("frameLimit",value)}
            onSoundRequested:Native.Desktop.setOption("sound",!sound)
            onMotionRequested:Native.Desktop.setOption("motion",!motion)
            onDetailRequested:function(value){Native.Desktop.setOption("detail",value)}
            onExitRequested:Native.Desktop.setOption("mode","idle")
            onDiscovered:function(group,id){if(!host.discovered[group].includes(id)){const next=Object.assign({},host.discovered);next[group]=next[group].concat(id);host.discovered=next;host.persist()}}
            onCareerDelta:function(delta){host.records=JSON.parse(Native.Desktop.mergeProgress(JSON.stringify(delta)));host.persist()}
        }
    }
    Timer {interval:1000;repeat:true;running:host.visible && !host.claimed;onTriggered:host.claimVisible()}
    Timer {
        interval:250;repeat:true;running:host.claimed
        onTriggered: {
            if(battle.item) {
                const run=battle.item.run
                if(!run.desktop)run.desktop={cpuMode:false,heat:0,locked:false,pressure:0,cpu:0,music:0,musicTick:0}
                run.desktop.cpuMode=host.options.cpuAmmo
                run.desktop.cpu=Native.Desktop.cpu
                const bands=Native.Desktop.bands
                const bass=(bands[0]+bands[1]+bands[2])/3,treble=(bands[5]+bands[6]+bands[7])/3
                run.desktop.resonance=host.options.musicReactive ? (bass>treble*1.25 ? "bass" : treble>bass*1.25 ? "treble" : "pulse") : ""
                run.desktop.music=host.options.musicReactive && host.home ? Native.Desktop.loudness : 0
            }
            host.report()
        }
    }
    Connections {
        target:Native.Desktop
        function onCommandRequested(name) {
            if(!host.claimed || !battle.item)return
            const game=battle.item
            if(name==="new") {Native.Desktop.setOption("mode","play");game.resetRun()}
            else if(name==="continue") {
                const restored=SaveData.decodeRun(Native.Desktop.savedRun(),Progress.unlocked(host.records,host.options.achievementOverride))
                if(restored) {Native.Desktop.setOption("mode","play");game.run=restored;game.frontId=restored.playerFront;game.previousFront=game.frontId;game.paused=true;game.publish()}
            } else if(name==="pause" || name==="settings" || name==="loadout") game.pauseRun(name==="settings" ? "settings" : "build")
            else if(name==="begin") {if(host.home)game.startWave()}
            else if(name==="resume") {if(host.home) {game.paused=false;game.keyTargetFocus()}}
            else if(name==="save") Native.Desktop.saveRun(SaveData.encodeRun(game.run))
            else if(host.home && host.mode==="play" && !game.paused) {
                if(name==="reload")game.reloadGun()
                if(name==="q" || name==="e") {Rules.useAbility(game.run,name==="q" ? 0 : 1,game.frontId,0,null);game.publish()}
                if(name==="weapon1" || name==="weapon2")game.equipWeapon(name==="weapon1" ? 0 : 1)
                if(["left","right","up","down"].includes(name))game.turnView(name)
                if(name==="shield") {Rules.holdShield(game.run,!game.run.shield.raised);game.publish()}
            }
            host.report()
        }
    }
    Loader {
        anchors.fill:parent;active:host.bookOpen;z:40
        sourceComponent:Ui.ReferencePage {
            artDirectory:Qt.resolvedUrl("../V0.1/kde/contents/images/")
            firstTab:host.bookTab;known:host.discovered;unlocks:Progress.unlocked(host.records,host.options.achievementOverride);career:host.records
            achievementsUnlocked:host.options.achievementOverride
            onUnlockToggleRequested:Native.Desktop.setOption("achievementOverride",!host.options.achievementOverride)
            onCloseRequested:host.bookOpen=false
        }
    }
    Loader {active:host.options.sound;sourceComponent:Game.Music {enabledSound:host.options.sound;activeWindow:host.home;track:host.bookOpen ? "book" : host.mode==="play" && battle.item ? battle.item.musicTrack : "home";quiet:host.bookOpen ? false : battle.item ? battle.item.paused : false;variation:battle.item ? battle.item.musicVariation : ""}}
    Row {
        anchors.left:parent.left;anchors.bottom:parent.bottom;anchors.margins:12;spacing:6;z:60
        visible:host.home && (!battle.item || battle.item.paused || host.mode!=="play" || battle.item.phase!=="combat")
        Ui.ActionButton {text:"Grimoire";onClicked:{if(battle.item)battle.item.pauseRun("build");host.bookOpen=true}}
        Ui.ActionButton {text:"Desktop settings";onClicked:settingsDrawer.open()}
    }
    Rectangle {
        anchors.horizontalCenter:parent.horizontalCenter;anchors.top:parent.top;anchors.topMargin:20
        visible:!Native.Desktop.visibilityReady
        width:Math.min(650,parent.width-30);height:54;color:"#ef211823";radius:6;border.color:"#c89b61";z:70
        Text {anchors.fill:parent;anchors.margins:9;wrapMode:Text.WordWrap;color:"#f2dfbf";text:"Enable the Blackbox desktop visibility helper in System Settings → Window Management → KWin Scripts. Play pauses whenever another app takes focus."}
    }
    Row {
        anchors.bottom:parent.bottom;anchors.horizontalCenter:parent.horizontalCenter;spacing:3;visible:host.home && host.options.musicReactive;z:9
        Repeater {model:Native.Desktop.bands
            Rectangle {required property var modelData;width:12;height:4+modelData*60;anchors.bottom:parent.bottom;color:"#c788ed";opacity:.65}}
    }
    Drawer {id:settingsDrawer;width:Math.min(620,host.width);height:host.height;edge:Qt.RightEdge;z:80
        DesktopOptions {anchors.fill:parent;anchors.margins:16}}
}
