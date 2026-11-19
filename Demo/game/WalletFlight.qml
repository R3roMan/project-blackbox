pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: holder
    property bool motion:true
    ListModel {id:bursts}
    signal arrived(string kind)

    function launch(event,from,to) {
        if (!motion) {arrived(event.kind);return}
        const count=event.kind==="gem" ? event.amount : Math.min(6,Math.ceil(Math.sqrt(event.amount)*.70))
        if (bursts.count>=14) bursts.remove(0)
        bursts.append({serial:event.id,kind:event.kind,startX:from.x,startY:from.y,targetX:to.x,targetY:to.y,total:count})
    }

    function clear() {bursts.clear()}
    function remove(id,kind) {
        for (let i=0;i<bursts.count;i++) {
            if (bursts.get(i).serial!==id) continue
            bursts.remove(i)
            break
        }
        arrived(kind)
    }

    Repeater {
        model:bursts
        delegate:Item {
            id: burst
            anchors.fill:parent
            required property int serial
            required property string kind
            required property real startX
            required property real startY
            required property real targetX
            required property real targetY
            required property int total
            readonly property bool gem:kind==="gem"
            readonly property color glow:gem ? "#df6fff" : "#ffcb5d"
            property real progress:0
            NumberAnimation on progress {
                from:0;to:1;duration:burst.gem ? 880 : 690
                onFinished:holder.remove(burst.serial,burst.kind)
            }
            Repeater {
                model:burst.total
                Item {
                    id: shard
                    required property int index
                    readonly property real launchAngle:index*2.399+burst.serial*.12
                    readonly property real air:Math.min(1,burst.progress/.52)
                    readonly property real bolt:Math.pow(Math.max(0,(burst.progress-.52)/.48),1.82)
                    readonly property real startX:burst.startX+Math.sin(launchAngle)*air*(18+index*4)
                    readonly property real startY:burst.startY-Math.sin(air*Math.PI*.64)*(30+index*12)
                    readonly property real dx:burst.targetX-startX
                    readonly property real dy:burst.targetY-startY
                    x:startX+dx*bolt
                    y:startY+dy*bolt
                    opacity:bolt>.92 ? 1-(bolt-.92)/.08 : 1
                    Rectangle {
                        width:Math.min(Math.hypot(shard.dx,shard.dy)*shard.bolt*.45,burst.gem ? 125 : 88)
                        height:burst.gem ? 3.8 : 1.6
                        color:burst.glow
                        radius:height*.5
                        x:-width
                        y:-height*.5
                        rotation:Math.atan2(shard.dy,shard.dx)*180/Math.PI
                        transformOrigin:Item.Right
                        visible:shard.bolt>.01
                        opacity:.54
                    }
                    Rectangle {
                        width:burst.gem ? 11 : 9
                        height:burst.gem ? 13 : 8
                        x:-width*.5
                        y:-height*.5
                        radius:burst.gem ? 1 : width*.5
                        rotation:burst.gem ? 45+shard.index*13+240*burst.progress : burst.progress*180
                        border.color:burst.gem ? "#f8ceff" : "#fff0b2"
                        scale:1.25-shard.bolt*.48
                        gradient:Gradient {
                            GradientStop {position:0;color:burst.gem ? "#fbcdff" : "#fffbc9"}
                            GradientStop {position:.61;color:burst.glow}
                            GradientStop {position:1;color:burst.gem ? "#6d2da3" : "#ad6e26"}
                        }
                    }
                }
            }
        }
    }
}
