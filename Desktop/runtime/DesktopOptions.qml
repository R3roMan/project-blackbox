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
        CheckBox {text:"CPU heat replaces ammunition";checked:Native.Desktop.config.cpuAmmo;onClicked:Native.Desktop.setOption("cpuAmmo",checked)}
        Label {Layout.fillWidth:true;text:"Shots raise virtual heat. Real CPU use is its floor; after reaching 100%, let it cool. Turn off for ordinary magazines.";wrapMode:Text.WordWrap}
        CheckBox {text:"Respond to GPU load";checked:Native.Desktop.config.gpuEffects;onClicked:Native.Desktop.setOption("gpuEffects",checked)}
        Label {Layout.fillWidth:true;text:"Reads GPU use and lowers rendering detail under load. Demon hits add a virtual pressure meter; hardware settings stay under your control.";wrapMode:Text.WordWrap}
        CheckBox {text:"React to speaker output";checked:Native.Desktop.config.musicReactive;onClicked:Native.Desktop.setOption("musicReactive",checked)}
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
        Label {text:"Game screen name · blank uses the first Blackbox desktop"}
        TextField {Layout.fillWidth:true;text:Native.Desktop.config.screenName;placeholderText:"e.g. DP-1";onEditingFinished:Native.Desktop.setOption("screenName",text)}
        Button {text:"Save current run";onClicked:Native.Desktop.command("save")}
        Button {text:"Continue saved run";enabled:Native.Desktop.hasSave;onClicked:Native.Desktop.command("continue")}
        Label {Layout.fillWidth:true;text:"No system services, network settings or KDE components are replaced. Remove the Blackbox packages to return to your usual setup.";wrapMode:Text.WordWrap}
    }
    FileDialog {id:imagePicker;title:"Choose wallpaper";fileMode:FileDialog.OpenFile;nameFilters:["Images (*.png *.jpg *.jpeg *.webp)"];onAccepted:Native.Desktop.setOption("wallpaper_"+settings.choosing,String(selectedFile))}
}
