import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: card
    required property Item anchorItem
    required property bool hovered
    required property string details
    required property string chapter
    required property string entryId
    property int delay:300
    signal entryRequested(string chapter, string id)

    parent:anchorItem
    modal:false
    focus:false
    closePolicy:Popup.NoAutoClose
    padding:12
    z:50
    readonly property real windowWidth:anchorItem.Window.window?.width || 760
    readonly property real windowHeight:anchorItem.Window.window?.height || 530
    readonly property point origin:anchorItem.mapToItem(null,0,0)
    width:Math.max(160,Math.min(432,windowWidth-24))
    height:Math.min(implicitHeight,windowHeight-24)
    x:Math.max(12-origin.x,Math.min((anchorItem.width-width)/2,windowWidth-origin.x-width-12))
    y:Math.max(12-origin.y,Math.min(anchorItem.height+5+origin.y+height < windowHeight-12
        ? anchorItem.height+5 : -height-5,windowHeight-origin.y-height-12))

    function updateHover() {
        if (hovered && details.length) {
            dismiss.stop()
            if (!visible) reveal.restart()
        } else if (underPointer.hovered || expand.activeFocus) {
            dismiss.stop()
        } else {
            reveal.stop()
            if (visible) dismiss.restart()
        }
    }

    onHoveredChanged:updateHover()
    onDetailsChanged:if (!details.length) close()
    Component.onCompleted:updateHover()
    Timer { id:reveal; interval:card.delay; onTriggered:if (card.hovered) card.open() }
    Timer { id:dismiss; interval:380; onTriggered:if (!card.hovered && !underPointer.hovered && !expand.activeFocus) card.close() }
    background:Rectangle {
        radius:7
        color:"#fc241b29"
        border.color:"#b28373"
        border.width:1
    }
    contentItem:Item {
        implicitHeight:heading.implicitHeight+7+readout.implicitHeight
        HoverHandler { id:underPointer; onHoveredChanged:card.updateHover() }
        RowLayout {
            id:heading
            anchors.left:parent.left
            anchors.right:parent.right
            spacing:7
            Text {
                Layout.fillWidth:true
                text:card.details.split("\n")[0]
                font.family:"Inter"
                font.pixelSize:UiMetrics.text(15)
                font.bold:true
                color:"#fff0d7"
                wrapMode:Text.WordWrap
            }
            Button {
                id:expand
                objectName:"inspect-"+card.entryId
                Layout.preferredWidth:34
                Layout.preferredHeight:34
                leftPadding:0
                rightPadding:0
                font.bold:true
                font.pixelSize:UiMetrics.text(20)
                palette.buttonText:"#271521"
                background:Rectangle { color:expand.hovered ? "#ffddaa" : "#f2ae7f"; radius:5 }
                text:"+"
                Accessible.name:"Open exact Grimoire page"
                onActiveFocusChanged:card.updateHover()
                onClicked: {
                    card.close()
                    card.entryRequested(card.chapter,card.entryId)
                }
            }
        }
        ScrollView {
            id:body
            anchors.top:heading.bottom
            anchors.topMargin:7
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            contentWidth:availableWidth
            clip:true
            ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
            Text {
                id:readout
                width:Math.max(0,body.availableWidth-8)
                text:card.details.split("\n").slice(1).join("\n")
                textFormat:Text.PlainText
                wrapMode:Text.WordWrap
                font.family:"Inter"
                font.pixelSize:UiMetrics.text(13)
                lineHeight:1.2
                color:"#ebd9df"
            }
        }
    }
}
