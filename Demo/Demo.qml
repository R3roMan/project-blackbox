import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import QtQuick.Dialogs
import "../V0.1/kde/contents/ui" as Template
import "game" as Game
import "ui" as Ui
import "game/Progress.js" as Progress
import "game/SaveData.js" as SaveData

ApplicationWindow {
    id: window
    objectName: "blackboxDemo"
    width: 1200
    height: 750
    minimumWidth: 760
    minimumHeight: 530
    title: "Project Blackbox · Grimoire build"
    visible: true
    color: "#110e19"

    readonly property url art: Qt.resolvedUrl("../V0.1/kde/contents/images/")
    readonly property bool activeHome: visible && active && visibility !== Window.Minimized
    readonly property bool software: Qt.application.arguments.indexOf("--software") >= 0
        || view.softwareBackend || graphicsFailed
    property bool graphicsFailed: false
    property string page: "home"
    property bool sound: display.audioEnabled && !Qt.application.arguments.includes("--mute")
    property bool motion: display.animationEnabled
    onSoundChanged:if (!Qt.application.arguments.includes("--mute")) display.audioEnabled=sound
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
    readonly property var profile: Progress.read(codex.career)
    readonly property var unlocks: Progress.unlocked(profile,codex.unlockAchievements)
    readonly property var continuedRun:page==="home" ? SaveData.savedChoice(codex.savedRun,codex.previousRun,unlocks) : null
    readonly property string continueSummary: !continuedRun ? "No saved run" : continuedRun.training ? "Tutorial checkpoint"
        : "Wave "+continuedRun.wave+" · "+continuedRun.difficulty+(continuedRun.debug ? " · Practice" : "")
            +(continuedRun.restored ? " · Recovered save" : "")

    function saveRun(data) {
        if (!SaveData.decodeRun(data,unlocks)) return false
        if (codex.savedRun && SaveData.decodeRun(codex.savedRun,unlocks))
            codex.previousRun=codex.savedRun
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

    Settings {
        id: display
        location: codex.location
        category: "Display"
        property string framing: "fill"
        property int quality: 0
        property real zoom: 1
        property bool mouseTurns: true
        property int frameLimit:60
        property bool showTimer:false
        property int detail:1
        property string transitionStyle:"cinematic"
        property real transitionStrength:1
        property real textScale:1
        property bool autoSave:true
        property bool audioEnabled:true
        property bool animationEnabled:true
    }
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
        page = "home"
    }

    function beginGame(continuing) {
        tutorial=false
        const saved = continuing ? continuedRun : null
        if (continuing && !saved) return
        pendingResume = saved ? saved.data : ""
        page = "play"
    }

    function displayValues() {
        return {framing:display.framing,quality:display.quality,zoom:display.zoom,mouseTurns:display.mouseTurns,
            frameLimit:display.frameLimit,showTimer:display.showTimer,detail:display.detail,transitionStyle:display.transitionStyle,transitionStrength:display.transitionStrength,
            textScale:display.textScale,autoSave:display.autoSave}
    }

    function changeDisplay(key,value) {
        display[key] = value
    }

    function exportProgress(file) {
        const store = backupStore.createObject(window,{location:file})
        const payload = SaveData.bundle(profile,known,codex.unlockAchievements,displayValues(),sound,motion,
            SaveData.savedChoice(codex.savedRun,codex.previousRun,unlocks)?.data || "")
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
        for (const key of Object.keys(incoming.display))
            display[key] = incoming.display[key]
        sound = incoming.sound
        motion = incoming.motion
        codex.sync()
        display.sync()
        settingsStatus = "Progress imported. Continue opens the saved run."
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
        const before = Progress.unlocked(profile)
        const updated = Progress.merge(profile, delta)
        codex.career = JSON.stringify(updated)
        return Progress.achievements.filter(function(achievement) {
            return !before.includes(achievement.reward) && Progress.complete(updated, achievement)
        }).map(function(achievement) { return achievement.title })
    }

    Loader {
        id: view
        anchors.fill: parent
        readonly property bool softwareBackend: GraphicsInfo.api === GraphicsInfo.Software
        sourceComponent: window.page === "play" ? playPage : window.page === "xd" ? xdPage
            : window.page === "home" ? homePage : window.page === "settings" ? settingsPage
            : window.page === "achievements" ? achievementsPage
            : window.page === "controls" || window.page === "codex" ? referencePage : galleryPage
    }

    Loader {
        id:runBook
        anchors.fill:parent
        z:30
        active:window.page==="play" && window.bookVisible
        sourceComponent:Ui.ReferencePage {
            artDirectory:window.art
            firstTab:window.bookChapter || "enemies"
            firstEntry:window.bookEntry
            known:window.known
            unlocks:window.unlocks
            career:window.profile
            achievementsUnlocked:codex.unlockAchievements
            motion:window.motion
            overlay:true
            onUnlockToggleRequested:codex.unlockAchievements=!codex.unlockAchievements
            onCloseRequested:window.bookChapter=""
        }
    }

    readonly property Game.PlayScene currentPlay: page === "play" && view.item && view.item.objectName === "playScene" ? view.item as Game.PlayScene : null
    Component.onCompleted: {
        if (Screen.width * Screen.devicePixelRatio >= 3840 && Screen.height * Screen.devicePixelRatio >= 2000)
            showMaximized()
    }

    Loader {
        active: window.sound
        sourceComponent: Game.Music {
            enabledSound: window.sound
            activeWindow: window.activeHome
            track: window.bookVisible ? "book" : window.currentPlay ? window.currentPlay.musicTrack
                : window.page === "home" || window.page === "controls" || window.page === "codex" || window.page === "achievements"
                    ? (window.page==="codex" || window.page==="achievements" ? "book" : "home") : ""
            quiet: !window.bookVisible && window.currentPlay ? window.currentPlay.paused : false
            variation: !window.bookVisible && window.currentPlay ? window.currentPlay.musicVariation : ""
        }
    }

    Component {
        id: homePage

        Item {
            Image {
                anchors.fill: parent
                source: String(window.art) + "shrine.png"
                fillMode: Image.PreserveAspectCrop
            }
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#f40e0b15" }
                    GradientStop { position: 0.43; color: "#d9120c17" }
                    GradientStop { position: 1; color: "#11100d16" }
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * 0.35
                gradient: Gradient {
                    GradientStop { position: 0; color: "#00110d18" }
                    GradientStop { position: 1; color: "#f6110d18" }
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(34, parent.width * 0.069)
                width: Math.min(parent.width - x - 28, 602)
                spacing: 12

                Text {
                    text: "HOME SHRINE"
                    color: "#ffc295"
                    font.family: "IBM Plex Mono"
                    font.pixelSize: 14
                    font.letterSpacing: 4
                }
                Text {
                    width: parent.width
                    text: "BLACKBOX"
                    color: "#fff1e6"
                    font.family: "Archivo Black"
                    font.weight: Font.Black
                    font.pixelSize: Math.min(78, parent.width / 5.4)
                    font.letterSpacing: -2
                }
                Text {
                    width: Math.min(parent.width, 340)
                    text: "Hold the Shrine against waves from five fronts."
                    color: "#f1d8d2"
                    wrapMode: Text.WordWrap
                    font.family: "Inter"
                    font.pixelSize: 18
                }
                Text {
                    objectName: "bestWaveRecord"
                    text: "BEST WAVE   " + (window.profile.bestWave || "—")
                    color: "#f3bc94"
                    font.family: "IBM Plex Mono"
                    font.pixelSize: 13
                }
                Row {
                    spacing:8
                    Ui.ActionButton {
                        objectName:"continueRun"
                        enabled:!!window.continuedRun
                        Accessible.description:window.continueSummary
                        text:"Continue"
                        primary:true
                        implicitWidth:144
                        implicitHeight:47
                        onClicked:window.beginGame(true)
                    }
                    Ui.ActionButton {
                        objectName:"openPlay"
                        text:"New game"
                        primary:!window.continuedRun
                        implicitWidth:174
                        implicitHeight:47
                        onClicked:window.beginGame(false)
                    }
                }
                Text {
                    text:window.continueSummary
                    color:window.continuedRun ? "#efd2b5" : "#beb0c1"
                    font.family:"Inter"
                    font.pixelSize:Ui.UiMetrics.text(13)
                }
                Flow {
                    width:parent.width
                    spacing:8
                    Ui.ActionButton {objectName:"openTutorial";text:"Tutorial battle";onClicked:{window.tutorial=true;window.pendingResume="";window.page="play"}}
                    Ui.ActionButton { objectName: "openControls"; text: "Controls"; onClicked: window.page = "controls" }
                    Ui.ActionButton { objectName: "openCodex"; text: "Grimoire"; onClicked: window.page = "codex" }
                    Ui.ActionButton { objectName: "openAchievements"; text: "Achievements"; onClicked: window.page = "achievements" }
                    Ui.ActionButton {objectName:"openSettings"; text:"Settings"; onClicked:window.page="settings"}
                }
                Row {
                    spacing: 8
                    Ui.ActionButton { text: "Idle"; onClicked: window.page = "idle" }
                    Ui.ActionButton { text: "Performance"; onClicked: window.page = "performance" }
                    Ui.ActionButton { text: "XD courtyard"; enabled: !window.software; onClicked: window.page = "xd" }
                }
            }
            Row {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 22
                spacing: 8
                Ui.ActionButton {
                    text: window.sound ? "Mute" : "Sound"
                    onClicked: window.sound = !window.sound
                }
                Ui.ActionButton {
                    text: window.motion ? "Motion on" : "Motion off"
                    onClicked: window.motion = !window.motion
                }
            }
            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 25
                text: window.software ? "Software playfield" : ""
                color: "#ded0d7"
                font.family: "IBM Plex Mono"
                font.pixelSize: 12
            }
        }
    }

    Component {
        id: referencePage
        Ui.ReferencePage {
            artDirectory: window.art
            motion:window.motion
            firstTab: window.page === "controls" ? "controls" : "enemies"
            known: window.known
            career:window.profile
            unlocks: window.unlocks
            achievementsUnlocked: codex.unlockAchievements
            onUnlockToggleRequested: codex.unlockAchievements = !codex.unlockAchievements
            onCloseRequested: window.goHome()
        }
    }

    Component {
        id: achievementsPage
        Ui.ReferencePage {
            artDirectory:window.art
            motion:window.motion
            firstTab:"achievements"
            known:window.known
            unlocks:window.unlocks
            career:window.profile
            achievementsUnlocked: codex.unlockAchievements
            onUnlockToggleRequested: codex.unlockAchievements = !codex.unlockAchievements
            onCloseRequested: window.goHome()
        }
    }

    Component {
        id:settingsPage
        Ui.MainSettings {
            display:window.displayValues()
            sound:window.sound
            motion:window.motion
            status:window.settingsStatus
            onDisplayRequested:function(key,value) {window.changeDisplay(key,value)}
            onSoundRequested:window.sound=!window.sound
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
            transitionStyle:display.transitionStyle
            transitionStrength:display.transitionStrength
            autoSave:display.autoSave
            onSaveRequested:function(data,automatic) {
                const saved=window.saveRun(data)
                if (!automatic || !saved)
                    play.saveNotice=saved ? "Saved · Wave "+(play.wave || play.upcomingStage.wave) : "Save failed"
            }
            onTextScaleRequested:function(value) { display.textScale=value }
            onAutoSaveRequested:function(value) { display.autoSave=value }
            onDetailRequested:function(value) {display.detail=value}
            onTransitionStyleRequested:function(value) {display.transitionStyle=value}
            onTransitionStrengthRequested:function(value) {display.transitionStrength=value}
            wallpaperFit: display.framing
            wallpaperQuality: display.quality
            wallpaperZoom: display.zoom
            mouseTurns: display.mouseTurns
            onMouseTurnsRequested: function(value) { display.mouseTurns = value }
            onFitRequested: function(value) { display.framing = value }
            onQualityRequested: function(value) { display.quality = value }
            onZoomRequested: function(value) { display.zoom = value }
            onExitRequested: window.goHome()
            onSoundRequested: window.sound = !window.sound
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
                    text: gallery.performance ? "Performance" : "Idle"
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
            Template.Scene {
                id: gallery
                anchors.top: galleryBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                preview: true
                focus: true
                exposed: window.activeHome
                mode: window.page === "performance" ? "performance" : "wallpaper"
                motionAllowed: window.motion
            }
            Shortcut {
                sequence: "Escape"
                enabled: !gallery.drawerOpen && !gallery.clean
                onActivated: window.goHome()
            }
        }
    }

    Component {
        id: xdPage
        Item {
            id: xd
            property real orbit: 0
            Loader {
                id: courtyard
                anchors.fill: parent
                active: window.activeHome
                sourceComponent: Component {
                    Game.Shrine3D {
                        motion: window.motion && window.activeHome
                        orbit: xd.orbit
                    }
                }
            }
            Timer {
                interval: 1500
                running: courtyard.active
                onTriggered: {
                    const scene = courtyard.item as Game.Shrine3D
                    if (scene && scene.effectiveTextureSize.width <= 0) {
                        window.graphicsFailed = true
                        window.goHome()
                    }
                }
            }
            DragHandler {
                target: null
                property real startOrbit: 0
                onActiveChanged: if (active) startOrbit = xd.orbit
                onActiveTranslationChanged: {
                    if (active)
                        xd.orbit = Math.max(-38, Math.min(38, startOrbit + activeTranslation.x * 0.17))
                }
            }
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 18
                Text {
                    Layout.fillWidth: true
                    text: "XD courtyard · Drag to orbit"
                    color: "#fff0df"
                    font.family: "Inter"
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    style: Text.Outline
                    styleColor: "#241727"
                }
                Ui.ActionButton { text: "Back to Home · Esc"; onClicked: window.goHome() }
            }
            Shortcut { sequence: "Escape"; onActivated: window.goHome() }
        }
    }
}
