import QtQuick
import QtQuick3D

Node {
    id:presence
    required property var enemy
    required property int revision
    required property color tint
    property bool motion:true
    readonly property var styles:({
        humontafagus:[0,1.15,.92,1.08],mastafangenbus:[1,1.16,.62,2.45],
        gigafinterus:[0,1.52,1.22,1.37],lucifoverus:[2,1.30,1.45,1.64],
        hasasasa:[1,1.60,.78,.62],stinkaturumus:[3,1.17,.78,.72],
        voidGlitch:[2,1.43,1.17,2.16],reapfast:[3,1.86,1.15,.43]
    })
    readonly property var style:styles[enemy.type] || styles.humontafagus
    readonly property real clock:{revision;return motion ? enemy.age : .15}
    readonly property real intensity:{revision;return enemy.hp>0 ? .68+.32*(1-Math.min(1,enemy.hp/Math.max(1,enemy.maxHp))) : 0}
    PrincipledMaterial {
        id:reflections
        baseColor:Qt.tint("#969aa1",presence.tint)
        metalness:.38
        roughness:.26
        clearcoatAmount:.49
        emissiveFactor:Qt.vector3d(presence.tint.r*.48,presence.tint.g*.48,presence.tint.b*.48)
    }
    PointLight {
        position:Qt.vector3d(-65,76,-41)
        color:presence.tint
        quadraticFade:.52
        brightness:presence.intensity*(1.45+Math.sin(presence.clock*.78)*.22)
    }
    Repeater3D {
        model:12
        Model {
            required property int index
            readonly property real phase:(index*.61803399+presence.clock*.22)%1
            readonly property real angle:index*2.399963+presence.clock*presence.style[3]*.38
            source:presence.style[0]===0 ? "#Cone" : presence.style[0]===3 ? "#Sphere" : "#Cube"
            x:Math.cos(angle)*(62+(index%4)*12)*presence.style[1]
            y:(phase-.29)*(index%2===0 ? 123 : 83)*presence.style[2]+Math.sin(angle*1.7)*21
            z:Math.sin(angle)*42-37
            eulerRotation:Qt.vector3d(angle*52,angle*31,index*53+phase*79)
            scale:Qt.vector3d(.025+phase*.012,.045+phase*.034,.025+phase*.011)
            opacity:Math.sin(phase*Math.PI)*presence.intensity*.76
            castsShadows:false
            materials:[reflections]
        }
    }
}
