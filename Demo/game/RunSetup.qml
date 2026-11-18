import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui

ColumnLayout {
    id: setup
    required property string difficulty
    required property int startAt
    required property string build
    required property bool unlockAll
    property bool bloodMoon:false
    signal practiceWeatherRequested(bool enabled)
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
    CheckBox {
        property bool practice:setup.debugEnabled
        visible:practice
        objectName:"debugBloodMoon"
        text:"Blood Moon practice"
        checked:setup.bloodMoon
        palette.windowText:"#f1ccd2"
        onToggled:setup.practiceWeatherRequested(checked)
    }
}
