import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import QtQuick.Dialogs
import "game" as Game
import "ui" as Ui
import "game/Progress.js" as Progress
import "game/SaveData.js" as SaveData
import "game/Meta.js" as Meta

ApplicationWindow {
    id: window
    objectName: "blackboxDemo"
    width: 1200
    height: 750
    minimumWidth: 760
    minimumHeight: 530
    title: "Project Blackbox · The Witch’s Vault"
    visible: true
    color: "#110e19"

    readonly property url art: Qt.resolvedUrl("../V0.1/kde/contents/images/")
    readonly property bool activeHome: visible && active && visibility !== Window.Minimized
    readonly property bool software: Qt.application.arguments.indexOf("--software") >= 0
        || view.softwareBackend || graphicsFailed
    property bool graphicsFailed: false
    property int initialDetail:1
    property string page: "home"
    readonly property bool sound: display.audioMaster>0 && !Qt.application.arguments.includes("--mute")
    property bool motion: display.animationEnabled
    onMotionChanged:display.animationEnabled=motion
    property bool tutorial:false
    property string pendingResume:""
    property string bookChapter:""
    property string bookEntry:""
    readonly property bool bookVisible:bookChapter.length>0

    function openBook(chapter,id) {
        bookEntry=id || ""
        bookChapter=chapter
    }
    property string settingsStatus:""
    readonly property var known: readCodex(codex.entries)
    readonly property var profile: Progress.withGrades(Progress.read(codex.career),careerVault.state)
    readonly property var unlocks: Progress.unlocked(profile,codex.unlockAchievements)
    readonly property var continuedRun:page==="home" ? SaveData.savedChoice(codex.savedRun,codex.previousRun,unlocks,careerVault.state) : null
    readonly property string continueSummary: !continuedRun ? "No saved run" : continuedRun.training ? "Tutorial checkpoint"
        : "Wave "+continuedRun.wave+" · "+continuedRun.difficulty+(continuedRun.debug ? " · Practice" : "")
            +(continuedRun.restored ? " · Recovered save" : "")

    function saveRun(data) {
        const run=SaveData.decodeRun(data,unlocks)
        if (!run || SaveData.isClosed(run,careerVault.state)) return false
        if (SaveData.closesCheckpoint(codex.savedRun,run.attemptId,run.seed) && SaveData.decodeRun(codex.savedRun,unlocks))
            codex.previousRun=codex.savedRun
        else if (!SaveData.closesCheckpoint(codex.previousRun,run.attemptId,run.seed))
            codex.previousRun=""
        codex.savedRun=data
        codex.sync()
        return codex.savedRun===data
    }

    Settings {
        id: codex
        location: String(StandardPaths.writableLocation(StandardPaths.ConfigLocation)) + "/project-blackbox-demo.ini"
        category: "Codex"
        property string entries: "{}"
        property string career: "{}"
        property bool unlockAchievements: false
        property string savedRun:""
        property string previousRun:""
    }
    Ui.ProfileVault {id:careerVault;location:codex.location}

    Settings {
        id: display
        location: codex.location
        category: "Display"
        property var backgroundFiles: ({})
        property string framing: "fill"
        property int quality: 0
        property real zoom: 1
        property bool mouseTurns: true
        property int frameLimit:60
        property bool showTimer:false
        property int detail:1
        property string transitionStyle:"cinematic"
        property real transitionStrength:1
        property real hudScale:1
        property real textScale:1
        property bool autoSave:true
        property bool audioEnabled:true
        property real audioMaster:audioEnabled ? 1 : 0
        property real audioMusic:1
        property real audioEffects:1
        property real audioAmbience:1
        property real audioInterface:1
        property bool animationEnabled:true
    }
    Binding {target:Ui.SoundMix;property:"master";value:display.audioMaster}
    Binding {target:Ui.SoundMix;property:"music";value:display.audioMusic}
    Binding {target:Ui.SoundMix;property:"effects";value:display.audioEffects}
    Binding {target:Ui.SoundMix;property:"ambience";value:display.audioAmbience}
    Binding {target:Ui.SoundMix;property:"interfaceGain";value:display.audioInterface}
    Binding { target:Ui.UiMetrics; property:"hudScale"; value:display.hudScale }
    Binding { target:Ui.UiMetrics; property:"textScale"; value:display.textScale }

    Shortcut {
        sequence: "F11"
        onActivated: {
            if (window.visibility === Window.FullScreen)
                window.showNormal()
            else
                window.showFullScreen()
        }
    }

    function readCodex(text) {
        try {
            const saved = JSON.parse(text)
            return {
                enemies: saved && Array.isArray(saved.enemies) ? saved.enemies : [],
                abilities: saved && Array.isArray(saved.abilities) ? saved.abilities : []
            }
        } catch (error) {
            return { enemies: [], abilities: [] }
        }
    }

    function remember(group, entry) {
        if (known[group].includes(entry))
            return
        const updated = readCodex(codex.entries)
        updated[group].push(entry)
        codex.entries = JSON.stringify(updated)
    }

    function goHome() {
        bookChapter=""
        careerVault.reload()
        page = "home"
    }

    function beginGame(continuing) {
        tutorial=false
        const saved = continuing ? continuedRun : null
        if (continuing && !saved) return
        if (menuSound.item) menuSound.item.play(saved ? "continue-game" : "new-game",.72)
        pendingResume = saved ? saved.data : ""
        page = "play"
    }

    function displayValues() {
        return {backgroundFiles:display.backgroundFiles,framing:display.framing,quality:display.quality,zoom:display.zoom,mouseTurns:display.mouseTurns,
            frameLimit:display.frameLimit,showTimer:display.showTimer,detail:display.detail,transitionStyle:display.transitionStyle,transitionStrength:display.transitionStrength,
            hudScale:display.hudScale,textScale:display.textScale,autoSave:display.autoSave,
            audioMaster:display.audioMaster,audioMusic:display.audioMusic,audioEffects:display.audioEffects,audioAmbience:display.audioAmbience,audioInterface:display.audioInterface}
    }

    function changeDisplay(key,value) {
        display[key] = value
    }

    function exportProgress(file) {
        const store = backupStore.createObject(window,{location:file})
        careerVault.reload()
        const payload = SaveData.bundle(profile,known,codex.unlockAchievements,displayValues(),sound,motion,
            SaveData.savedChoice(codex.savedRun,codex.previousRun,unlocks,careerVault.state)?.data || "",careerVault.state)
        store.setValue("payload",payload)
        store.sync()
        store.destroy()
        settingsStatus = "Progress exported. Keep the .blackbox.ini file to restore it later."
    }

    function importProgress(file) {
        const store = backupStore.createObject(window,{location:file})
        const incoming = SaveData.decodeBundle(String(store.value("payload","")))
        store.destroy()
        if (!incoming) {
            settingsStatus = "This file is damaged or uses an unsupported game-data format."
            return false
        }
        codex.entries = JSON.stringify(incoming.discoveries)
        codex.career = JSON.stringify(incoming.profile)
        codex.unlockAchievements = incoming.achievementsOverride
        // Keep recovery data for the imported run independent of the previous profile.
        codex.previousRun = ""
        codex.savedRun = incoming.runSave
        careerVault.importLedger(incoming.vault || Meta.fresh())
        if (codex.savedRun && !SaveData.savedChoice(codex.savedRun,"",unlocks,careerVault.state)) codex.savedRun=""
        for (const key of Object.keys(incoming.display))
            display[key] = incoming.display[key]
        motion = incoming.motion
        codex.sync()
        display.sync()
        settingsStatus = codex.savedRun ? "Progress imported. Continue opens the saved run." : "Progress imported."
        return true
    }

    Component {id:backupStore; Settings {category:"BlackboxBackup"}}
    FileDialog {
        id:exportDialog
        title:"Export Blackbox progress"
        fileMode:FileDialog.SaveFile
        nameFilters:["Blackbox backup (*.blackbox.ini)"]
        defaultSuffix:"blackbox.ini"
        onAccepted:window.exportProgress(selectedFile)
    }
    FileDialog {
        id:importDialog
        title:"Import Blackbox progress"
        fileMode:FileDialog.OpenFile
        nameFilters:["Blackbox backup (*.blackbox.ini)"]
        onAccepted:window.importProgress(selectedFile)
    }

    function reportProgress(delta) {
        const stored=Progress.read(codex.career)
        const before = Progress.unlocked(stored)
        const updated = Progress.withGrades(Progress.merge(stored, delta),careerVault.state)
        codex.career = JSON.stringify(updated)
        return Progress.achievements.filter(function(achievement) {
            return !before.includes(achievement.reward) && Progress.complete(updated, achievement)
        }).map(function(achievement) { return achievement.title })
    }

    Loader {
        id: view
        anchors.fill: parent
        readonly property bool softwareBackend: GraphicsInfo.api === GraphicsInfo.Software
        sourceComponent: window.page === "play" ? playPage
            : window.page === "home" ? homePage : window.page === "settings" ? settingsPage
            : window.page === "witch" ? witchPage : window.page === "record" ? recordPage
            : window.page === "controls" || window.page === "codex" ? referencePage : galleryPage
    }

    Loader {
        id:runBook
        anchors.fill:parent
        z:30
        active:window.page==="play" && window.bookVisible
        sourceComponent:Ui.ReferencePage {
            sound:window.sound && window.activeHome
            artDirectory:window.art
            firstTab:window.bookChapter || "enemies"
            firstEntry:window.bookEntry
            known:window.known
            unlocks:window.unlocks
            career:window.profile
            liveRun:window.currentPlay?.run || null
            liveRevision:window.currentPlay?.revision || 0
            achievementsUnlocked:codex.unlockAchievements
            motion:window.motion
            overlay:true
            onUnlockToggleRequested:codex.unlockAchievements=!codex.unlockAchievements
            onCloseRequested:window.bookChapter=""
        }
    }

    readonly property Game.PlayScene currentPlay: page === "play" && view.item && view.item.objectName === "playScene" ? view.item as Game.PlayScene : null
    Component.onCompleted: {
        window.initialDetail=display.detail
        if (Screen.width * Screen.devicePixelRatio >= 3840 && Screen.height * Screen.devicePixelRatio >= 2000)
            showMaximized()
    }

    Loader {
        id:menuSound
        active:window.visible && window.sound
        sourceComponent:Game.CuePlayer {allowed:window.activeHome;capacity:9}
    }

    Loader {
        active: window.visible && window.sound
        sourceComponent: Game.Music {
            enabledSound: window.sound
            activeWindow: window.activeHome
            track: window.bookVisible ? "book" : window.currentPlay ? window.currentPlay.musicTrack
                : window.page === "witch" ? "witch"
                : window.page === "home" || window.page === "record" || window.page === "controls" || window.page === "codex"
                    ? (window.page==="codex" ? "book" : "home") : ""
            quiet: !window.bookVisible && window.currentPlay ? window.currentPlay.paused : false
            variation: !window.bookVisible && window.currentPlay ? window.currentPlay.musicVariation : ""
        }
    }

    Component {
        id: homePage

        Item {
            id:home
            Image {
                anchors.fill:parent
                source:String(window.art)+"shrine.png"
                fillMode:Image.PreserveAspectCrop
            }
            Rectangle {
                anchors.fill:parent
                gradient:Gradient {
                    orientation:Gradient.Horizontal
                    GradientStop {position:0;color:"#f7110b16"}
                    GradientStop {position:.40;color:"#d1110c17"}
                    GradientStop {position:.79;color:"#3b100a15"}
                    GradientStop {position:1;color:"#0f160b19"}
                }
            }
            Rectangle {
                anchors.bottom:parent.bottom
                width:parent.width;height:parent.height*.28
                gradient:Gradient {
                    GradientStop {position:0;color:"#00120e18"}
                    GradientStop {position:1;color:"#eb120e18"}
                }
            }
            Ui.HomeSparks {anchors.fill:parent;animate:window.motion;exposed:window.activeHome}
            Column {
                id:homeMenu
                x:Math.max(27,parent.width*.074)
                anchors.verticalCenter:parent.verticalCenter
                width:Math.min(parent.width-x-24,550)
                spacing:home.height<600 ? 9 : 13

                Text {
                    text:"PROJECT"
                    color:"#ffbe94"
                    font.family:"IBM Plex Mono"
                    font.pixelSize:Ui.UiMetrics.text(13)
                    font.letterSpacing:5
                }
                Text {
                    text:"BLACKBOX"
                    color:"#fff4e7"
                    font.family:"Archivo Black"
                    font.weight:Font.Black
                    font.letterSpacing:-1
                    font.pixelSize:Math.min(home.height*.125,homeMenu.width*.155,84)
                }
                Rectangle {width:Math.min(parent.width,420);height:1;color:"#90614f"}
                Row {
                    spacing:10
                    Ui.ActionButton {
                        objectName:"openPlay"
                        text:"New game"
                        primary:!window.continuedRun
                        implicitWidth:Math.max(170,implicitContentWidth+35)
                        implicitHeight:Math.max(49,Ui.UiMetrics.text(16)+22)
                        onClicked:window.beginGame(false)
                    }
                    Ui.ActionButton {
                        objectName:"continueRun"
                        enabled:!!window.continuedRun
                        Accessible.description:window.continueSummary
                        text:"Continue"
                        primary:!!window.continuedRun
                        implicitWidth:Math.max(145,implicitContentWidth+35)
                        implicitHeight:Math.max(49,Ui.UiMetrics.text(16)+22)
                        onClicked:window.beginGame(true)
                    }
                }
                Text {
                    objectName:"bestWaveRecord"
                    text:(window.continuedRun ? window.continueSummary+"  ·  " : "")+"Best wave "+(window.profile.bestWave || "—")
                    color:"#e7c5ab"
                    font.family:"IBM Plex Mono"
                    font.pixelSize:Ui.UiMetrics.text(12)
                }
                Grid {
                    columns:2
                    spacing:6
                    readonly property real controlWidth:Math.min((homeMenu.width-6)*.5,210)
                    Ui.ActionButton {
                        objectName:"openWitchShop"
                        width:parent.controlWidth
                        text:"◆  Witch’s Vault · "+careerVault.state.gems
                        accent:"#d09be9"
                        onClicked:{careerVault.reload();window.page="witch"}
                    }
                    Ui.ActionButton {
                        objectName:"openCodex"
                        width:parent.controlWidth
                        text:"▣  Grimoire"
                        onClicked:window.page="codex"
                    }
                    Ui.ActionButton {
                        objectName:"openRunRecord"
                        width:parent.controlWidth
                        text:"✦  Expedition records"
                        onClicked:window.page="record"
                    }
                    Ui.ActionButton {
                        objectName:"openTutorial"
                        width:parent.controlWidth
                        text:"▷  Tutorial battle"
                        onClicked:{
                            if (menuSound.item) menuSound.item.play("new-game",.72)
                            window.tutorial=true
                            window.pendingResume=""
                            window.page="play"
                        }
                    }
                }
                Row {
                    spacing:6
                    Ui.ActionButton {
                        objectName:"openSettings"
                        text:"⚙"
                        Accessible.name:"Settings"
                        hintText:"Settings"
                        implicitWidth:42
                        onClicked:window.page="settings"
                    }
                    Ui.ActionButton {
                        objectName:"openIdle"
                        text:"☽"
                        Accessible.name:"Idle wallpaper"
                        hintText:"Idle wallpaper"
                        implicitWidth:42
                        onClicked:window.page="idle"
                    }
                    Ui.ActionButton {
                        objectName:"openControls"
                        text:"?"
                        Accessible.name:"Controls"
                        hintText:"Controls"
                        implicitWidth:42
                        onClicked:window.page="controls"
                    }
                }
            }
        }
    }

    Component {
        id:witchPage
        Ui.WitchShop {
            ledger:careerVault.state
            motion:window.motion
            vaultOpened:window.profile.wave100Boss>0
            onPurchaseRequested:function(id) {if (careerVault.purchase(id) && menuSound.item) menuSound.item.play("buy",.72)}
            onRefundRequested:function(id) {if (careerVault.refund(id) && menuSound.item) menuSound.item.play("buy",.72)}
            onPracticePurchase:if (menuSound.item) menuSound.item.play("buy",.72)
            onCardRequested:function(id) {if (careerVault.turnCard(id) && menuSound.item) menuSound.item.play("book-flip",.66)}
            onBackRequested:window.goHome()
        }
    }

    Component {
        id:recordPage
        Ui.ExpeditionRecords {
            best:careerVault.state.best
            archived:careerVault.state.archive.slice().sort(function(a,b) { return b.date-a.date })
            onCloseRequested:window.goHome()
        }
    }

    Component {
        id: referencePage
        Ui.ReferencePage {
            sound:window.sound && window.activeHome
            artDirectory: window.art
            motion:window.motion
            firstTab: window.page === "controls" ? "controls" : "enemies"
            known: window.known
            career:window.profile
            nextTerms:Meta.contract(careerVault.state)
            unlocks: window.unlocks
            achievementsUnlocked: codex.unlockAchievements
            onUnlockToggleRequested: codex.unlockAchievements = !codex.unlockAchievements
            onCloseRequested: window.goHome()
        }
    }

    Component {
        id:settingsPage
        Ui.MainSettings {
            display:window.displayValues()
            initialDetail:window.initialDetail
            motion:window.motion
            status:window.settingsStatus
            onDisplayRequested:function(key,value) {window.changeDisplay(key,value)}
            onMotionRequested:window.motion=!window.motion
            onExportRequested:exportDialog.open()
            onImportRequested:importDialog.open()
            onCloseRequested:window.goHome()
        }
    }

    Component {
        id: playPage
        Game.PlayScene {
            id: play
            artDirectory: window.art
            tutorial:window.tutorial
            vault:careerVault
            bookVisible:window.bookVisible
            enabled:!bookVisible
            onCodexRequested:function(chapter,id) { window.openBook(chapter,id) }
            frameLimit:display.frameLimit
            showTimer:display.showTimer
            onFrameLimitRequested:function(value) {display.frameLimit=value}
            onTimerRequested:function(value) {display.showTimer=value}
            allowed: window.activeHome
            software: window.software
            sound: window.sound
            motion: window.motion
            unlockedGear: window.unlocks
            knownEnemies:window.known.enemies
            resumeState:window.pendingResume
            graphicsDetail:display.detail
            initialDetail:window.initialDetail
            transitionStyle:display.transitionStyle
            transitionStrength:display.transitionStrength
            autoSave:display.autoSave
            onCheckpointClosed:function(id,seed) {
                if (SaveData.closesCheckpoint(codex.savedRun,id,seed)) {
                    codex.savedRun=""
                    codex.previousRun=""
                } else if (SaveData.closesCheckpoint(codex.previousRun,id,seed)) codex.previousRun=""
                codex.sync()
            }
            onSaveRequested:function(data,automatic) {
                const saved=window.saveRun(data)
                if (!automatic || !saved)
                    play.saveNotice=saved ? "Saved · Wave "+(play.wave || play.upcomingStage.wave) : "Save failed"
            }
            onHudScaleRequested:function(value) { display.hudScale=value }
            onTextScaleRequested:function(value) { display.textScale=value }
            onAutoSaveRequested:function(value) { display.autoSave=value }
            onDetailRequested:function(value) {display.detail=value}
            onTransitionStyleRequested:function(value) {display.transitionStyle=value}
            onTransitionStrengthRequested:function(value) {display.transitionStrength=value}
            backgroundFiles: display.backgroundFiles || ({})
            wallpaperFit: display.framing
            wallpaperQuality: display.quality
            wallpaperZoom: display.zoom
            mouseTurns: display.mouseTurns
            onMouseTurnsRequested: function(value) { display.mouseTurns = value }
            onFitRequested: function(value) { display.framing = value }
            onQualityRequested: function(value) { display.quality = value }
            onZoomRequested: function(value) { display.zoom = value }
            onExitRequested: window.goHome()
            onAudioLevelRequested:function(key,value) {window.changeDisplay(key,value)}
            onMotionRequested: window.motion = !window.motion
            onGraphicsUnavailable: window.graphicsFailed = true
            onDiscovered: function(group, entry) { window.remember(group, entry) }
            onCareerDelta: function(delta) {
                const earned = window.reportProgress(delta)
                if (earned.length)
                    play.announceAchievements(earned)
            }
        }
    }

    Component {
        id: galleryPage
        FocusScope {
            focus: true
            Rectangle {
                id: galleryBar
                anchors.left: parent.left
                anchors.right: parent.right
                height: 52
                color: "#211923"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 14
                    text:"Idle wallpaper"
                    color: "#ffdec7"
                    font.family: "Inter"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                }
                Ui.ActionButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    text: "Back to Home"
                    onClicked: window.goHome()
                }
            }
            Game.AmbientGallery {
                id: gallery
                sceneryDetail:display.detail
                anchors.top: galleryBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                preview: true
                focus: true
                exposed: window.activeHome
                mode:"wallpaper"
                motionAllowed: window.motion
            }
            Shortcut {
                sequence: "Escape"
                enabled: !gallery.drawerOpen && !gallery.clean
                onActivated: window.goHome()
            }
        }
    }
}
