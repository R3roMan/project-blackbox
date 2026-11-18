import QtQuick
import QtQuick3D
import "Rules.js" as Rules

Node {
    id: well
    objectName: "gravityWell"
    required property var hole
    required property int revision
    required property bool motion
    readonly property var location: Rules.front(hole.front)
    readonly property real age: { revision; return hole.duration-hole.life }
    readonly property real pulse: { revision; return hole.pulse }
    readonly property real bloom: .78 + .73*pulse
    readonly property real fade: { revision; return Math.min(1,hole.life/.42) }
    eulerRotation: Qt.vector3d(location.pitch,location.yaw,0)
    opacity: fade
    PrincipledMaterial { id: core; baseColor: "#0b0719"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: violet; baseColor: "#a35ffb"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: white; baseColor: "#f9ceff"; lighting: PrincipledMaterial.NoLighting }

    Node {
        position: Qt.vector3d(well.hole.lane,well.hole.elevation,-well.hole.depth)
        scale: Qt.vector3d(well.bloom,well.bloom,well.bloom)
        Model { source:"#Sphere"; scale:Qt.vector3d(1.60,1.60,1.60); materials:[core] }
        Repeater3D {
            model: 28
            delegate: Model {
                required property int index
                readonly property real angle: index * Math.PI/14 + (well.motion ? well.age*(index%3 ? 3.25 : -2.2) : 0)
                readonly property real radius: 90 + index%5*10
                source: "#Sphere"
                position: Qt.vector3d(Math.cos(angle)*radius,Math.sin(angle)*radius*.59,Math.sin(angle)*radius*.52)
                scale: Qt.vector3d(.07+index%3*.035,.053,.074)
                materials: [index%4 ? violet : white]
            }
        }
    }
}
