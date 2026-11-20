import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Demo/ui" as Ui

FocusScope {
    id: petPanel
    objectName:"petConsole"
    required property var assistant
    signal closeRequested()
    signal submitted(string command)
    function takeFocus() {entry.forceActiveFocus()}
    Keys.onEscapePressed:closeRequested()
    Ui.ShrineFrame {anchors.fill:parent; decorated:true; blood:.2}
    ColumnLayout {
        anchors.fill:parent
        anchors.margins:14
        spacing:8
        RowLayout {
            Layout.fillWidth:true
            Text {
                Layout.fillWidth:true
                text:"Pet terminal"
                font.family:Ui.InterfaceTheme.heading;font.pixelSize:22;font.bold:true
                color:Ui.InterfaceTheme.text
            }
            Ui.ActionButton {text:"Close";onClicked:petPanel.closeRequested()}
        }
        PetMood {Layout.fillWidth:true;mood:petPanel.assistant.mood;name:petPanel.assistant.petName}
        ScrollView {
            id: history
            Layout.fillHeight:true;Layout.fillWidth:true
            clip:true
            TextArea {
                text:petPanel.assistant.log.join("\n")
                readOnly:true;selectByMouse:true
                wrapMode:TextEdit.Wrap
                textFormat:TextEdit.PlainText
                font.family:"monospace"
                font.pixelSize:14
                color:Ui.InterfaceTheme.text
                background:Rectangle {color:"#131218";radius:5}
                onTextChanged:Qt.callLater(()=>{if (history.contentItem) history.contentItem.contentY=Math.max(0,history.contentHeight-history.height)})
            }
        }
        RowLayout {
            Layout.fillWidth:true
            Text {text:"pet";font.family:"monospace";color:"#a2e5c5"}
            TextField {
                id:entry
                objectName:"petCommandEntry"
                Layout.fillWidth:true
                placeholderText:"say hello"
                maximumLength:1500
                selectByMouse:true
                onAccepted:{
                    if (!text.trim()) return
                    petPanel.submitted(text)
                    clear()
                }
            }
            Ui.ActionButton {text:"Help";onClicked:petPanel.submitted("help")}
            Ui.ActionButton {text:"Send";primary:true;onClicked:entry.accepted()}
        }
        RowLayout {
            Layout.fillWidth:true
            visible:!!petPanel.assistant.pendingTitle
            Text {
                Layout.fillWidth:true
                text:petPanel.assistant.pendingTitle
                color:"#ffdca8";wrapMode:Text.WordWrap;font.pixelSize:13
            }
            Ui.ActionButton {text:"Cancel";onClicked:petPanel.assistant.cancel()}
            Ui.ActionButton {text:petPanel.assistant.approvalLabel;primary:true;onClicked:petPanel.assistant.approve()}
        }
    }
}
