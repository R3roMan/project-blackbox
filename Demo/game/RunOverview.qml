import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Rules.js" as Rules
import "Loadout.js" as Gear
import "Pets.js" as Pets
import "Tarot.js" as Tarot

ColumnLayout {
    id: overview
    objectName: "runOverview"

    required property var run
    required property int revision
    required property string tab
    required property bool motion
    property bool dense: false
    readonly property bool editable: { revision; return Rules.canEditLoadout(run) }
    signal entryRequested(string chapter, string id)
    signal tabRequested(string name)
    signal swapRequested(string group, int from, int to)
    signal debugGearRequested(string group, string id, int slot)
    signal inventoryRequested(int cell, string group, int slot)
    signal audioLevelRequested(string key,real value)
    signal motionRequested()
    signal bugReportRequested()
    required property string wallpaperFit
    required property int wallpaperQuality
    required property real wallpaperZoom
    required property bool mouseTurns
    property int frameLimit:60
    property bool showTimer:false
    property bool autoSave:true
    property bool backgroundPlay:false
    signal backgroundPlayRequested(bool enabled)
    signal autoSaveRequested(bool enabled)
    signal hudScaleRequested(real scale)
    signal textScaleRequested(real scale)
    signal frameLimitRequested(int value)
    signal timerRequested(bool value)
    property int graphicsDetail:1
    property int initialDetail:graphicsDetail
    property string graphicsRestartText:"Save your run, then restart Blackbox to fully apply this preset."
    property string transitionStyle:"cinematic"
    property real transitionStrength:1
    signal mouseTurnsRequested(bool value)
    signal fitRequested(string value)
    signal qualityRequested(int value)
    signal zoomRequested(real value)
    signal detailRequested(int value)
    signal transitionStyleRequested(string value)
    signal transitionStrengthRequested(real value)

    readonly property bool loadoutTab:tab === "build" || tab === "inventory"
    readonly property var equipped: { revision; return Gear.current(run) }
    readonly property var crit: { revision; return Rules.criticalProfile(run,Gear.weapons[equipped.id]) }
    spacing: dense ? 8 : 12

    component Detail: Text {
        color: "#d7c6d9"
        font.family: "Inter"
        font.pixelSize: Ui.UiMetrics.text(14)
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }
    RowLayout {
        spacing: 7
        Ui.ActionButton {
            objectName: "buildTab"
            text: "Loadout · T"
            primary: overview.loadoutTab
            onClicked: overview.tabRequested("build")
        }
        Ui.ActionButton {
            objectName: "debugGearTab"
            visible: overview.run.debugUnlockAll && overview.editable
            text: "Debug gear"
            primary: overview.tab === "debugGear"
            onClicked: overview.tabRequested("debugGear")
        }
        Ui.ActionButton {
            objectName: "settingsTab"
            text: "Settings"
            primary: overview.tab === "settings"
            onClicked: overview.tabRequested("settings")
        }
    }

    Loader {
        Layout.fillWidth: true
        active: overview.tab === "debugGear" && overview.run.debugUnlockAll && overview.editable
        visible: active
        sourceComponent: DebugGear {
            run: overview.run
            revision: overview.revision
            onEquipRequested: function(group, id, slot) { overview.debugGearRequested(group, id, slot) }
        }
    }

    RowLayout {
        visible: overview.tab === "settings"
        Layout.fillWidth:true
        Detail {text:"Blackbox theme"}
        Ui.ThemeChooser {onThemeRequested:key=>Ui.InterfaceTheme.selectionRequested(key)}
        Ui.ActionButton {
            objectName: "pauseMotion"
            text: overview.motion ? "Motion on" : "Motion off"
            onClicked: overview.motionRequested()
        }
    }

    Switch {
        objectName: "mouseTurns"
        visible: overview.tab === "settings"
        text: "Mouse edge turns"
        checked: overview.mouseTurns
        onToggled: overview.mouseTurnsRequested(checked)
    }

    Ui.AudioSettings {
        Layout.fillWidth:true
        visible:overview.tab==="settings"
        onLevelRequested:function(key,value){overview.audioLevelRequested(key,value)}
    }

    Ui.FieldStyleOptions {visible:overview.tab==="settings"}
    Ui.ActionButton {visible:overview.tab==="settings";text:"Report a bug";onClicked:overview.bugReportRequested()}
    DisplaySettings {
        Layout.fillWidth: true
        visible: overview.tab === "settings"
        fit: overview.wallpaperFit
        quality: overview.wallpaperQuality
        zoom: overview.wallpaperZoom
        frameLimit:overview.frameLimit
        showTimer:overview.showTimer
        autoSave:overview.autoSave
        backgroundPlay:overview.backgroundPlay
        onBackgroundPlayChangedByUser:function(value) {overview.backgroundPlayRequested(value)}
        onAutoSaveChangedByUser:function(value) { overview.autoSaveRequested(value) }
        onHudScaleChangedByUser:function(value) {overview.hudScaleRequested(value)}
        onTextScaleChangedByUser:function(value) { overview.textScaleRequested(value) }
        onFrameLimitChangedByUser:function(value) {overview.frameLimitRequested(value)}
        onTimerChangedByUser:function(value) {overview.timerRequested(value)}
        detail:overview.graphicsDetail
        initialDetail:overview.initialDetail
        restartText:overview.graphicsRestartText
        transitionStyle:overview.transitionStyle
        transitionStrength:overview.transitionStrength
        onFitChangedByUser: function(value) { overview.fitRequested(value) }
        onQualityChangedByUser: function(value) { overview.qualityRequested(value) }
        onZoomChangedByUser: function(value) { overview.zoomRequested(value) }
        onDetailChangedByUser:function(value) {overview.detailRequested(value)}
        onTransitionStyleChangedByUser:function(value) {overview.transitionStyleRequested(value)}
        onTransitionStrengthChangedByUser:function(value) {overview.transitionStrengthRequested(value)}
    }

    ColumnLayout {
        visible: overview.loadoutTab
        spacing: 10

        Detail {
            objectName: "buildCombatStats"
            text: {
                overview.revision
                const pet = overview.run.pet
                return Math.ceil(overview.run.health)+" / "+Gear.maxHealth(overview.run)+" HP  ·  "+(Number.isFinite(Gear.availableGold(overview.run)) ? overview.run.gold : "∞")+" gold  ·  "+(pet ? Pets.spec(pet.id).title + " · Lv " + pet.level + "     " : "")
                    + (overview.crit.chance*100).toFixed(1) + "% critical chance · ×" + overview.crit.power.toFixed(2) + " damage"
                    + (overview.run.shield.level ? "     Shield Lv " + overview.run.shield.level : "")
            }
            color: "#e1c5ac"
        }
        Detail {
            objectName:"activeTarot"
            readonly property var omen:{overview.revision;return Tarot.card(overview.run.covenant?.tarot || "")}
            visible:!!omen
            color:"#efcc9e"
            text:omen ? "Tarot · "+omen.title+"  ·  "+omen.description : ""
        }
        InventoryPanel {
            id:fullLoadout
            Layout.fillWidth:true
            run:overview.run
            revision:overview.revision
            animate:overview.motion
            dense:overview.dense
            editable:overview.editable
            onEntryRequested:function(chapter,id) { overview.entryRequested(chapter,id) }
            onMoved:function(cell,group,slot) { overview.inventoryRequested(cell,group,slot) }
            onSwapped:function(group,from,to) { overview.swapRequested(group,from,to) }
        }
        KitSummary {
            Layout.fillWidth:true
            run:overview.run
            revision:overview.revision
            paged:true
        }
    }
}
