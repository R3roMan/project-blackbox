import QtQuick
import QtQuick3D

Node {
    id: rig
    required property int targetId
    required property bool live
    required property real clock
    required property real openness
    required property real healing
    required property bool hurt

    PrincipledMaterial { id: hide; baseColor: rig.hurt ? "#7d4c51" : "#513c40"; roughness: .86 }
    PrincipledMaterial { id: fur; baseColor: "#2a262a"; roughness: 1 }
    PrincipledMaterial { id: hair; baseColor: "#413238"; roughness: 1 }
    PrincipledMaterial { id: gums; baseColor: "#621d34"; roughness: .47 }
    PrincipledMaterial { id: pit; baseColor: "#210912"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: tooth; baseColor: "#e0bd88"; roughness: .53 }
    PrincipledMaterial {
        id: gaze
        baseColor: rig.healing > 0 ? "#b5f489" : "#ffcc91"
        lighting: PrincipledMaterial.NoLighting
    }

    Model {
        objectName: String(rig.targetId)
        pickable: rig.live
        source: "#Sphere"
        scale: Qt.vector3d(1.50,1.31,1.09)
        materials: [hide]
    }
    Repeater3D {
        model: 24
        delegate: Model {
            required property int index
            readonly property real angle: index*2.3999
            readonly property real heightPart: (index+.5)/24
            source: "#Cone"
            x: Math.sin(angle)*66
            y: 54-heightPart*120
            z: -18+Math.cos(angle)*42
            eulerRotation.z: Math.sin(angle)*60
            eulerRotation.x: Math.cos(angle)*47
            scale: Qt.vector3d(.092 + index%4*.025,.22 + index%5*.046,.10)
            materials: [index%3 ? fur : hair]
        }
    }
    Repeater3D {
        model: [-1,1]
        delegate: Node {
            required property int modelData
            x: modelData*69
            y: 17
            z: -37
            eulerRotation.y: modelData*(13+Math.sin(rig.clock*8)*20)
            Model { source:"#Cone"; x:modelData*21; y:2; eulerRotation.z:modelData*-65;
                scale:Qt.vector3d(.36,.63,.082); materials:[gums] }
            Model { source:"#Cone"; x:modelData*9; y:-14; eulerRotation.z:modelData*42;
                scale:Qt.vector3d(.19,.41,.083); materials:[fur] }
        }
    }
    Node {
        y: 20
        z: 49 + rig.openness*7
        Model {
            objectName: String(rig.targetId)
            pickable: rig.live
            source: "#Sphere"
            scale: Qt.vector3d(1.30,.73,.61)
            materials: [gums]
        }
        Model { source:"#Sphere"; y:-6; z:27; scale:Qt.vector3d(1.05,.30+rig.openness*.45,.075); materials:[pit] }
        Model { source:"#Sphere"; y:31; z:19; scale:Qt.vector3d(.32,.20,.19); materials:[gaze] }
        Model { source:"#Sphere"; y:31; z:28; scale:Qt.vector3d(.084,.15,.056); materials:[pit] }
        Repeater3D {
            model: 13
            delegate: Model {
                required property int index
                readonly property bool lower: index >= 7
                readonly property int toothIndex: lower ? index-7 : index
                source: "#Cone"
                x: (toothIndex - (lower ? 2.5 : 3))*13
                y: lower ? -20 - rig.openness*38 + Math.abs(toothIndex-2.5)*3 : 10 - Math.abs(toothIndex-3)*1.6
                z: 32-Math.abs(toothIndex-3)*2
                eulerRotation.z: lower ? (index%3-1)*8 : 180+(index%3-1)*8
                scale: Qt.vector3d(.094, .19+(index%3)*.040, .095)
                materials: [tooth]
            }
        }
        Model {
            objectName: String(rig.targetId)
            pickable: rig.live
            source: "#Sphere"
            y: -23-rig.openness*39
            z: 8
            scale: Qt.vector3d(1.09,.25,.66)
            materials: [hide]
        }
    }
}
