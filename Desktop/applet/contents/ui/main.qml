import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "../../../../../project-blackbox/native" as Native
import "../../../../../project-blackbox/Demo/ui" as Ui
import "../../../../../project-blackbox/Demo/game/Loadout.js" as Gear
PlasmoidItem {
    id:applet
    Plasmoid.title:"Blackbox"
    preferredRepresentation:compactRepresentation
    compactRepresentation:RowLayout {
        spacing:3
        Button {text:Native.Desktop.state.wave ? "BB · "+Native.Desktop.state.wave : "BLACKBOX";onClicked:applet.expanded=!applet.expanded}
        Repeater {
            model:Native.Desktop.state.actives || []
            Button {
                required property int index
                required property var modelData
                text:(index ? "E" : "Q")+(modelData.cooldown>0 ? " "+Math.ceil(modelData.cooldown) : "")
                enabled:!!modelData.id && Native.Desktop.atHome && Native.Desktop.state.phase==="combat" && !Native.Desktop.state.paused && modelData.cooldown<=0
                implicitWidth:43
                implicitHeight:43
                contentItem:Item {
                    Ui.GalleryPortrait {anchors.fill:parent;visible:!!modelData.id;entry:Gear.activeAbilities[modelData.id] || Gear.activeAbilities.shock;tint:Gear.rarities[Gear.activeAbilities[modelData.id]?.rarity || "common"].color}
                    Text {anchors.left:parent.left;anchors.top:parent.top;text:index ? "E" : "Q";color:"white";font.pixelSize:11;font.bold:true;style:Text.Outline;styleColor:"black"}
                    Text {anchors.centerIn:parent;text:modelData.cooldown>0 ? Math.ceil(modelData.cooldown) : "";color:"white";font.bold:true;style:Text.Outline;styleColor:"black"}
                }
                ToolTip.visible:hovered;ToolTip.text:modelData.title
                onClicked:Native.Desktop.command(index ? "e" : "q")
                Rectangle {anchors.bottom:parent.bottom;height:2;width:parent.width*(1-modelData.cooldown/modelData.duration);color:"white"}
            }
        }
        Button {text:"Ⅱ";onClicked:Native.Desktop.command("pause")}
    }
    fullRepresentation:ColumnLayout {
        Layout.minimumWidth:350;Layout.preferredWidth:440;Layout.minimumHeight:380
        Text {text:"PROJECT BLACKBOX";color:"#f0cdac";font.pixelSize:22;font.bold:true}
        Label {Layout.fillWidth:true;text:Native.Desktop.visibilityReady ? (Native.Desktop.atHome ? "Desktop active" : "Paused while using another app") : "Enable Blackbox visibility in KWin Scripts";wrapMode:Text.WordWrap}
        Label {text:"Wave "+(Native.Desktop.state.wave || 0)+" · "+(Native.Desktop.state.hp || 200)+" / "+(Native.Desktop.state.maxHp || 200)+" HP"}
        Label {text:Native.Desktop.state.renderer || ""; visible:text.length>0}
        ComboBox {Layout.fillWidth:true;model:["Idle","Play","Performance","XD"];currentIndex:["idle","play","performance","xd"].indexOf(Native.Desktop.config.mode);onActivated:Native.Desktop.setOption("mode",["idle","play","performance","xd"][currentIndex])}
        RowLayout {
            Button {text:"New run";onClicked:Native.Desktop.command("new")}
            Button {text:Native.Desktop.state.phase==="ready" || Native.Desktop.state.phase==="between" ? "Begin wave" : "Resume";onClicked:Native.Desktop.command(Native.Desktop.state.phase==="ready" || Native.Desktop.state.phase==="between" ? "begin" : "resume")}
            Button {text:"Loadout";onClicked:Native.Desktop.command("loadout")}
        }
        RowLayout {
            Button {text:Native.Desktop.state.saveStatus || "Save";onClicked:Native.Desktop.command("save")}
            Button {text:"Continue";enabled:Native.Desktop.hasSave;onClicked:Native.Desktop.command("continue")}
            Button {text:"Settings";onClicked:Native.Desktop.command("settings")}
        }
        Label {text:"CPU "+Math.round(Native.Desktop.cpu*100)+"% · GPU "+(Native.Desktop.gpu<0 ? "unavailable" : Math.round(Native.Desktop.gpu*100)+"%")}
        Label {text:Native.Desktop.audioStatus;wrapMode:Text.WordWrap;Layout.fillWidth:true}
        Item {Layout.fillHeight:true}
    }
}
