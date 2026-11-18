import QtQuick
import QtQuick3D

Node {
    id:blast
    required property var event
    required property int revision
    readonly property real age:{revision; return Math.max(0,1-event.life/event.span)}
    PrincipledMaterial {id:foam; baseColor:"#b2edff"; lighting:PrincipledMaterial.NoLighting}
    PrincipledMaterial {id:violet; baseColor:"#b58bdf"; lighting:PrincipledMaterial.NoLighting}
    Model {
        source:"#Sphere"
        scale:Qt.vector3d(.8+blast.age*4.0,.8+blast.age*4.0,.8+blast.age*4.0)
        opacity:Math.pow(1-blast.age,2)*.47
        materials:[foam]
    }
    Model {
        source:"#Sphere"
        eulerRotation.x:29
        scale:Qt.vector3d(1+blast.age*5.1,.12+blast.age*.13,1+blast.age*5.1)
        opacity:(1-blast.age)*.40
        materials:[violet]
    }
    Repeater3D {
        model:10
        delegate:Model {
            required property int index
            readonly property real angle:index*2.39996
            source:"#Sphere"
            x:Math.cos(angle)*blast.age*255
            y:Math.sin(angle)*blast.age*245-blast.age*blast.age*42
            z:Math.sin(angle*2.8)*blast.age*190
            scale:Qt.vector3d(.13+blast.age*.18,.13+blast.age*.18,.13+blast.age*.18)
            opacity:1-blast.age
            materials:[index%3 ? foam : violet]
        }
    }
}
