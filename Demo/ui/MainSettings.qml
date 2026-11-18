import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game" as Game

Item {
    id:page
    objectName:"mainSettings"
    required property var display
    required property bool sound
    required property bool motion
    property string status:""
    signal displayRequested(string key,var value)
    signal soundRequested()
    signal motionRequested()
    signal exportRequested()
    signal importRequested()
    signal closeRequested()

    Rectangle { anchors.fill:parent; color:"#15101b" }
    Shortcut { sequence:"Escape"; onActivated:page.closeRequested() }
    ScrollView {
        id:scroller
        anchors.fill:parent
        anchors.margins:page.width<900 ? 16 : 28
        contentWidth:availableWidth
        clip:true
        ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
        Item {
            width:scroller.availableWidth
            height:settingsBody.implicitHeight
            ColumnLayout {
                id:settingsBody
                width:Math.min(parent.width-10,1100)
                anchors.horizontalCenter:parent.horizontalCenter
                spacing:15
                RowLayout {
                    Layout.fillWidth:true
                    SettingsTitle { text:"Settings"; font.pixelSize:UiMetrics.text(28); Layout.fillWidth:true }
                    ActionButton { text:"Home"; onClicked:page.closeRequested() }
                }
                GridLayout {
                    Layout.fillWidth:true
                    columns:settingsBody.width>850 ? 2 : 1
                    columnSpacing:16
                    rowSpacing:14
                    SettingsCard {
                        Layout.fillWidth:true
                        Layout.alignment:Qt.AlignTop
                        SettingsTitle {text:"Display and accessibility"}
                        Game.DisplaySettings {
                            Layout.fillWidth:true
                            fit:page.display.framing
                            quality:page.display.quality
                            zoom:page.display.zoom
                            frameLimit:page.display.frameLimit
                            showTimer:page.display.showTimer
                            autoSave:page.display.autoSave
                            detail:page.display.detail
                            transitionStyle:page.display.transitionStyle
                            transitionStrength:page.display.transitionStrength
                            onFrameLimitChangedByUser:function(value) {page.displayRequested("frameLimit",value)}
                            onTimerChangedByUser:function(value) {page.displayRequested("showTimer",value)}
                            onAutoSaveChangedByUser:function(value) {page.displayRequested("autoSave",value)}
                            onTextScaleChangedByUser:function(value) {page.displayRequested("textScale",value)}
                            onFitChangedByUser:function(value) {page.displayRequested("framing",value)}
                            onQualityChangedByUser:function(value) {page.displayRequested("quality",value)}
                            onZoomChangedByUser:function(value) {page.displayRequested("zoom",value)}
                            onDetailChangedByUser:function(value) {page.displayRequested("detail",value)}
                            onTransitionStyleChangedByUser:function(value) {page.displayRequested("transitionStyle",value)}
                            onTransitionStrengthChangedByUser:function(value) {page.displayRequested("transitionStrength",value)}
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth:true
                        Layout.alignment:Qt.AlignTop
                        spacing:14
                        SettingsCard {
                            Layout.fillWidth:true
                            SettingsTitle {text:"Sound and controls"}
                            SettingsCheck { text:"Sound"; checked:page.sound; onClicked:page.soundRequested() }
                            SettingsCheck { text:"Animation"; checked:page.motion; onClicked:page.motionRequested() }
                            SettingsCheck { text:"Mouse edge turns"; checked:page.display.mouseTurns; onClicked:page.displayRequested("mouseTurns",checked) }
                        }
                        SettingsCard {
                            Layout.fillWidth:true
                            SettingsTitle {text:"Progress backup"}
                            SettingsText {text:"Export your discoveries, achievements, settings and saved run. Import restores those from the backup you choose."}
                            RowLayout {
                                ActionButton {objectName:"exportProgress"; text:"Export"; onClicked:page.exportRequested()}
                                ActionButton {objectName:"importProgress"; text:"Import"; onClicked:page.importRequested()}
                            }
                            SettingsText {visible:page.status.length>0; text:page.status; color:"#a1dbc9"}
                        }
                    }
                }
            }
        }
    }

    component SettingsTitle: Text {
        font.family:"Inter"
        font.pixelSize:UiMetrics.text(18)
        font.bold:true
        color:"#ffe7d3"
    }
    component SettingsText: Text {
        Layout.fillWidth:true
        font.family:"Inter"
        font.pixelSize:UiMetrics.text(14)
        color:"#d9cbd9"
        wrapMode:Text.WordWrap
    }
    component SettingsCheck: CheckBox {
        font.pixelSize:UiMetrics.text(14)
        palette.windowText:"#eadde8"
        palette.text:"#eadde8"
    }
    component SettingsCard: Rectangle {
        default property alias content:body.data
        implicitWidth:body.implicitWidth+32
        implicitHeight:body.implicitHeight+32
        color:"#231b29"
        border.color:"#715268"
        radius:7
        ColumnLayout {
            id:body
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.margins:16
            y:16
            spacing:10
        }
    }
}
