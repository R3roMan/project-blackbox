import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import "../../../../../project-blackbox/native" as Native
import "../../../../../project-blackbox/Demo/ui" as Ui
import "../../../../../project-blackbox/Demo/game/Loadout.js" as Gear
import "../../../../../project-blackbox/Demo/game/Controls.js" as Controls
PlasmoidItem {
    id:applet
    Plasmoid.title:"Project Blackbox"
    Plasmoid.icon:blackboxIcon.toString()
    readonly property url blackboxIcon:Qt.resolvedUrl("../../../../../project-blackbox/runtime/blackbox-desktop.svg")
    readonly property var bindings:Controls.read(Native.Desktop.config.controlBindings)
    readonly property bool activeWallpaper:Native.Desktop.wallpaperActive
    readonly property bool showing:!activeWallpaper || Native.Desktop.config.mode==="play" || !!Native.Desktop.state.idleControls
    property string layoutNotice:""
    onShowingChanged:if (!showing) expanded=false
    onExpandedChanged:if (expanded) Native.Desktop.refreshPanelStyle()
    preferredRepresentation:compactRepresentation
    component PanelButton: Button {
        id:panelButton
        implicitHeight:30
        padding:4
        background:Rectangle {
            radius:4
            color:panelButton.down ? "#232027" : panelButton.hovered ? "#151418" : "#09090a"
            border.color:panelButton.visualFocus ? "#e4d5d7" : "#51464c"
        }
        contentItem:Text {
            text:panelButton.text
            color:panelButton.enabled ? "#ebe5e7" : "#90868a"
            font:panelButton.font
            horizontalAlignment:Text.AlignHCenter
            verticalAlignment:Text.AlignVCenter
        }
    }
    compactRepresentation:RowLayout {
        id:panelControls
        opacity:applet.showing ? 1 : 0
        enabled:applet.showing
        Behavior on opacity {NumberAnimation {duration:220}}
        spacing:3
        PanelButton {
            id:badge
            objectName:"blackboxPanelBadge"
            text:applet.activeWallpaper && Native.Desktop.config.mode==="play" && Native.Desktop.state.wave ? "BLACKBOX · "+Native.Desktop.state.wave : "BLACKBOX"
            Accessible.name:"Project Blackbox"
            onClicked:applet.expanded=!applet.expanded
            contentItem:RowLayout {
                spacing:4
                Image {source:applet.blackboxIcon;Layout.preferredWidth:21;Layout.preferredHeight:21;fillMode:Image.PreserveAspectFit}
                Text {text:badge.text;color:"#f2eaed";font.pixelSize:12;font.bold:true}
            }
        }
        Repeater {
            model:applet.activeWallpaper && Native.Desktop.config.mode==="play" ? Native.Desktop.state.actives || [] : []
            PanelButton {
                required property int index
                required property var modelData
                text:Controls.label(applet.bindings,index ? "active2" : "active1")+(modelData.cooldown>0 ? " "+Math.ceil(modelData.cooldown) : "")
                enabled:!!modelData.id && Native.Desktop.atHome && Native.Desktop.state.phase==="combat" && !Native.Desktop.state.paused && modelData.cooldown<=0
                implicitWidth:34
                implicitHeight:26
                Layout.maximumHeight:Math.max(16,panelControls.height)
                contentItem:Item {
                    Ui.GalleryPortrait {anchors.fill:parent;visible:!!modelData.id;entry:Gear.activeAbilities[modelData.id] || Gear.activeAbilities.shock;tint:Gear.rarities[Gear.activeAbilities[modelData.id]?.rarity || "common"].color}
                    Text {anchors.left:parent.left;anchors.top:parent.top;text:Controls.label(applet.bindings,index ? "active2" : "active1");color:"white";font.pixelSize:Math.max(7,Math.min(11,31/(Math.max(1,text.length)*.55)));font.bold:true;style:Text.Outline;styleColor:"black"}
                    Text {anchors.centerIn:parent;text:modelData.cooldown>0 ? Math.ceil(modelData.cooldown) : "";color:"white";font.bold:true;style:Text.Outline;styleColor:"black"}
                }
                ToolTip.visible:hovered;ToolTip.text:modelData.title
                onClicked:Native.Desktop.command(index ? "e" : "q")
                Rectangle {anchors.bottom:parent.bottom;height:2;width:parent.width*(1-modelData.cooldown/modelData.duration);color:"white"}
            }
        }
        PanelButton {
            text:"Ⅱ"
            Accessible.name:"Pause Blackbox"
            visible:applet.activeWallpaper && Native.Desktop.config.mode==="play"
            onClicked:Native.Desktop.command("pause")
        }
    }
    fullRepresentation:ColumnLayout {
        Layout.minimumWidth:350;Layout.preferredWidth:440;Layout.minimumHeight:385
        Rectangle {
            Layout.fillWidth:true;implicitHeight:42;radius:5;color:"#09090a";border.color:"#51464c"
            RowLayout {
                anchors.fill:parent;anchors.margins:7;spacing:8
                Image {source:applet.blackboxIcon;Layout.preferredWidth:29;Layout.preferredHeight:29;fillMode:Image.PreserveAspectFit}
                Text {Layout.fillWidth:true;text:"PROJECT BLACKBOX";color:"#f2eaed";font.pixelSize:20;font.bold:true}
            }
        }
        Label {Layout.fillWidth:true;visible:!applet.activeWallpaper;text:"Blackbox uses this KDE desktop, its apps and panel widgets.";wrapMode:Text.WordWrap}
        Button {
            objectName:"useKdeLayout"
            Layout.fillWidth:true
            visible:!applet.activeWallpaper
            text:"Use my KDE layout"
            onClicked:{
                const opened=Native.Desktop.useKdeLayout(Qt.resolvedUrl("../../../../../project-blackbox/runtime/desktop-session.py"))
                applet.layoutNotice=opened ? "Opening Blackbox on this Activity…" : "Could not open Blackbox. Select its wallpaper in KDE’s Desktop and Wallpaper settings."
            }
        }
        Label {Layout.fillWidth:true;visible:!applet.activeWallpaper && text.length>0;text:applet.layoutNotice;wrapMode:Text.WordWrap}
        Label {Layout.fillWidth:true;text:Native.Desktop.sessionLocked ? "Session locked" : Native.Desktop.visibilityReady
            ? (Native.Desktop.atHome ? "Desktop active" : Native.Desktop.config.backgroundPlay ? "Background play enabled" : "Paused while using another app")
            : "Enable Blackbox visibility in KWin Scripts";visible:applet.activeWallpaper;wrapMode:Text.WordWrap}
        Label {visible:applet.activeWallpaper;text:"Wave "+(Native.Desktop.state.wave || 0)+" · "+(Native.Desktop.state.hp || 200)+" / "+(Native.Desktop.state.maxHp || 200)+" HP"}
        Label {text:Native.Desktop.state.renderer || "";visible:applet.activeWallpaper && text.length>0}
        ComboBox {Layout.fillWidth:true;visible:applet.activeWallpaper;model:["Idle","Play"];currentIndex:Native.Desktop.config.mode==="play" ? 1 : 0;onActivated:Native.Desktop.setOption("mode",currentIndex ? "play" : "idle")}
        RowLayout {
            visible:applet.activeWallpaper
            Button {text:"New run";onClicked:Native.Desktop.command("new")}
            Button {text:Native.Desktop.config.mode!=="play" ? "Back to Play" : Native.Desktop.state.phase==="ready" || Native.Desktop.state.phase==="between" ? "Begin wave" : "Resume"
                onClicked:{Native.Desktop.command(Native.Desktop.config.mode!=="play" ? "play" : Native.Desktop.state.phase==="ready" || Native.Desktop.state.phase==="between" ? "begin" : "resume");applet.expanded=false}}
            Button {text:"Loadout";onClicked:Native.Desktop.command("loadout")}
        }
        RowLayout {
            visible:applet.activeWallpaper
            Button {text:Native.Desktop.state.saveStatus || "Save";onClicked:Native.Desktop.command("save")}
            Button {text:"Continue";enabled:Native.Desktop.hasSave;onClicked:Native.Desktop.command("continue")}
            Button {text:"Settings";onClicked:{Native.Desktop.command("settings");applet.expanded=false}}
            Button {text:"Grimoire";onClicked:{Native.Desktop.command("grimoire");applet.expanded=false}}
        }
        Button {
            objectName:"darkPanelStyle"
            Layout.fillWidth:true
            enabled:!Native.Desktop.panelStyleBusy
            text:Native.Desktop.panelStyleBusy ? "Changing Plasma style…" : Native.Desktop.darkPanel ? "Restore previous Plasma style" : "Use Blackbox dark panel style"
            onClicked:Native.Desktop.setDarkPanel(!Native.Desktop.darkPanel)
        }
        Label {Layout.fillWidth:true;wrapMode:Text.WordWrap;text:Native.Desktop.panelStyleNotice || "Applies to Plasma panels and widgets. Your apps keep their own appearance."}
        Label {visible:applet.activeWallpaper;text:"CPU "+Math.round(Native.Desktop.cpu*100)+"% · GPU "+(Native.Desktop.gpu<0 ? "unavailable" : Math.round(Native.Desktop.gpu*100)+"%")}
        Label {visible:applet.activeWallpaper;text:Native.Desktop.audioStatus;wrapMode:Text.WordWrap;Layout.fillWidth:true}
        Item {Layout.fillHeight:true}
    }
}
