import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import "../native" as Native
import "../Demo/game" as Game
import "../Demo/ui" as Ui
import "../Demo/game/Rules.js" as Rules
import "../Demo/game/Loadout.js" as Gear
import "../Demo/game/Progress.js" as Progress
import "../Demo/game/Autoplay.js" as Autoplay
import "../Demo/game/SaveData.js" as SaveData
import "../Demo/game/Meta.js" as Meta

FocusScope {
    id:host
    focus:true
    objectName:"blackboxDesktopHost"
    property string screenName:Screen.name
    property bool claimed:false
    property bool useWorkArea:false
    property bool standaloneWindow:!useWorkArea
    property bool editingDesktop:false
    property rect workArea:Qt.rect(0,0,width,height)
    readonly property real areaLeft:useWorkArea ? Math.max(0,workArea.x) : 0
    readonly property real areaTop:useWorkArea ? Math.max(0,workArea.y) : 0
    readonly property real areaRight:useWorkArea ? Math.max(0,width-workArea.x-workArea.width) : 0
    readonly property real areaBottom:useWorkArea ? Math.max(0,height-workArea.y-workArea.height) : 0
    property string saveStatus:""
    Ui.ProfileVault {
        id:careerVault
        location:String(StandardPaths.writableLocation(StandardPaths.ConfigLocation))+"/project-blackbox-demo.ini"
    }
    Settings {
        id:checkpointStorage
        location:careerVault.location
        category:"Codex"
    }
    function dropCheckpoint(id,seed) {
        checkpointStorage.sync()
        if (SaveData.closesCheckpoint(String(checkpointStorage.value("savedRun","")),id,seed)) {
            checkpointStorage.setValue("savedRun","")
            checkpointStorage.setValue("previousRun","")
        } else if (SaveData.closesCheckpoint(String(checkpointStorage.value("previousRun","")),id,seed)) {
            checkpointStorage.setValue("previousRun","")
        }
        checkpointStorage.sync()
        if (SaveData.closesCheckpoint(Native.Desktop.parkedRun(),id,seed)) Native.Desktop.parkRun("")
    }
    function writeCheckpoint(data,automatic) {
        if (data.length && Native.Desktop.saveRun(data)) {
            saveStatus="Saved"
            if (!automatic && battle.item) battle.item.saveNotice="Saved · Wave "+battle.item.wave
        } else if (!automatic && battle.item) {
            saveStatus="Save failed"
            battle.item.saveNotice=saveStatus
        }
    }
    property string ownershipToken:Date.now().toString(36)+"-"+Math.random().toString(36)
    function claimVisible() {
        if(visible && (!preferredScreen || preferredScreen===screenName)) claimed=Native.Desktop.claim(screenName,ownershipToken)
        else if(claimed) {
            if(battle.item)Native.Desktop.parkRun(SaveData.encodeRun(battle.item.run))
            Native.Desktop.release(ownershipToken);claimed=false
        }
    }
    readonly property string preferredScreen:Native.Desktop.screens.includes(options.screenName) ? options.screenName : ""
    onPreferredScreenChanged:claimVisible()
    onScreenNameChanged:claimVisible()
    onVisibleChanged:claimVisible()
    property bool bookOpen:false
    property bool vaultOpen:false
    property string bookTab:"enemies"
    property string bookEntry:""
    function openBook(chapter,id) {
        bookTab=chapter
        bookEntry=id || ""
        bookOpen=true
    }
    Binding {target:Ui.SoundMix;property:"master";value:host.options.audioMaster;when:host.claimed}
    Binding {target:Ui.SoundMix;property:"music";value:host.options.audioMusic;when:host.claimed}
    Binding {target:Ui.SoundMix;property:"effects";value:host.options.audioEffects;when:host.claimed}
    Binding {target:Ui.SoundMix;property:"ambience";value:host.options.audioAmbience;when:host.claimed}
    Binding {target:Ui.SoundMix;property:"interfaceGain";value:host.options.audioInterface;when:host.claimed}
    Binding { target:Ui.UiMetrics; property:"hudScale"; value:host.options.hudScale || 1; when:host.claimed }
    Binding { target:Ui.UiMetrics; property:"textScale"; value:host.options.textScale || 1; when:host.claimed }
    property var stored:JSON.parse(Native.Desktop.progress())
    property var records:stored.profile || stored
    readonly property var availableRecords:Progress.withGrades(records,careerVault.state)
    property var discovered:stored.discoveries && stored.discoveries.enemies ? stored.discoveries : ({enemies:[],abilities:[]})
    function persist() {Native.Desktop.saveProgress(JSON.stringify({profile:records,discoveries:discovered}))}
    readonly property var options:Native.Desktop.config
    readonly property string mode:options.mode
    readonly property string linkedFront:Native.Desktop.desktopFront
    readonly property bool here:!options.linkDesktops || !!linkedFront
    readonly property bool home:(standaloneWindow ? activeFocus || Window.active : Native.Desktop.atHome)
        && !Native.Desktop.sessionLocked && visible && here && !editingDesktop
    property bool idleControls:false
    property real idleOpacity:idleControls ? 1 : 0
    property bool ctrlDown:false
    property bool ctrlAlone:false
    property int quickCount:0
    property bool quickQueued:false
    readonly property bool idleKeys:home && claimed && mode==="idle"
        && !bookOpen && !vaultOpen && !settingsDrawer.visible && !galleryLoader.item?.drawerOpen
    Behavior on idleOpacity {NumberAnimation {duration:220;easing.type:Easing.InOutQuad}}
    onIdleKeysChanged:if (!idleKeys) {
        ctrlDown=false
        ctrlAlone=false
        quickHold.stop()
        quickStart.stop()
        quickCount=0
    }

    Keys.onPressed:function(event) {
        if (!idleKeys) return
        if (event.isAutoRepeat) {
            if (event.key===Qt.Key_Space && ctrlDown) event.accepted=true
            return
        }
        if (event.key===Qt.Key_Escape && quickCount>0) {
            quickStart.stop()
            quickCount=0
            event.accepted=true
            report()
            return
        }
        if (event.key===Qt.Key_Control) {
            ctrlDown=true
            ctrlAlone=event.modifiers===Qt.NoModifier || event.modifiers===Qt.ControlModifier
        } else {
            ctrlAlone=false
            if (event.key===Qt.Key_Space && ctrlDown && !(event.modifiers & (Qt.ShiftModifier | Qt.AltModifier | Qt.MetaModifier)) && !quickCount) {
                quickHold.restart()
                event.accepted=true
            } else {
                quickHold.stop()
            }
        }
    }
    Keys.onReleased:function(event) {
        if (event.isAutoRepeat) return
        if (event.key===Qt.Key_Space) quickHold.stop()
        if (event.key!==Qt.Key_Control) return
        ctrlDown=false
        quickHold.stop()
        if (idleKeys && ctrlAlone && !quickCount) {
            idleControls=!idleControls
            report()
        }
        ctrlAlone=false
    }
    TapHandler {
        enabled:host.idleKeys && host.idleOpacity<.95 && !host.quickCount
        acceptedButtons:Qt.LeftButton
        gesturePolicy:TapHandler.DragThreshold
        onTapped:{
            host.Window.window?.requestActivate()
            galleryLoader.item?.forceActiveFocus(Qt.MouseFocusReason)
        }
    }
    Shortcut {
        sequence:"Ctrl+Space";context:Qt.WindowShortcut
        enabled:host.idleKeys && !host.quickCount
        autoRepeat:false
        onActivated:{
            host.ctrlAlone=false
            galleryLoader.item?.forceActiveFocus()
            quickHold.restart()
        }
    }
    Timer {
        id:quickHold;interval:420
        onTriggered:if (host.idleKeys && battle.item) {
            host.quickCount=3
            menuSound.item?.play("takeover-tick",.69)
            quickStart.start()
            host.report()
        }
    }
    Timer {
        id:quickStart;interval:1000;repeat:true
        onTriggered:{
            host.quickCount-=1
            if (host.quickCount>0) {
                menuSound.item?.play(host.quickCount===1 ? "takeover-final" : "takeover-tick",.69)
                return
            }
            stop()
            host.idleControls=false
            battle.item?.prepareQuickRun()
            host.quickQueued=true
            Native.Desktop.setOption("mode","play")
            Qt.callLater(host.beginQuickBattle)
        }
    }
    function beginQuickBattle() {
        if (!quickQueued || mode!=="play" || !home || !battle.item?.allowed)
            return
        quickQueued=false
        battle.item.startWave()
        report()
    }
    property bool gpuBudgetLimited:false
    property bool workspaceSyncQueued:false
    property string requestedWorkspace:""
    function syncWorkspace() {
        if (!claimed || !options.linkDesktops || !linkedFront) return
        if (mode==="play" && battle.item?.fighting && battle.item.frontId!==linkedFront) {
            if (requestedWorkspace===battle.item.frontId) return
            if (battle.item.turning) workspaceSyncQueued=true
            else battle.item.turnTo(linkedFront,"")
        } else if (["idle","performance"].includes(mode) && galleryLoader.item) {
            const room=frontRooms[linkedFront]
            if (room!==galleryLoader.item.destination && room!==galleryLoader.item.room)
                galleryLoader.item.go(room,true)
        }
    }
    readonly property var frontRooms:({front:"shrine",left:"media",right:"lab",up:"sky",down:"abyss"})
    onLinkedFrontChanged:{
        if (linkedFront===requestedWorkspace) requestedWorkspace=""
        Qt.callLater(syncWorkspace)
    }
    Timer {
        id:workspaceRequestTimeout;interval:1400
        onTriggered:host.requestedWorkspace=""
    }
    onModeChanged:{
        if (mode==="idle") idleControls=false
        if (options.linkDesktops && mode==="play" && battle.item) Native.Desktop.switchWorkspace(battle.item.frontId)
        else Qt.callLater(syncWorkspace)
    }
    function returnToPlasma() {
        if (battle.item && SaveData.phases.includes(battle.item.phase)) battle.item.saveCheckpoint(false)
        if (!Native.Desktop.returnToPlasma(Qt.resolvedUrl("desktop-session.py"))) saveStatus="Could not open KDE desktop switcher"
    }
    readonly property var backgrounds: {
        const map={}
        for(const front of ["front","left","right","up","down"]) if(options["wallpaper_"+front]) map[front]=options["wallpaper_"+front]
        return map
    }
    function report() {
        if(!claimed || !battle.item)return
        const game=battle.item,run=game.run
        const actives=run.slots.active.map(function(slot,i){return slot.item ? {title:Gear.activeAbilities[slot.item.id].title,id:slot.item.id,cooldown:Rules.activeCooldown(run,slot.item.id),duration:Rules.abilityRecovery(run,slot)} : {title:"Empty",cooldown:0,duration:1}})
        Native.Desktop.publish({renderer:game.projectedMode ? "2D fallback" : "Qt Quick 3D",
            canContinue:Native.Desktop.hasSave,debug:run.debug,startAt:run.startAt,saveStatus:host.saveStatus,atHome:host.home,visibilityReady:Native.Desktop.visibilityReady,wave:run.wave,phase:run.phase,idleControls:host.idleControls,countdown:host.quickCount,weapon:Gear.current(run).id,pet:run.pet?.id || "",difficulty:run.difficulty,auto:game.autoPlaying,autoLimit:game.autoLimit,waveTime:run.waveTime,workspace:host.linkedFront,workBottom:host.areaBottom,hp:Math.ceil(run.health),maxHp:Gear.maxHealth(run),front:game.frontId,ammo:Gear.current(run).ammo,magazine:Rules.magazine(run),paused:game.paused,actives:actives,mode:mode,critical:Rules.criticalProfile(run,Gear.weapons[Gear.current(run).id]).chance,heat:run.desktop?.heat || 0,gpuPressure:run.desktop?.pressure || 0})
    }
    onHomeChanged:if(home) {
        if (mode==="play" && battle.item) {
            battle.item.keyTargetFocus()
            Qt.callLater(beginQuickBattle)
        } else galleryLoader.item?.forceActiveFocus()
    }
    property int initialDetail:1
    Component.onCompleted: {initialDetail=options.detail;claimVisible();report()}
    Component.onDestruction: {if(claimed && battle.item)Native.Desktop.parkRun(SaveData.encodeRun(battle.item.run));Native.Desktop.release(ownershipToken)}
    Image {anchors.fill:parent;source:host.backgrounds.front || Qt.resolvedUrl("../Demo/assets/landscape/shrine-day.webp");fillMode:Image.PreserveAspectCrop}
    Loader {
        id:galleryLoader
        anchors.fill:parent
        active:host.claimed && ["idle","performance"].includes(host.mode)
        visible:active && host.here
        onLoaded:item.go(host.frontRooms[host.linkedFront || host.options.idleFront] || "shrine",true)
        sourceComponent:Game.AmbientGallery {
            onRoomChanged:{
                const front=Object.keys(host.frontRooms).find(key=>host.frontRooms[key]===room)
                if (!front || !host.home) return
                if (host.options.idleFront!==front) Native.Desktop.setOption("idleFront",front)
                if (host.options.linkDesktops) Native.Desktop.switchWorkspace(front)
            }
            mode:host.mode==="performance" ? "performance" : "wallpaper"
            preview:false
            exposed:host.home
            enabled:host.home
            focus:host.mode!=="play"
            mouseLook:host.options.mouseTurns
            escapeBack:!host.quickCount
            externalChrome:true
            chromeOpacity:host.idleOpacity
            ambientFps:Math.min(24,host.options.frameLimit)
            sceneryDetail:host.options.detail
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
        anchors.leftMargin:host.areaLeft
        anchors.topMargin:host.areaTop
        anchors.rightMargin:host.areaRight
        anchors.bottomMargin:host.areaBottom
        active:host.claimed
        visible:host.mode==="play" && host.here
        sourceComponent:Game.PlayScene {
            id:game
            resumeState:Native.Desktop.parkedRun()
            vault:careerVault
            artDirectory:Qt.resolvedUrl("../V0.1/kde/contents/images/")
            backgroundFiles:host.backgrounds
            allowed:host.mode==="play" && host.visible && !Native.Desktop.sessionLocked && !host.editingDesktop
                && (host.home || host.options.backgroundPlay || !!host.requestedWorkspace || turning && host.options.linkDesktops)
            mouseTurns:host.options.mouseTurns
            onMouseTurnsRequested:function(value){Native.Desktop.setOption("mouseTurns",value)}
            escapeBack:true
            wallpaperInsets:Qt.rect(host.areaLeft,host.areaTop,host.areaRight,host.areaBottom)
            interactive:host.home && host.mode==="play"
            onFrontIdChanged:if (host.options.linkDesktops && host.mode==="play" && host.here && host.claimed && frontId!==host.linkedFront) {
                host.workspaceSyncQueued=false
                host.requestedWorkspace=frontId
                if (!Native.Desktop.switchWorkspace(frontId)) host.requestedWorkspace=""
                else workspaceRequestTimeout.restart()
            }
            onTurningChanged:if (!turning && host.workspaceSyncQueued) {
                host.workspaceSyncQueued=false
                Qt.callLater(host.syncWorkspace)
            }
            backgroundPlay:host.options.backgroundPlay
            autoLimit:Autoplay.waveLimit(host.availableRecords,careerVault.state)
            onBackgroundPlayRequested:function(value) {Native.Desktop.setOption("backgroundPlay",value)}
            bookVisible:host.bookOpen || host.vaultOpen || settingsDrawer.visible
            enabled:!bookVisible
            onCodexRequested:function(chapter,id) { host.openBook(chapter,id) }
            software:GraphicsInfo.api===GraphicsInfo.Software
            autoSave:host.options.autoSave
            sound:host.options.audioMaster>0
            motion:host.options.motion
            frameLimit:host.options.frameLimit
            initialDetail:host.initialDetail
            graphicsRestartText:"Save the run and restart the preview or reload the wallpaper to fully apply this preset."
            graphicsDetail:host.gpuBudgetLimited ? Math.max(0,host.options.detail-1) : host.options.detail
            wallpaperQuality:host.mode==="performance" ? 1080 : 0
            showTimer:host.options.showTimer
            unlockedGear:Progress.unlocked(host.availableRecords,host.options.achievementOverride)
            knownEnemies:host.discovered.enemies
            onCheckpointClosed:function(id,seed) {host.dropCheckpoint(id,seed)}
            onSaveRequested:function(data,automatic) { host.writeCheckpoint(data,automatic) }
            onAutoSaveRequested:function(value) { Native.Desktop.setOption("autoSave",value) }
            onHudScaleRequested:function(value) { Native.Desktop.setOption("hudScale",value) }
            onTextScaleRequested:function(value) { Native.Desktop.setOption("textScale",value) }
            onTimerRequested:function(value){Native.Desktop.setOption("showTimer",value)}
            onFrameLimitRequested:function(value){Native.Desktop.setOption("frameLimit",value)}
            onAudioLevelRequested:function(key,value) {Native.Desktop.setOption(key,value)}
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
                run.desktop.gpuMode=host.options.gpuEffects
                const pressure=Math.min(1,Math.max(0,Native.Desktop.gpu)+(run.desktop.pressure || 0)*.45)
                run.desktop.gpuLoad=(run.desktop.gpuLoad || 0)*.65+pressure*.35
                host.gpuBudgetLimited=host.options.gpuEffects && run.desktop.gpuLoad>(host.gpuBudgetLimited ? .62 : .84)
                const bands=Native.Desktop.bands
                const bass=(bands[0]+bands[1]+bands[2])/3,treble=(bands[5]+bands[6]+bands[7])/3
                run.desktop.resonance=host.options.musicReactive && host.home && Native.Desktop.loudness>.045 ? (bass>treble*1.25 ? "bass" : treble>bass*1.25 ? "treble" : "pulse") : ""
                run.desktop.music=host.options.musicReactive && host.home ? Native.Desktop.loudness : 0
            }
            host.report()
        }
    }
    Connections {
        target:Native.Desktop
        function onCommandRequested(name) {
            if(!host.claimed || !battle.item || host.vaultOpen)return
            const game=battle.item
            if(name==="revert") host.returnToPlasma()
            else if(name==="grimoire") {if(host.home)host.openBook("enemies","")}
            else if(name==="play") {
                Native.Desktop.setOption("mode","play")
                if(host.options.linkDesktops) Native.Desktop.switchWorkspace(game.frontId)
            } else if(name==="new") {
                menuSound.item?.play("new-game",.72)
                Native.Desktop.setOption("mode","play")
                game.resetRun()
            }
            else if(name==="continue") {
                const unlocks=Progress.unlocked(host.availableRecords,host.options.achievementOverride)
                const saved=SaveData.savedChoice(Native.Desktop.savedRun(),Native.Desktop.previousRun(),unlocks,careerVault.state)
                if (saved) {
                    menuSound.item?.play("continue-game",.72)
                    Native.Desktop.setOption("mode","play")
                    game.restoreRun(SaveData.decodeRun(saved.data,unlocks))
                }
            } else if(name==="settings") settingsDrawer.open()
            else if(name==="pause" || name==="loadout") game.pauseRun("build")
            else if(name==="begin" && !host.bookOpen && host.home) {
                Native.Desktop.setOption("mode","play")
                game.startWave()
            }
            else if(name==="resume") {if(host.home && !host.bookOpen) {game.paused=false;game.keyTargetFocus()}}
            else if(name==="save") game.saveCheckpoint(false)
            else if(host.home && host.mode==="play" && !game.paused && !host.bookOpen) {
                if(name==="reload")game.reloadGun()
                if(name==="q" || name==="e") game.activateAbility(name==="q" ? 0 : 1,true)
                if(name==="weapon1" || name==="weapon2")game.equipWeapon(name==="weapon1" ? 0 : 1)
                if(["left","right","up","down"].includes(name))game.turnView(name)
                if(name==="shield") {Rules.holdShield(game.run,!game.run.shield.raised);game.publish()}
            }
            host.report()
        }
    }
    Loader {
        anchors.fill:parent
        anchors.leftMargin:host.areaLeft
        anchors.topMargin:host.areaTop
        anchors.rightMargin:host.areaRight
        anchors.bottomMargin:host.areaBottom
        active:host.bookOpen;z:40
        sourceComponent:Ui.ReferencePage {
            sound:(host.options.audioMaster>0) && host.home
            artDirectory:Qt.resolvedUrl("../V0.1/kde/contents/images/")
            firstTab:host.bookTab;firstEntry:host.bookEntry;overlay:host.mode==="play";motion:host.options.motion;known:host.discovered;unlocks:Progress.unlocked(host.availableRecords,host.options.achievementOverride);career:host.availableRecords
            achievementsUnlocked:host.options.achievementOverride
            liveRun:battle.item?.run || null
            liveRevision:battle.item?.revision || 0
            nextTerms:Meta.contract(careerVault.state)
            onUnlockToggleRequested:Native.Desktop.setOption("achievementOverride",!host.options.achievementOverride)
            onCloseRequested:host.bookOpen=false
        }
    }
    Loader {id:menuSound;active:(host.options.audioMaster>0);sourceComponent:Game.CuePlayer {allowed:host.home;capacity:9}}
    Loader {active:(host.options.audioMaster>0);sourceComponent:Game.Music {enabledSound:(host.options.audioMaster>0);activeWindow:host.home;track:host.vaultOpen ? "witch" : host.bookOpen ? "book" : host.mode==="play" && battle.item ? battle.item.musicTrack : "home";quiet:host.bookOpen || host.vaultOpen ? false : battle.item ? battle.item.paused : false;variation:!host.bookOpen && !host.vaultOpen && battle.item ? battle.item.musicVariation : ""}}
    Loader {
        anchors.fill:parent
        anchors.leftMargin:host.areaLeft
        anchors.topMargin:host.areaTop
        anchors.rightMargin:host.areaRight
        anchors.bottomMargin:host.areaBottom
        z:65
        active:host.vaultOpen && host.home
        sourceComponent:Ui.WitchShop {
            ledger:careerVault.state
            motion:host.options.motion
            vaultOpened:host.records.wave100Boss>0
            onPurchaseRequested:function(id) {if (careerVault.purchase(id) && menuSound.item) menuSound.item.play("buy",.72)}
            onRefundRequested:function(id) {if (careerVault.refund(id) && menuSound.item) menuSound.item.play("buy",.72)}
            onPracticePurchase:if (menuSound.item) menuSound.item.play("buy",.72)
            onCardRequested:function(id) {if (careerVault.turnCard(id) && menuSound.item) menuSound.item.play("book-flip",.66)}
            onBackRequested:host.vaultOpen=false
        }
    }
    Row {
        anchors.right:parent.right;anchors.top:parent.top;anchors.rightMargin:host.areaRight+14;anchors.topMargin:host.areaTop+70;spacing:6;z:60
        opacity:host.idleOpacity
        enabled:opacity>.95 && !host.quickCount
        visible:host.home && !host.bookOpen && !host.vaultOpen && host.mode!=="play" && opacity>0
        Ui.ActionButton {text:"Back to Play";primary:true;onClicked:Native.Desktop.command("play")}
        Ui.ActionButton {text:"Grimoire";onClicked:host.openBook("enemies","")}
        Ui.ActionButton {text:"Witch’s Vault";onClicked:{careerVault.reload();host.vaultOpen=true}}
        Ui.ActionButton {text:"Desktop settings";onClicked:settingsDrawer.open()}
    }
    Rectangle {
        anchors.horizontalCenter:parent.horizontalCenter;anchors.top:parent.top;anchors.topMargin:20
        visible:!Native.Desktop.visibilityReady && (host.mode==="play" || host.idleOpacity>.01)
        width:Math.min(650,parent.width-30);height:54;color:"#ef211823";radius:6;border.color:"#c89b61";z:70
        Text {anchors.fill:parent;anchors.margins:9;wrapMode:Text.WordWrap;color:"#f2dfbf";text:"Enable the Blackbox desktop visibility helper in System Settings → Window Management → KWin Scripts. It tells Blackbox when the wallpaper has focus."}
    }
    Row {
        anchors.bottom:parent.bottom;anchors.horizontalCenter:parent.horizontalCenter;spacing:3;visible:host.home && host.options.musicReactive && (host.mode==="play" || host.idleOpacity>.01);z:9
        Repeater {model:Native.Desktop.bands
            Rectangle {required property var modelData;width:12;height:4+modelData*60;anchors.bottom:parent.bottom;color:"#c788ed";opacity:.65}}
    }
    Item {
        id:desktopControls
        anchors.fill:parent
        anchors.leftMargin:host.areaLeft; anchors.rightMargin:host.areaRight
        anchors.topMargin:host.areaTop; anchors.bottomMargin:host.areaBottom
        z:80
    }
    Loader {
        anchors.fill:desktopControls;z:90
        active:host.quickCount>0
        sourceComponent:Game.OutcomeSplash {
            loss:false
            motion:host.options.motion
            message:String(host.quickCount)
        }
    }
    Drawer {id:settingsDrawer
        popupType:Popup.Item
        parent:desktopControls
        width:Math.min(620,desktopControls.width)
        height:desktopControls.height
        edge:Qt.RightEdge;z:80
        DesktopOptions {anchors.fill:parent;anchors.margins:16}}
}
