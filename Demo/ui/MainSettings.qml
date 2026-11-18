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
    Rectangle {anchors.fill:parent; color:"#17111e"}
    Shortcut {sequence:"Escape"; onActivated:page.closeRequested()}
    ScrollView {
        anchors.fill:parent
        anchors.margins:24
        contentWidth:availableWidth
        clip:true
        ColumnLayout {
            width:Math.min(780,parent.width)
            spacing:14
            RowLayout {
                Layout.fillWidth:true
                Text {text:"Settings"; color:"#fff0e5"; font.family:"Inter"; font.pixelSize:29; font.bold:true; Layout.fillWidth:true}
                ActionButton {text:"Home · Esc"; onClicked:page.closeRequested()}
            }
            Game.DisplaySettings {
                Layout.fillWidth:true
                fit:page.display.framing
                quality:page.display.quality
                zoom:page.display.zoom
                frameLimit:page.display.frameLimit
                showTimer:page.display.showTimer
                onFrameLimitChangedByUser:function(value) {page.displayRequested("frameLimit",value)}
                onTimerChangedByUser:function(value) {page.displayRequested("showTimer",value)}
                detail:page.display.detail
                transitionStyle:page.display.transitionStyle
                transitionStrength:page.display.transitionStrength
                onFitChangedByUser:function(value) {page.displayRequested("framing",value)}
                onQualityChangedByUser:function(value) {page.displayRequested("quality",value)}
                onZoomChangedByUser:function(value) {page.displayRequested("zoom",value)}
                onDetailChangedByUser:function(value) {page.displayRequested("detail",value)}
                onTransitionStyleChangedByUser:function(value) {page.displayRequested("transitionStyle",value)}
                onTransitionStrengthChangedByUser:function(value) {page.displayRequested("transitionStrength",value)}
            }
            RowLayout {
                CheckBox {text:"Sound"; checked:page.sound; onClicked:page.soundRequested()}
                CheckBox {text:"Animation"; checked:page.motion; onClicked:page.motionRequested()}
                CheckBox {text:"Mouse edge turns"; checked:page.display.mouseTurns; onClicked:page.displayRequested("mouseTurns",checked)}
            }
            Text {
                Layout.fillWidth:true
                text:"Progress backup"
                color:"#ffd4af"; font.family:"Inter"; font.pixelSize:19; font.bold:true
            }
            Text {
                Layout.fillWidth:true
                text:"Export achievements, discoveries, combat records, settings and your single saved run. Import replaces these with the chosen backup."
                wrapMode:Text.WordWrap; color:"#d2c2d1"; font.family:"Inter"; font.pixelSize:13
            }
            RowLayout {
                ActionButton {objectName:"exportProgress"; text:"Export progress"; onClicked:page.exportRequested()}
                ActionButton {objectName:"importProgress"; text:"Import progress"; onClicked:page.importRequested()}
            }
            Text {Layout.fillWidth:true; text:page.status; color:"#a1dbc9"; font.family:"Inter"; wrapMode:Text.WordWrap; font.pixelSize:13}
        }
    }
}
