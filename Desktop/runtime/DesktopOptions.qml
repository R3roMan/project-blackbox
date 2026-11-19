import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../native" as Native
import "../Demo/ui" as Ui

ScrollView {
    id:settings
    contentWidth:availableWidth;clip:true
    property string choosing:"front"
    property int initialDetail:1
    Component.onCompleted:initialDetail=Native.Desktop.config.detail
    ColumnLayout {
        width:settings.availableWidth;spacing:13
        Label {text:"BLACKBOX DESKTOP";font.pixelSize:23;font.bold:true}
        Label {Layout.fillWidth:true;text:"Changes apply immediately and are saved in Blackbox's own settings.";wrapMode:Text.WordWrap}
        Label {text:"Mode"}
        ComboBox {Layout.fillWidth:true;model:["Idle","Play"];currentIndex:Native.Desktop.config.mode==="play" ? 1 : 0;onActivated:Native.Desktop.setOption("mode",currentIndex ? "play" : "idle")}
        CheckBox {text:"Keep battles running behind other apps";checked:Native.Desktop.config.backgroundPlay;onClicked:Native.Desktop.setOption("backgroundPlay",checked)}
        CheckBox {text:"Use a KDE virtual desktop for each wallpaper";checked:Native.Desktop.config.linkDesktops
            onClicked:Native.Desktop.setOption("linkDesktops",checked)}
        Label {Layout.fillWidth:true;wrapMode:Text.WordWrap;text:"Creates five named Blackbox virtual desktops when first enabled. Your existing virtual desktops stay available."}
        CheckBox {text:"CPU heat replaces ammunition";checked:Native.Desktop.config.cpuAmmo;onClicked:Native.Desktop.setOption("cpuAmmo",checked)}
        Label {Layout.fillWidth:true;text:"Shots raise virtual heat. CPU load lifts the starting heat. At 100%, let the circle cool to 45%. Turn off for ordinary magazines.";wrapMode:Text.WordWrap}
        CheckBox {text:"Respond to GPU load";checked:Native.Desktop.config.gpuEffects;onClicked:Native.Desktop.setOption("gpuEffects",checked)}
        Label {Layout.fillWidth:true;text:"Shows GPU load and pressure from demon hits in a separate ring. Sustained pressure steps down graphics detail.";wrapMode:Text.WordWrap}
        CheckBox {text:"Use speaker output to vary enemy lineups";checked:Native.Desktop.config.musicReactive;onClicked:Native.Desktop.setOption("musicReactive",checked)}
        Label {Layout.fillWidth:true;text:Native.Desktop.audioStatus;wrapMode:Text.WordWrap}
        TextField {Layout.fillWidth:true;placeholderText:"Optional PipeWire output node name";text:Native.Desktop.config.audioTarget;onEditingFinished:Native.Desktop.setOption("audioTarget",text)}
        Label {text:"Frame limit"}
        SpinBox {from:20;to:240;editable:true;value:Native.Desktop.config.frameLimit;onValueModified:Native.Desktop.setOption("frameLimit",value)}
        Label {text:"3D quality"}
        ComboBox {model:["Low","Standard","High","Ultra"];currentIndex:Native.Desktop.config.detail;onActivated:Native.Desktop.setOption("detail",currentIndex)}
        Label {
            visible:Native.Desktop.config.detail!==settings.initialDetail
            Layout.fillWidth:true
            wrapMode:Text.WordWrap
            text:"Save the run and restart the preview or reload the wallpaper to fully apply this preset."
        }
        Label {text:"Combat HUD size"}
        ComboBox {
            model:["80%","100%","115%","130%"]
            readonly property var scales:[.8,1,1.15,1.3]
            currentIndex:Math.max(0,scales.indexOf(Native.Desktop.config.hudScale))
            onActivated:Native.Desktop.setOption("hudScale",scales[currentIndex])
        }
        Label {text:"Text size"}
        ComboBox {
            model:["100%","115%","130%","145%"]
            readonly property var scales:[1,1.15,1.3,1.45]
            currentIndex:Math.max(0,scales.indexOf(Native.Desktop.config.textScale))
            onActivated:Native.Desktop.setOption("textScale",scales[currentIndex])
        }
        CheckBox {text:"Save at wave checkpoints";checked:Native.Desktop.config.autoSave;onClicked:Native.Desktop.setOption("autoSave",checked)}
        Ui.AudioSettings {
            levels:Native.Desktop.config
            Layout.fillWidth:true
            onLevelRequested:function(key,value){Native.Desktop.setOption(key,value)}
        }
        CheckBox {text:"Animation";checked:Native.Desktop.config.motion;onClicked:Native.Desktop.setOption("motion",checked)}
        CheckBox {text:"Show wave timer";checked:Native.Desktop.config.showTimer;onClicked:Native.Desktop.setOption("showTimer",checked)}
        Label {text:"Backgrounds · your original files stay where they are";font.bold:true}
        Repeater {
            model:[{id:"front",title:"Shrine"},{id:"left",title:"West"},{id:"right",title:"Droid lab"},{id:"up",title:"Sky"},{id:"down",title:"Abyss"}]
            RowLayout {
                required property var modelData
                Layout.fillWidth:true
                Label {text:modelData.title;Layout.preferredWidth:85}
                Button {text:"Choose image…";onClicked:{settings.choosing=modelData.id;imagePicker.open()}}
                Button {text:"Reset";onClicked:Native.Desktop.setOption("wallpaper_"+modelData.id,"")}
            }
        }
        Label {text:"Game monitor"}
        ComboBox {
            Layout.fillWidth:true
            readonly property var names:[""].concat(Array.from(Native.Desktop.screens))
            model:names.map(name=>name || "Automatic")
            currentIndex:Math.max(0,names.indexOf(Native.Desktop.config.screenName))
            onActivated:Native.Desktop.setOption("screenName",names[currentIndex])
        }
        Button {text:"Save current run";onClicked:Native.Desktop.command("save")}
        Button {text:"Continue saved run";enabled:Native.Desktop.hasSave;onClicked:Native.Desktop.command("continue")}
        Button {text:"Return to KDE desktop";onClicked:Native.Desktop.command("revert")}
        Label {Layout.fillWidth:true;text:"Saves the run and restores the previous wallpaper. The Project Blackbox shortcut on your desktop opens it again.";wrapMode:Text.WordWrap}
    }
    FileDialog {id:imagePicker;title:"Choose wallpaper";fileMode:FileDialog.OpenFile;nameFilters:["Images (*.png *.jpg *.jpeg *.webp)"];onAccepted:Native.Desktop.setOption("wallpaper_"+settings.choosing,String(selectedFile))}
}
