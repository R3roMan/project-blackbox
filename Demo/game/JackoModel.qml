pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

Node {
    id: jacko
    required property real phase
    required property real strike
    required property real charged
    required property real fold
    property bool motion: true
    readonly property real agitation: Math.max(strike*2.2,charged)
    PrincipledMaterial { id: rind; baseColor:"#b44a20";roughness:.67 }
    PrincipledMaterial { id: edge; baseColor:"#d97622";roughness:.61 }
    PrincipledMaterial {id:stem;baseColor:"#536539";roughness:.78}
    PrincipledMaterial {
        id: dark
        baseColor:"#261426"
        lighting:PrincipledMaterial.NoLighting
        cullMode:Material.NoCulling
    }
    PrincipledMaterial {
        id: lit
        baseColor:jacko.agitation>.14 ? "#d4ff79" : "#80e852"
        lighting:PrincipledMaterial.NoLighting
        cullMode:Material.NoCulling
    }
    PrincipledMaterial {
        id: flame
        baseColor:"#318e4e"
        lighting:PrincipledMaterial.NoLighting
    }
    Repeater3D {
        model:10
        Model {
            required property int index
            readonly property real angle:index*Math.PI*.2
            source:"#Sphere"
            x:Math.sin(angle)*18
            z:Math.cos(angle)*16
            eulerRotation.y:index*36
            scale:Qt.vector3d(.41,.68,.45)
            materials:[index%2 ? rind : edge]
        }
    }
    Model {
        source:"#Cylinder"
        y:34
        z:-3
        eulerRotation.z:-22
        scale:Qt.vector3d(.084,.16,.082)
        materials:[stem]
    }
    ProceduralMesh {
        id: eyes
        positions:[Qt.vector3d(-29,13,31),Qt.vector3d(-9,8,38),Qt.vector3d(-18,-2,35),
            Qt.vector3d(29,13,31),Qt.vector3d(9,8,38),Qt.vector3d(18,-2,35)]
        indexes:[0,1,2,3,5,4]
    }
    ProceduralMesh {
        id: smile
        positions:[Qt.vector3d(-28,-5,31),Qt.vector3d(-15,-10,36),Qt.vector3d(-10,-8,39),Qt.vector3d(-2,-14,40),
            Qt.vector3d(5,-10,40),Qt.vector3d(12,-13,38),Qt.vector3d(27,-4,32),Qt.vector3d(20,-19,31),
            Qt.vector3d(11,-23,34),Qt.vector3d(0,-24,34),Qt.vector3d(-16,-20,33),Qt.vector3d(-24,-13,33)]
        indexes:[0,1,11,1,10,11,1,2,10,2,9,10,2,3,9,3,4,9,4,8,9,4,5,8,5,7,8,5,6,7]
    }
    Model {
        geometry:eyes
        y:8*jacko.fold
        z:1.3
        scale:Qt.vector3d(1.06,1-.75*jacko.fold,1)
        materials:[dark]
    }
    Model {
        geometry:eyes
        x:0
        y:8*jacko.fold
        z:4
        scale:Qt.vector3d(.89,(.72+jacko.agitation*.21)*(1-.86*jacko.fold),.98)
        materials:[lit]
    }
    Model {geometry:smile;z:2;materials:[dark]}
    Model {
        geometry:smile
        z:5
        y:-3.5
        scale:Qt.vector3d(.85,.77,1)
        opacity:1-.86*jacko.fold
        materials:[lit]
    }
    Repeater3D {
        model:8
        Model {
            required property int index
            readonly property real rise:jacko.motion ? (jacko.phase*(.74+index*.025)+index*.154)%1 : index*.098
            readonly property real angle:index*2.3999+rise*2.35
            readonly property real spray:jacko.agitation*12
            visible:jacko.fold<.98
            source:"#Cone"
            position:Qt.vector3d(Math.cos(angle)*(8+rise*(16+spray)),29+rise*(40+spray),Math.sin(angle)*14)
            eulerRotation:Qt.vector3d(Math.sin(angle)*25,0,Math.cos(angle)*38)
            scale:Qt.vector3d(.06+rise*.09,.23+rise*.13,.06+rise*.09)
            opacity:(1-rise)*(.83-.74*jacko.fold)
            materials:[index%3===0 || jacko.agitation>.22 ? lit : flame]
        }
    }
}
