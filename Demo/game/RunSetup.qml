import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear

ColumnLayout {
    id: setup
    required property string difficulty
    required property int startAt
    required property string build
    required property bool unlockAll
    property string debugWeapon:"pistol"
    signal debugWeaponRequested(string id)
    property bool bloodMoon:false
    property string weatherLayer:""
    property bool unlimitedMoney:false
    signal moneyRequested(bool enabled)
    signal practiceWeatherRequested(bool enabled)
    signal weatherLayerRequested(string layer)
    signal unlocksRequested(bool enabled)
    signal configurationChanged(string difficulty, int startAt, string build)
    readonly property bool debugEnabled: startAt > 1
    spacing: 7

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: ["Normal", "Hard", "Insane"]
            Ui.ActionButton {
                required property string modelData
                objectName: "difficulty-" + modelData.toLowerCase()
                text: modelData
                primary: setup.difficulty === modelData.toLowerCase()
                onClicked: setup.configurationChanged(modelData.toLowerCase(), setup.startAt, setup.build)
            }
        }
        Item { Layout.fillWidth: true }
        Ui.ActionButton {
            objectName: "enableDebug"
            text: "Debug"
            primary: setup.debugEnabled
            checkable: true
            checked: setup.debugEnabled
            onClicked: setup.configurationChanged(setup.difficulty, setup.debugEnabled ? 1 : 10, "standard")
        }
        Label {color:"#e4d5e0"; text: "Wave"; visible: setup.debugEnabled }
        SpinBox {
            objectName: "debugStart"
            visible: setup.debugEnabled
            from: 10
            to: 150
            stepSize: 10
            editable:true
            validator:IntValidator {bottom:10; top:150}
            valueFromText:function(text) {return Math.max(10,Math.min(150,Math.round(Number(text)/10)*10))}
            value: Math.max(10, setup.startAt)
            Accessible.name: "Debug starting wave"
            onValueModified: setup.configurationChanged(setup.difficulty, value, setup.build)
        }
    }
    RowLayout {
        visible: setup.debugEnabled
        spacing: 6
        Label {color:"#e4d5e0"; text: "Build" }
        Repeater {
            model: [{id:"standard", label:"Standard"}, {id:"random", label:"Scaled random"}, {id:"star", label:"Star Destroyer+"}]
            Ui.ActionButton {
                required property var modelData
                objectName: "debugBuild-" + modelData.id
                text: modelData.label
                primary: setup.build === modelData.id
                onClicked: setup.configurationChanged(setup.difficulty, setup.startAt, modelData.id)
            }
        }
        Item { Layout.fillWidth: true }
        CheckBox {
            palette.windowText:"#e4d5e0"
            palette.text:"#e4d5e0"
            objectName: "debugUnlockAll"
            checked: setup.unlockAll
            text: "Unlock all gear"
            onToggled: setup.unlocksRequested(checked)
        }
    }
    ComboBox {
        id:weaponPicker
        objectName:"debugStartingWeapon"
        visible:setup.debugEnabled
        Layout.fillWidth:true
        model:Object.values(Gear.weapons).sort((a,b)=>a.title.localeCompare(b.title))
        textRole:"title";valueRole:"id"
        currentIndex:setup.build==="custom" ? indexOfValue(setup.debugWeapon) : -1
        displayText:currentIndex<0 ? "Choose any starting weapon" : currentText
        Accessible.name:"Choose any debug starting weapon"
        onActivated:setup.debugWeaponRequested(currentValue)
    }
    RowLayout {
        visible:setup.debugEnabled
        CheckBox {
            objectName:"debugBloodMoon"
            text:"Blood Moon practice"
            checked:setup.bloodMoon
            palette.windowText:"#f1ccd2"
            onToggled:setup.practiceWeatherRequested(checked)
        }
        CheckBox {
            objectName:"debugMoney"
            text:"Infinite gold"
            checked:setup.unlimitedMoney
            palette.windowText:"#e4d5e0"
            onToggled:setup.moneyRequested(checked)
        }
        ComboBox {
            objectName:"debugWeatherLayer"
            property var options:["","clear","fog","thunder","rain","winter","inferno","incursion","meteor","windy","glitch","cloudy","heatwave","windyCloudy"]
            model:["Random weather","Clear","Fog","Thunderstorm","Rain","Winter","Inferno","Abyssal Takeover","Meteor shower","High winds","Glitch","Cloudy","Heatwave","High winds + Cloudy"]
            currentIndex:Math.max(0,options.indexOf(setup.weatherLayer))
            Accessible.name:"Debug weather overlay"
            onActivated:setup.weatherLayerRequested(options[currentIndex])
        }
    }
}
