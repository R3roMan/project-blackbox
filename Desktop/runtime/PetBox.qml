import QtQuick
import "../Demo/ui" as Ui

Item {
    id:box
    objectName:"petBox"
    property bool armed:true
    property bool trapped:false
    property real petSize:180
    property real edgeBottom:0
    property real desiredX:75
    property real desiredY:85
    property real desiredWidth:380
    property real desiredHeight:290
    signal released()
    signal removed()
    readonly property real minimumWidth:Math.min(parent.width,petSize+26)
    readonly property real minimumHeight:Math.min(parent.height-edgeBottom,petSize*99/134+60)
    readonly property rect inner:Qt.rect(x+7,y+36,Math.max(0,width-14),Math.max(0,height-43))
    width:Math.min(parent.width,Math.max(minimumWidth,desiredWidth))
    height:Math.min(parent.height-edgeBottom,Math.max(minimumHeight,desiredHeight))
    x:Math.max(0,Math.min(desiredX,parent.width-width))
    y:Math.max(0,Math.min(desiredY,parent.height-edgeBottom-height))

    Rectangle {
        anchors.fill:parent
        radius:8
        color:"#18376277"
        border.width:2
        border.color:box.trapped ? "#94d4db" : "#678fa9"
        Rectangle {anchors.fill:parent;anchors.margins:5;radius:5;color:"transparent";border.color:"#689edcdd"}
    }
    Rectangle {
        id:header
        objectName:"petBoxHandle"
        width:parent.width;height:35;radius:7;color:"#eb1d2a3a"
        MouseArea {
            anchors.fill:parent;cursorShape:pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            property point start
            property point original
            onPressed:mouse=>{start=mapToItem(box.parent,mouse.x,mouse.y);original=Qt.point(box.x,box.y)}
            onPositionChanged:mouse=>{
                if (!pressed) return
                const point=mapToItem(box.parent,mouse.x,mouse.y)
                box.desiredX=Math.max(0,Math.min(box.parent.width-box.width,original.x+point.x-start.x))
                box.desiredY=Math.max(0,Math.min(box.parent.height-box.edgeBottom-box.height,original.y+point.y-start.y))
            }
        }
        Text {
            anchors.left:parent.left;anchors.leftMargin:9;anchors.right:actions.left;anchors.rightMargin:6
            anchors.verticalCenter:parent.verticalCenter;elide:Text.ElideRight
            text:box.trapped ? "Pet enclosure · latched" : box.armed ? "Pet enclosure · ready" : "Pet enclosure · open"
            color:"#e5f7fb";font.pixelSize:13;font.bold:true
        }
        Row {
            id:actions
            anchors.right:parent.right;anchors.rightMargin:5;anchors.verticalCenter:parent.verticalCenter;spacing:4
            Ui.ActionButton {
                objectName:"petBoxLatch";height:26
                text:box.armed ? "Release" : "Arm"
                onClicked:if (box.armed) box.released();else box.armed=true
            }
            Ui.ActionButton {objectName:"petBoxRemove";height:26;text:"×";Accessible.name:"Remove pet enclosure";onClicked:box.removed()}
        }
    }
    MouseArea {
        objectName:"petBoxResize"
        width:26;height:26;anchors.right:parent.right;anchors.bottom:parent.bottom
        cursorShape:Qt.SizeFDiagCursor
        property point start
        property point original
        onPressed:mouse=>{start=mapToItem(box.parent,mouse.x,mouse.y);original=Qt.point(box.width,box.height)}
        onPositionChanged:mouse=>{
            if (!pressed) return
            const point=mapToItem(box.parent,mouse.x,mouse.y)
            box.desiredWidth=Math.max(box.minimumWidth,Math.min(box.parent.width-box.x,original.x+point.x-start.x))
            box.desiredHeight=Math.max(box.minimumHeight,Math.min(box.parent.height-box.edgeBottom-box.y,original.y+point.y-start.y))
        }
        Text {anchors.centerIn:parent;text:"◢";color:"#b7e5ef";font.pixelSize:17}
    }
}
