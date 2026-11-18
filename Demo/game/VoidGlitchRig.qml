import QtQuick
import QtQuick3D

Node {
    id: rig
    required property int targetId
    required property bool live
    required property real time
    required property bool warning
    PrincipledMaterial { id: unseen; baseColor: "#1a1228"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: noise; baseColor: "#781035"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: eye; baseColor: rig.warning ? "#ffb282" : "#ff325b"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: glow; baseColor: "#fa1642"; lighting: PrincipledMaterial.NoLighting }

    Model {
        objectName: String(rig.targetId)
        pickable: rig.live
        source: "#Sphere"
        scale: Qt.vector3d(1.87,1.80,.91)
        opacity: .15
        materials: [unseen]
    }
    Repeater3D {
        model: 20
        delegate: Model {
            required property int index
            readonly property real error: Math.sin(Math.floor(rig.time*(22+index%5)) + index*14.61)
            source: "#Cube"
            x: Math.sin(index*14.41)*47 + error*67
            y: (index-9.5)*9 + error*7
            z: index%4 * 14 - 19
            visible: error < .70 || index%3 === 0
            scale: Qt.vector3d(.38+(index%7)*.28,.025+(index%3)*.045,.049)
            opacity: .29 + Math.abs(error)*.50
            materials: [index%5 === 0 ? noise : unseen]
        }
    }
    Repeater3D {
        model: [-1,1]
        delegate: Node {
            required property int modelData
            x: modelData*30
            y: 21
            z: 51
            eulerRotation.z: modelData*13
            Model { source:"#Sphere"; scale:Qt.vector3d(.38,.20,.07); opacity:.37; materials:[glow] }
            Model { source:"#Sphere"; z:4; scale:Qt.vector3d(.205,.099,.072); materials:[eye] }
        }
    }
}
