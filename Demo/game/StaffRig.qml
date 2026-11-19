pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: staff
    property var surfaces:null
    required property string kind
    required property color tint
    property real charge: 0
    property real cast:0
    property string style:""
    property real clock: 0
    readonly property var spectrum: ["#8afad6","#ff7849","#99e6ff","#d684ff","#e4a365","#cc8dff"]

    LitSurface { surfaces:staff.surfaces; finish:"steel"; id:iron; baseColor: "#25232b"; metalness: .81; roughness: .42 }
    LitSurface { surfaces:staff.surfaces; finish:"steel"; id:metal; baseColor: "#767381"; metalness: .84; roughness: .35 }
    LitSurface { surfaces:staff.surfaces; finish:"weave"; id:leather; baseColor: "#422631"; roughness: .96 }
    LitSurface { surfaces:staff.surfaces; finish:"wood"; id:wood; baseColor:"#5c3a38"; roughness:.64 }
    PrincipledMaterial {
        id: rune
        baseColor: Qt.lighter(staff.tint, 1 + Math.max(staff.charge,Math.sin(staff.cast*Math.PI))*.85)
        lighting: PrincipledMaterial.NoLighting
    }
    Repeater3D {
        model:staff.cast > 0 ? 8 : 0
        delegate:Model {
            required property int index
            readonly property real angle:index*Math.PI/4+staff.cast*Math.PI*2
            source:staff.kind === "burn" ? "#Cone" : "#Cube"
            x:Math.cos(angle)*(22+staff.cast*65)
            y:Math.sin(angle)*(22+staff.cast*65)
            z:-150-staff.cast*100
            eulerRotation.z:angle*180/Math.PI
            scale:Qt.vector3d(.07,.22,.07)
            opacity:Math.sin(staff.cast*Math.PI)*.85
            materials:[rune]
        }
    }
    Model {
        source: "#Cylinder"
        eulerRotation.x: 90
        scale: Qt.vector3d(.15, 2.76, .15)
        materials: [staff.style==="twig" || staff.kind==="wind" || staff.kind==="stun" ? wood : iron]
    }
    Model {
        source: "#Cylinder"
        z: 62
        eulerRotation.x: 90
        scale: Qt.vector3d(.225, .66, .225)
        materials: [leather]
    }
    Repeater3D {
        model:staff.style==="twig" ? 3 : 9
        delegate: Model {
            required property int index
            source: "#Cylinder"
            z: 34 + index * 8
            eulerRotation.x: 90
            scale: Qt.vector3d(.227,.038,.227)
            materials: [index % 3 === 0 ? metal : iron]
        }
    }
    Node {
        visible:staff.style==="hourglass"
        z:-133
        Repeater3D {model:[-1,1];Model {required property int modelData;source:"#Cone";z:modelData*22;eulerRotation.x:modelData===1 ? 180 : 0;scale:Qt.vector3d(.56,.40,.56);materials:[metal]}}
        Model {source:"#Sphere";scale:Qt.vector3d(.14,.60,.14);materials:[rune]}
    }
    Node {
        z: -136
        Model {
            source: staff.kind === "burn" ? "#Cone" : staff.kind === "wind" ? "#Cylinder" : "#Cube"
            eulerRotation: Qt.vector3d(45, staff.clock * 24, 45)
            scale: Qt.vector3d(.28,.32 + staff.charge*.10,.25)
            materials: [rune]
        }
        Repeater3D {
            model:staff.style==="twig" ? 2 : staff.style==="fork" ? 3 : staff.kind === "avatar" ? 6 : staff.kind === "wind" || staff.kind === "aurora" ? 8 : 4
            delegate: Node {
                required property int index
                readonly property real angle: index * (staff.kind === "avatar" ? 60 : staff.kind === "wind" || staff.kind === "aurora" ? 45 : 90)
                eulerRotation.z: angle + staff.clock * (20 + staff.charge * 50)
                Model {
                    source: staff.kind === "stun" ? "#Cube" : "#Cone"
                    x: 29
                    z: staff.kind === "electric" ? 6 : 16
                    eulerRotation.x: -71
                    eulerRotation.z: staff.kind === "electric" ? 46 : -24
                    scale: Qt.vector3d(.12, staff.kind === "burn" ? .50 : .38, .12)
                    materials: [metal]
                }
                Model {
                    source: "#Sphere"
                    x: 31 + staff.charge * 12
                    z: -4
                    opacity: .3 + staff.charge*.70
                    scale: Qt.vector3d(.08+staff.charge*.06,.08+staff.charge*.06,.08+staff.charge*.06)
                    materials: PrincipledMaterial {
                        baseColor: staff.kind === "avatar" ? staff.spectrum[index] : staff.tint
                        lighting: PrincipledMaterial.NoLighting
                    }
                }
            }
        }
        Repeater3D {
            model: staff.kind === "wind" || staff.charge >= 1 ? 12 : 0
            delegate: Model {
                required property int index
                readonly property real turn: index*.55 + staff.clock*(3 + staff.charge*2)
                source: "#Cube"
                x: Math.cos(turn) * (24 + staff.charge*24)
                y: Math.sin(turn) * (24 + staff.charge*24)
                z: 11 * Math.sin(index*.77)
                eulerRotation.z: turn*180/Math.PI
                opacity: staff.charge * .69
                scale: Qt.vector3d(.034,.14+staff.charge*.22,.028)
                materials: [rune]
            }
        }
    }
}
