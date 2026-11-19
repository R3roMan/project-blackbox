import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtCore

Popup {
    id: report
    property Item scene:null
    property var context:({})
    property string screenshotPath:""
    property string status:""
    readonly property string ledger:String(StandardPaths.writableLocation(StandardPaths.ConfigLocation))+"/project-blackbox-issues.ini"
    parent:Overlay.overlay
    anchors.centerIn:parent
    width:Math.min(parent ? parent.width-24 : 520,540)
    modal:true
    focus:true
    popupType:Popup.Item
    padding:16
    onOpened:description.forceActiveFocus()

    Settings {id:issues;location:report.ledger;category:"Reports"}
    background:Rectangle {color:"#1b171f";radius:8;border.color:"#785767"}
    contentItem:ColumnLayout {
        spacing:9
        Text {text:"Report a bug";font.pixelSize:UiMetrics.text(22);font.bold:true;color:"#f7e6e2"}
        Text {
            Layout.fillWidth:true
            wrapMode:Text.WordWrap
            text:"What happened? Tell us what you were doing and add a screenshot if it helps. Reports are saved locally."
            font.pixelSize:UiMetrics.text(14);color:"#e9d5de"
        }
        TextArea {
            id:description
            objectName:"bugDescription"
            Layout.fillWidth:true;Layout.preferredHeight:106
            selectByMouse:true
            wrapMode:TextEdit.Wrap
            placeholderText:"Describe the problem"
            onTextChanged:if (text.length>4000) remove(4000,text.length)
        }
        ActionButton {
            Layout.fillWidth:true
            visible:!!report.scene
            text:report.screenshotPath ? "Replace screenshot" : "Take a screenshot"
            onClicked:screenshot.open()
        }
        Text {
            Layout.fillWidth:true
            wrapMode:Text.WordWrap
            visible:report.status.length>0 || report.screenshotPath.length>0
            text:report.status || "Screenshot attached"
            color:"#cbe6cb";font.pixelSize:UiMetrics.text(13)
        }
        RowLayout {
            Layout.fillWidth:true
            ActionButton {text:"Close";onClicked:report.close()}
            Item {Layout.fillWidth:true}
            ActionButton {
                text:"Save report";primary:true;enabled:description.text.trim().length>0
                onClicked:{
                    const now=new Date()
                    const id="issue_"+now.getTime()+"_"+Math.floor(Math.random()*1e6)
                    issues.setValue(id,JSON.stringify({time:now.toISOString(),text:description.text.trim(),
                        screenshot:report.screenshotPath,context:report.context}))
                    issues.sync()
                    description.clear()
                    report.screenshotPath=""
                    report.status="Saved to the local issue ledger."
                }
            }
        }
    }
    FileDialog {
        id:screenshot
        title:"Save a screenshot of Blackbox"
        fileMode:FileDialog.SaveFile
        nameFilters:["PNG image (*.png)"]
        defaultSuffix:"png"
        currentFolder:StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted:{
            const path=decodeURIComponent(String(selectedFile).replace(/^file:\/\//,""))
            if (!report.scene?.grabToImage(result=>{
                if (result.saveToFile(path)) {report.screenshotPath=path;report.status=""}
                else report.status="Could not save the screenshot. Try a different path."
            })) report.status="The scene is unavailable for a screenshot."
        }
    }
}
