import QtQuick
import "../ui" as Ui
import "Pets.js" as Pets

Rectangle {
    id: meter
    objectName:"petActionMeter"
    required property var pet
    required property var world
    required property real clock
    required property int revision
    required property string frontId
    property bool motion:true
    readonly property var move:pet ? Pets.secondary[pet.id] : null
    readonly property real rest:{revision;return pet?.resting || 0}
    readonly property real charge:{revision;return pet?.chargeLeft || 0}
    readonly property bool pending:{revision;return !!pet?.chargePending}
    readonly property real fraction:{
        revision
        if (rest>0) return 1-rest/Math.max(.1,pet.restLength || pet.stats.rest)
        return pet ? 1-charge/Math.max(.1,pet.chargeLength) : 0
    }
    readonly property point location:{
        revision
        if (!world || !pet) return Qt.point(0,0)
        const pose=Pets.flight(pet,clock,motion)
        const position=world.projection(pose.lane,pose.elevation+73,pose.depth)
        return world.mapToItem(meter.parent,position.x,position.y)
    }
    visible:!!world && !!pet && pet.front===frontId && (rest>0 || pending)
        && location.x>=0 && location.x<parent.width && location.y>=0 && location.y<parent.height
    x:Math.max(5,Math.min(parent.width-width-5,location.x-width*.5))
    y:Math.max(8,location.y-height)
    width:Math.max(Ui.UiMetrics.text(115),title.implicitWidth+16)
    height:title.implicitHeight+13
    radius:5
    color:"#f2201828"
    border.color:rest>0 ? "#a198cb" : "#f4c786"
    Accessible.name:title.text

    Text {
        id:title
        anchors.horizontalCenter:parent.horizontalCenter
        y:3
        text:meter.rest>0 ? "RESTING · "+Math.ceil(meter.rest)+"s"
            : meter.move ? meter.move.title+(meter.charge<=.02 ? " · Ready" : " · "+meter.charge.toFixed(1)+"s") : ""
        font.family:"Inter"
        font.bold:true
        font.pixelSize:Ui.UiMetrics.text(11)
        color:meter.rest>0 ? "#e3d7ff" : "#ffe9b2"
    }
    Rectangle {
        anchors {left:parent.left; right:parent.right; bottom:parent.bottom; margins:4}
        height:3; radius:1
        color:"#534b61"
        Rectangle {
            width:parent.width*Math.max(0,Math.min(1,meter.fraction))
            height:parent.height; radius:1
            color:meter.border.color
        }
    }
}
