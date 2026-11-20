import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import "../../../../../project-blackbox/native" as Native
import "../../../../../project-blackbox/Demo/ui" as Ui
import "../../../../../project-blackbox/runtime" as Runtime
PlasmoidItem {
    id:applet
    Plasmoid.title:"Project Blackbox"
    Plasmoid.icon:blackboxIcon.toString()
    readonly property url blackboxIcon:Qt.resolvedUrl("../../../../../project-blackbox/runtime/blackbox-desktop.svg")
    readonly property bool activeWallpaper:Native.Desktop.wallpaperActive
    readonly property bool showing:!activeWallpaper || Native.Desktop.config.mode==="play" || !!Native.Desktop.state.idleControls || !!Native.Desktop.config.petAdmin
    property string layoutNotice:""
    onShowingChanged:if (!showing) expanded=false
    onExpandedChanged:if (expanded) Native.Desktop.refreshPanelStyle()
    Binding {target:Ui.InterfaceTheme;property:"selection";value:Native.Desktop.config.interfaceTheme}
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
            text:"BX"
            Accessible.name:"Project Blackbox"
            onClicked:applet.expanded=!applet.expanded
            contentItem:RowLayout {
                spacing:4
                Image {source:applet.blackboxIcon;Layout.preferredWidth:21;Layout.preferredHeight:21;fillMode:Image.PreserveAspectFit}
                Text {text:badge.text;color:"#f2eaed";font.pixelSize:12;font.bold:true}
            }
        }
    }
    fullRepresentation: Item {
        id:popup
        objectName:"blackboxPanelMenu"
        Layout.minimumWidth:356
        Layout.preferredWidth:400
        Layout.minimumHeight:335
        Layout.preferredHeight:346
        property bool appearance:false
        readonly property var style:Ui.InterfaceTheme.style(Native.Desktop.config.interfaceTheme)
        readonly property bool activePlay:Native.Desktop.config.mode==="play"
        // Native KDE controls inherit these popup colours.
        palette.window:style.base
        palette.base:style.slot
        palette.button:style.surface
        palette.text:Ui.InterfaceTheme.text
        palette.windowText:Ui.InterfaceTheme.text
        palette.buttonText:Ui.InterfaceTheme.text
        palette.highlight:style.accent
        palette.highlightedText:"#22141c"

        Ui.ShrineFrame {anchors.fill:parent;style:popup.style;decorated:true;blood:.61}
        ColumnLayout {
            anchors.fill:parent
            anchors.margins:13
            spacing:9
            RowLayout {
                Layout.fillWidth:true
                spacing:8
                Image {source:applet.blackboxIcon;Layout.preferredWidth:28;Layout.preferredHeight:28;fillMode:Image.PreserveAspectFit}
                Text {
                    text:"Blackbox"
                    Layout.fillWidth:true
                    color:Ui.InterfaceTheme.text
                    font.family:popup.style.serif ? "Noto Serif" : "Inter"
                    font.pixelSize:21
                    font.bold:true
                }
                Text {
                    visible:applet.activeWallpaper
                    text:popup.activePlay ? (Native.Desktop.state.wave ? "Wave "+Native.Desktop.state.wave : "Play") : "Idle"
                    color:popup.style.accent
                    font.pixelSize:12
                    font.bold:true
                }
            }
            RowLayout {
                Layout.fillWidth:true
                Ui.ActionButton {Layout.fillWidth:true;objectName:"bxDesktopTab";text:"Desktop";primary:!popup.appearance;accent:popup.style.accent;onClicked:popup.appearance=false}
                Ui.ActionButton {Layout.fillWidth:true;objectName:"bxAppearanceTab";text:"Appearance";primary:popup.appearance;accent:popup.style.accent;onClicked:popup.appearance=true}
            }
            Rectangle {Layout.fillWidth:true;implicitHeight:1;color:popup.style.line}
            ScrollView {
                id:appScroll
                Layout.fillWidth:true
                Layout.fillHeight:true
                clip:true
                contentWidth:availableWidth
                ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
                StackLayout {
                    width:appScroll.availableWidth
                    currentIndex:popup.appearance ? 1 : 0
                    ColumnLayout {
                        spacing:8
                        Text {
                            Layout.fillWidth:true
                            visible:applet.activeWallpaper
                            text:Native.Desktop.sessionLocked ? "Session locked" : !Native.Desktop.visibilityReady
                                ? "Enable Blackbox visibility in KWin Scripts" : popup.activePlay
                                ? (Native.Desktop.state.paused ? "Expedition paused" : "Expedition running") : "Ctrl + arrow or mouse edge to turn"
                            color:Ui.InterfaceTheme.secondary
                            wrapMode:Text.WordWrap
                        }
                        Ui.ActionButton {
                            objectName:"useKdeLayout"
                            Layout.fillWidth:true
                            visible:!applet.activeWallpaper
                            text:"Use my KDE layout"
                            onClicked:{
                                const opened=Native.Desktop.useKdeLayout(Qt.resolvedUrl("../../../../../project-blackbox/runtime/desktop-session.py"))
                                applet.layoutNotice=opened ? "Opening Blackbox on this Activity…" : "Select Blackbox in KDE’s Desktop and Wallpaper settings."
                            }
                        }
                        Switch {
                            objectName:"petAdminBx"
                            Layout.fillWidth:true
                            visible:applet.activeWallpaper
                            text:"Pet admin"
                            checked:Native.Desktop.config.petAdmin
                            onToggled:Native.Desktop.setOption("petAdmin",checked)
                        }
                        Runtime.PetMood {
                            Layout.fillWidth:true
                            visible:applet.activeWallpaper && Native.Desktop.config.idlePet
                            mood:Native.Desktop.state.petMood ?? .5
                            name:Native.Desktop.state.petName || "Pet"
                        }
                        Ui.ActionButton {
                            Layout.fillWidth:true
                            visible:applet.activeWallpaper && Native.Desktop.config.petAdmin
                            text:"Pet terminal · Ctrl+P"
                            onClicked:{Native.Desktop.command("pet-console");applet.expanded=false}
                        }
                        Label {Layout.fillWidth:true;visible:!applet.activeWallpaper && text.length>0;text:applet.layoutNotice;wrapMode:Text.WordWrap}
                        Ui.ActionButton {
                            Layout.fillWidth:true
                            visible:applet.activeWallpaper
                            primary:true
                            accent:popup.style.accent
                            text:!popup.activePlay ? "Back to Play" : ["ready","between"].includes(Native.Desktop.state.phase) && !Native.Desktop.state.paused ? "Begin wave" : "Resume"
                            onClicked:{
                                Native.Desktop.command(!popup.activePlay ? "play" : text==="Begin wave" ? "begin" : "resume")
                                applet.expanded=false
                            }
                        }
                        GridLayout {
                            Layout.fillWidth:true
                            visible:applet.activeWallpaper
                            columns:2
                            uniformCellWidths:true
                            Ui.ActionButton {Layout.fillWidth:true;text:"New run";onClicked:{Native.Desktop.command("new");applet.expanded=false}}
                            Ui.ActionButton {Layout.fillWidth:true;text:"Continue";enabled:Native.Desktop.hasSave;onClicked:{Native.Desktop.command("continue");applet.expanded=false}}
                            Ui.ActionButton {
                                Layout.fillWidth:true
                                text:popup.activePlay ? "Return to Idle" : "Settings"
                                onClicked:{
                                    if (popup.activePlay) Native.Desktop.setOption("mode","idle")
                                    else Native.Desktop.command("settings")
                                    applet.expanded=false
                                }
                            }
                            Ui.ActionButton {Layout.fillWidth:true;text:"Room overview";onClicked:{Native.Desktop.command("overview");applet.expanded=false}}
                            Ui.ActionButton {Layout.fillWidth:true;text:"Grimoire";onClicked:{Native.Desktop.command("grimoire");applet.expanded=false}}
                            Ui.ActionButton {Layout.fillWidth:true;visible:popup.activePlay;text:"Loadout";onClicked:{Native.Desktop.command("loadout");applet.expanded=false}}
                            Ui.ActionButton {Layout.fillWidth:true;visible:popup.activePlay;text:Native.Desktop.state.saveStatus || "Save run";onClicked:Native.Desktop.command("save")}
                        }
                    }
                    ColumnLayout {
                        spacing:8
                        Label {text:"Blackbox theme";font.bold:true;color:Ui.InterfaceTheme.text}
                        Ui.ThemeChooser {
                            Layout.fillWidth:true
                            selection:Native.Desktop.config.interfaceTheme
                            onThemeRequested:key=>Native.Desktop.setOption("interfaceTheme",key)
                        }
                        Label {text:"KDE appearance";font.bold:true;color:Ui.InterfaceTheme.text}
                        Ui.ActionButton {
                            objectName:"darkPanelStyle"
                            Layout.fillWidth:true
                            enabled:!Native.Desktop.panelStyleBusy
                            text:Native.Desktop.darkPanel ? "Restore Plasma style" : "Use dark Plasma style"
                            onClicked:Native.Desktop.setDarkPanel(!Native.Desktop.darkPanel)
                        }
                        Ui.ActionButton {
                            objectName:"darkAppColors"
                            Layout.fillWidth:true
                            enabled:!Native.Desktop.panelStyleBusy
                            text:Native.Desktop.darkApps ? "Restore KDE app colours" : "Use dark KDE app colours"
                            onClicked:Native.Desktop.setDarkApps(!Native.Desktop.darkApps)
                        }
                        Label {Layout.fillWidth:true;text:Native.Desktop.panelStyleNotice;visible:text.length>0;wrapMode:Text.WordWrap}
                        RowLayout {
                            Layout.fillWidth:true
                            Ui.ActionButton {Layout.fillWidth:true;text:"Night Light";onClicked:Native.Desktop.openDisplaySettings(false)}
                            Ui.ActionButton {Layout.fillWidth:true;text:"Displays and HDR";onClicked:Native.Desktop.openDisplaySettings(true)}
                        }
                    }
                }
            }
        }
    }
}
