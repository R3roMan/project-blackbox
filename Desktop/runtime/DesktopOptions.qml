import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../native" as Native
import "../Demo/ui" as Ui

Item {
    id:settings
    objectName:"desktopSettings"
    signal closeRequested()
    readonly property var options:Native.Desktop.config
    readonly property var sections:["Desktop","Gameplay","Controls","Display","Audio","Images"]
    property int section:0
    property string choosing:"front"
    property int initialDetail:options.detail
    readonly property color foreground:"#f6e9e5"
    readonly property color secondary:"#c9b9c5"
    readonly property color accent:Ui.InterfaceTheme.current.accent
    readonly property int inset:width<400 ? 14 : 22

    function set(key,value) {Native.Desktop.setOption(key,value)}

    Ui.ShrineFrame {anchors.fill:parent;decorated:true;blood:.43}
    ColumnLayout {
        anchors.fill:parent
        spacing:0
        ColumnLayout {
            Layout.fillWidth:true
            Layout.margins:settings.inset
            spacing:12
            RowLayout {
                Layout.fillWidth:true
                Text {
                    Layout.fillWidth:true
                    text:"Desktop settings";color:settings.foreground;wrapMode:Text.Wrap
                    font.family:"Inter";font.pixelSize:Ui.UiMetrics.text(25);font.bold:true
                }
                Ui.ActionButton {text:"Close";objectName:"closeDesktopSettings";onClicked:settings.closeRequested()}
            }
            Flow {
                id:tabRow
                Layout.fillWidth:true
                Layout.preferredHeight:implicitHeight
                spacing:6
                Repeater {
                    model:settings.sections
                    Ui.ActionButton {
                        required property string modelData
                        required property int index
                        objectName:"desktopSettings-"+modelData.toLowerCase()
                        text:modelData
                        primary:settings.section===index
                        onClicked:{
                            settings.section=index
                            scroller.contentItem.contentY=0
                        }
                    }
                }
            }
        }
        Rectangle {Layout.fillWidth:true;implicitHeight:1;color:"#694c60"}
        ScrollView {
            id:scroller
            objectName:"desktopSettingsScroll"
            Layout.fillWidth:true
            Layout.fillHeight:true
            clip:true
            contentWidth:availableWidth
            contentHeight:body.height
            ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
            ScrollBar.vertical:ScrollBar {
                id:scrollBar
                policy:ScrollBar.AsNeeded
                contentItem:Rectangle {implicitWidth:6;radius:3;color:scrollBar.pressed ? "#ffc398" : "#8e6b83"}
            }
            Item {
                id:body
                width:scroller.availableWidth
                height:content.implicitHeight+2*settings.inset
                Loader {
                    id:content
                    anchors.left:parent.left;anchors.right:parent.right
                    anchors.leftMargin:settings.inset
                    anchors.rightMargin:settings.inset+9
                    y:settings.inset
                    sourceComponent:[desktopPage,gameplayPage,controlsPage,displayPage,audioPage,imagesPage][settings.section]
                }
            }
        }
    }

    component Stack: ColumnLayout {spacing:12}
    component Title:Text {
        Layout.fillWidth:true
        color:settings.accent;font.bold:true;font.family:"Inter"
        font.pixelSize:Ui.UiMetrics.text(17)
        wrapMode:Text.Wrap
    }
    component Copy:Text {
        Layout.fillWidth:true
        color:settings.secondary;font.family:"Inter"
        font.pixelSize:Ui.UiMetrics.text(14)
        wrapMode:Text.Wrap
    }
    component Toggle: RowLayout {
        property alias text:caption.text
        property alias checked:control.checked
        signal toggled(bool value)
        Layout.fillWidth:true
        Copy {id:caption;color:settings.foreground}
        Switch {
            id:control
            Accessible.name:caption.text
            onClicked:parent.toggled(checked)
            indicator:Rectangle {
                implicitWidth:44;implicitHeight:25;radius:height/2
                x:control.leftPadding;y:(control.height-height)/2
                color:control.checked ? "#a4695e" : "#382a3b"
                border.color:control.visualFocus ? settings.accent : "#806279"
                Rectangle {
                    x:control.checked ? parent.width-width-3 : 3
                    anchors.verticalCenter:parent.verticalCenter
                    width:17;height:17;radius:height/2
                    color:control.checked ? "#ffe3c7" : "#c4b6c9"
                    Behavior on x {NumberAnimation {duration:140}}
                }
            }
        }
    }
    component Select: ComboBox {
        id:select
        Layout.fillWidth:true
        Layout.minimumWidth:0
        font.pixelSize:Ui.UiMetrics.text(14)
        implicitHeight:Math.max(42,selection.implicitHeight+12)
        popup.popupType:Popup.Item
        popup.width:select.width
        indicator:Text {
            x:select.width-width-12
            anchors.verticalCenter:parent.verticalCenter
            text:select.popup.visible ? "▴" : "▾"
            color:settings.accent;font.pixelSize:Ui.UiMetrics.text(15)
        }
        popup.background:Rectangle {radius:5;color:"#211924";border.color:"#806279"}
        contentItem:Text {
            id:selection
            text:select.displayText
            color:settings.foreground
            font:select.font
            verticalAlignment:Text.AlignVCenter
            wrapMode:Text.Wrap
            leftPadding:10
            rightPadding:30
        }
        background:Rectangle {radius:5;color:"#2b2130";border.color:select.activeFocus ? "#ffc398" : "#806279"}
        delegate:ItemDelegate {
            required property string modelData
            required property int index
            width:select.width
            highlighted:select.highlightedIndex===index
            background:Rectangle {color:parent.highlighted ? "#63445c" : "#2b2130"}
            contentItem:Text {text:modelData;color:settings.foreground;font:select.font;wrapMode:Text.Wrap}
        }
    }

    component NumberField:SpinBox {
        id:number
        Layout.preferredWidth:126
        Layout.maximumWidth:126
        implicitHeight:36
        editable:true
        palette.base:"#2b2130"
        palette.text:settings.foreground
        contentItem:TextInput {
            text:number.textFromValue(number.value,number.locale)
            font:number.font
            color:settings.foreground
            selectionColor:"#996d86"
            horizontalAlignment:Qt.AlignHCenter
            verticalAlignment:Qt.AlignVCenter
            readOnly:!number.editable
            validator:number.validator
            inputMethodHints:number.inputMethodHints
        }
        background:Rectangle {radius:5;color:"#2b2130";border.color:number.activeFocus ? settings.accent : "#806279"}
    }

    Component {
        id:desktopPage
        Stack {
            Title {text:"Mode and Idle scenery"}
            Select {
                objectName:"desktopMode"
                model:["Idle wallpaper","Play mode"]
                currentIndex:settings.options.mode==="play" ? 1 : 0
                onActivated:settings.set("mode",currentIndex ? "play" : "idle")
            }
            RowLayout {
                Layout.fillWidth:true
                Copy {id:phaseLabel;text:"Minutes per Idle lighting phase";color:settings.foreground}
                NumberField {
                    objectName:"idlePhaseMinutes";Accessible.name:phaseLabel.text
                    from:1;to:120;value:settings.options.idlePhaseMinutes
                    onValueModified:settings.set("idlePhaseMinutes",value)
                }
            }
            Copy {text:"Day → Sunset → Night → Sunrise. Each phase has about a 70% chance of weather and a 30% chance of clear skies."}
            RowLayout {
                Layout.fillWidth:true
                Copy {id:idleRateLabel;text:"Idle effects updates per second";color:settings.foreground}
                NumberField {
                    objectName:"idleFps";Accessible.name:idleRateLabel.text
                    from:5;to:30;value:settings.options.idleFps
                    onValueModified:settings.set("idleFps",value)
                }
            }
            Toggle {text:"Safe rendering · use 2D combat and static Idle";checked:settings.options.safeRendering;onToggled:value=>settings.set("safeRendering",value)}
            Toggle {text:"Roaming Idle pet";checked:settings.options.idlePet;onToggled:value=>settings.set("idlePet",value)}
            Ui.ActionButton {Layout.fillWidth:true;text:"Pick another Idle pet";enabled:settings.options.idlePet;onClicked:Native.Desktop.command("idle-pet")}
            Title {text:"KDE workspace integration"}
            Toggle {text:"Show the Blackbox cube when KDE shows the desktop";checked:settings.options.peekOverview;onToggled:value=>settings.set("peekOverview",value)}
            Copy {text:"With background play enabled, use Meta+Ctrl and an arrow to turn Idle from another app. Change these shortcuts in KDE System Settings."}
            Toggle {text:"Link each wallpaper to a KDE virtual desktop";checked:settings.options.linkDesktops;onToggled:value=>settings.set("linkDesktops",value)}
            Toggle {visible:settings.options.linkDesktops;text:"Use only the Blackbox turn animation while linked";checked:settings.options.singleWorkspaceTurn;onToggled:value=>settings.set("singleWorkspaceTurn",value)}
            Copy {text:"Blackbox uses your current KDE panels, apps and widgets. Add tray or panel widgets in KDE’s Edit Mode. Use KDE Activities for separate desktop widget layouts."}
            Ui.ActionButton {Layout.fillWidth:true;text:"KDE Night Light";onClicked:Native.Desktop.openDisplaySettings(false)}
            Ui.ActionButton {Layout.fillWidth:true;text:"KDE displays and HDR";onClicked:Native.Desktop.openDisplaySettings(true)}
            Ui.ActionButton {Layout.fillWidth:true;text:"Return to KDE desktop";onClicked:Native.Desktop.command("revert")}
            Ui.ActionButton {objectName:"resetDesktopSettings";Layout.fillWidth:true;text:"Restore desktop settings";onClicked:resetConfirmation.open()}
            Ui.ActionButton {Layout.fillWidth:true;text:"Report a bug";onClicked:bugReport.open()}
        }
    }
    Ui.BugReport {id:bugReport;scene:settings;context:({host:"Plasma",screen:"desktop settings",mode:settings.options.mode})}
    Component {
        id:gameplayPage
        Stack {
            Title {text:"Wave setup"}
            Toggle {objectName:"showEnemyPreview";text:"Show enemy lineup before waves";checked:settings.options.showEnemyPreview;onToggled:value=>settings.set("showEnemyPreview",value)}
            Copy {text:"Quick start goes straight into Wave 1 after the countdown. Regular runs keep their loadout and reward screens."}
            Toggle {text:"Show wave timer";checked:settings.options.showTimer;onToggled:value=>settings.set("showTimer",value)}
            Toggle {text:"Keep Blackbox running behind other apps";checked:settings.options.backgroundPlay;onToggled:value=>settings.set("backgroundPlay",value)}
            Title {text:"Run checkpoints"}
            Toggle {text:"Save at wave checkpoints";checked:settings.options.autoSave;onToggled:value=>settings.set("autoSave",value)}
            Ui.ActionButton {Layout.fillWidth:true;text:"Save current run";onClicked:Native.Desktop.command("save")}
            Ui.ActionButton {Layout.fillWidth:true;text:"Continue saved run";enabled:Native.Desktop.hasSave;onClicked:{settings.closeRequested();Native.Desktop.command("continue")}}
            Title {text:"Hardware-driven rules"}
            Toggle {text:"Use CPU heat as ammo";checked:settings.options.cpuAmmo;onToggled:value=>settings.set("cpuAmmo",value)}
            Copy {text:"CPU load raises the starting heat. When the meter reaches 100%, let it cool to 45%."}
        }
    }
    Component {
        id:controlsPage
        Stack {
            Toggle {text:"Mouse edge turning";checked:settings.options.mouseTurns;onToggled:value=>settings.set("mouseTurns",value)}
            Copy {text:"In Idle and Performance, hold Ctrl while pressing an arrow or moving to an edge."}
            Ui.FieldStyleOptions {}
            Ui.ControlBindings {
                Layout.fillWidth:true
                value:settings.options.controlBindings
                desktop:true
                wheelSwitch:settings.options.wheelSwitch
                onBindingsRequested:value=>settings.set("controlBindings",value)
                onWheelRequested:value=>settings.set("wheelSwitch",value)
            }
        }
    }
    Component {
        id:displayPage
        Stack {
            Title {text:"Appearance"}
            Ui.ThemeChooser {
                Layout.fillWidth:true
                selection:settings.options.interfaceTheme
                onThemeRequested:key=>settings.set("interfaceTheme",key)
            }
            Title {text:"Graphics"}
            Copy {text:"Wallpaper framing"}
            Select {
                objectName:"desktopWallpaperFraming"
                readonly property var modes:["fill","fit","stretch","16:9"]
                model:["Fill screen","Fit entire image","Stretch","16:9 composition"]
                currentIndex:Math.max(0,modes.indexOf(settings.options.framing))
                onActivated:settings.set("framing",modes[currentIndex])
            }
            Copy {text:"3D quality"}
            Select {model:["Low","Standard","High","Ultra"];currentIndex:settings.options.detail;onActivated:settings.set("detail",currentIndex)}
            Copy {
                visible:settings.options.detail!==settings.initialDetail
                text:"Save the run and restart the preview or reload the wallpaper to fully apply the graphics preset."
            }
            RowLayout {
                Layout.fillWidth:true
                Copy {id:frameLabel;text:"Frame limit";color:settings.foreground}
                NumberField {Accessible.name:frameLabel.text;from:20;to:240;value:settings.options.frameLimit;onValueModified:settings.set("frameLimit",value)}
            }
            Toggle {text:"Animation";checked:settings.options.motion;onToggled:value=>settings.set("motion",value)}
            Toggle {text:"Adapt graphics to GPU load";checked:settings.options.gpuEffects;onToggled:value=>settings.set("gpuEffects",value)}
            Title {text:"Accessibility"}
            Copy {text:"Combat HUD size"}
            Select {
                model:["80%","100%","115%","130%"]
                readonly property var scales:[.8,1,1.15,1.3]
                currentIndex:Math.max(0,scales.indexOf(settings.options.hudScale))
                onActivated:settings.set("hudScale",scales[currentIndex])
            }
            Copy {text:"Text size"}
            Select {
                model:["100%","115%","130%","145%"]
                readonly property var scales:[1,1.15,1.3,1.45]
                currentIndex:Math.max(0,scales.indexOf(settings.options.textScale))
                onActivated:settings.set("textScale",scales[currentIndex])
            }
            Copy {text:"Game monitor"}
            Select {
                readonly property var names:[""].concat(Array.from(Native.Desktop.screens))
                model:names.map(name=>name || "Automatic")
                currentIndex:Math.max(0,names.indexOf(settings.options.screenName))
                onActivated:settings.set("screenName",names[currentIndex])
            }
        }
    }
    Component {
        id:audioPage
        Stack {
            Title {text:"Volume"}
            Ui.AudioSettings {Layout.fillWidth:true;levels:settings.options;onLevelRequested:(key,value)=>settings.set(key,value)}
            Title {text:"Speaker response"}
            Toggle {text:"Vary enemy lineups based on speaker output";checked:settings.options.musicReactive;onToggled:value=>settings.set("musicReactive",value)}
            Copy {text:Native.Desktop.audioStatus}
            TextField {
                Layout.fillWidth:true
                placeholderText:"Optional PipeWire output node"
                text:settings.options.audioTarget
                onEditingFinished:settings.set("audioTarget",text)
            }
        }
    }
    Component {
        id:imagesPage
        Stack {
            Title {text:"Wallpaper images"}
            Repeater {
                model:[{id:"front",title:"Shrine"},{id:"left",title:"West"},{id:"right",title:"Droid Lab"},{id:"up",title:"Star Sky"},{id:"down",title:"Abyss"},{id:"back",title:"Pure Code"},{id:"cube",title:"Blackbox cube backdrop"}]
                ColumnLayout {
                    required property var modelData
                    readonly property string url:settings.options["wallpaper_"+modelData.id] || ""
                    Layout.fillWidth:true
                    Copy {text:parent.modelData.title;color:settings.foreground;font.bold:true}
                    Copy {text:parent.url ? parent.url.replace(/^.*[/]/,"") : "Bundled image";wrapMode:Text.WrapAnywhere}
                    RowLayout {
                        Layout.fillWidth:true
                        Ui.ActionButton {Layout.fillWidth:true;text:"Choose image…";onClicked:{settings.choosing=parent.parent.modelData.id;imagePicker.open()}}
                        Ui.ActionButton {text:"Reset";enabled:!!parent.parent.url;onClicked:settings.set("wallpaper_"+parent.parent.modelData.id,"")}
                    }
                }
            }
            Ui.ActionButton {objectName:"resetWallpaperImages";Layout.fillWidth:true;text:"Restore all default images";onClicked:Native.Desktop.resetOptions(true)}
        }
    }
    Dialog {
        id:resetConfirmation
        parent:settings
        anchors.centerIn:parent
        width:Math.min(settings.width-24,410)
        title:"Restore Blackbox desktop settings?"
        standardButtons:Dialog.RestoreDefaults | Dialog.Cancel
        onReset:{Native.Desktop.resetOptions(false);close()}
        Label {text:"Your runs, progress and images will be kept.";wrapMode:Text.WordWrap}
    }
    FileDialog {
        id:imagePicker
        title:"Choose wallpaper"
        fileMode:FileDialog.OpenFile
        nameFilters:["Images (*.png *.jpg *.jpeg *.webp)"]
        onAccepted:settings.set("wallpaper_"+settings.choosing,String(selectedFile))
    }
}
