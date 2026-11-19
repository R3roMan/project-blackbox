import QtQuick
import QtQuick3D

Node {
    id: rig
    property Material iceMaterial:null
    required property int targetId
    required property bool live
    required property real clock
    required property bool aiming
    required property real recoil

    property var surfaces:null
    LitSurface {surfaces:rig.surfaces; finish:"steel"; id:alloy; baseColor:"#526078"; metalness:.76; roughness:.38}
    LitSurface {surfaces:rig.surfaces; finish:"steel"; id:dark; baseColor:"#182334"; roughness:.64}
    LitSurface {surfaces:rig.surfaces; finish:"steel"; id:wire; baseColor:"#f2a263"; metalness:.50; roughness:.37}
    PrincipledMaterial {
        id: optic
        baseColor: rig.aiming ? "#fff0ba" : "#ff635a"
        lighting: PrincipledMaterial.NoLighting
    }

    Model {
        objectName: String(rig.targetId)
        source: "#Cube"
        pickable: rig.live
        eulerRotation.z: 17
        scale: Qt.vector3d(.83,.68,.57)
        materials: rig.iceMaterial ? [rig.iceMaterial] : ([alloy])
    }
    Model {
        objectName: String(rig.targetId)
        source: "#Sphere"
        pickable: rig.live
        y: 46
        z: 18
        scale: Qt.vector3d(.78,.37,.56)
        materials: rig.iceMaterial ? [rig.iceMaterial] : ([dark])
    }
    Model {
        source: "#Cube"
        y: 47
        z: 43
        scale: Qt.vector3d(.55,.09,.12)
        materials: rig.iceMaterial ? [rig.iceMaterial] : ([optic])
    }
    Model { source:"#Cube"; x:-26; y:75; eulerRotation.z:17; scale:Qt.vector3d(.035,.58,.037); materials:rig.iceMaterial ? [rig.iceMaterial] : ([wire])}
    Model { source:"#Sphere"; x:-34; y:105; scale:Qt.vector3d(.065,.065,.06); materials:rig.iceMaterial ? [rig.iceMaterial] : ([optic])}
    Node {
        x: 36
        y: 14
        z: 20 - rig.recoil*23
        eulerRotation: Qt.vector3d(rig.aiming ? -3 : 13,rig.aiming ? 8 : 28,-11)
        Model {
            source: "#Cube"
            objectName: String(rig.targetId)
            pickable: rig.live
            scale: Qt.vector3d(.45,.29,.63)
            materials: rig.iceMaterial ? [rig.iceMaterial] : ([dark])
        }
        Model { source:"#Cube"; z:54; y:8; scale:Qt.vector3d(.25,.13,1.19); materials:rig.iceMaterial ? [rig.iceMaterial] : ([alloy])}
        Model { source:"#Cube"; z:111; y:8; scale:Qt.vector3d(.32,.27,.31); materials:rig.iceMaterial ? [rig.iceMaterial] : ([dark])}
        Model { source:"#Cube"; z:128; y:8; scale:Qt.vector3d(.09,.075,.08); materials:rig.iceMaterial ? [rig.iceMaterial] : ([optic])}
        Model { source:"#Cube"; z:38; y:25; scale:Qt.vector3d(.16,.11,.31); materials:rig.iceMaterial ? [rig.iceMaterial] : ([optic])}
    }
    Repeater3D {
        model: [-1,1]
        delegate: Node {
            required property int modelData
            x: modelData*47
            y: -29
            eulerRotation.z: modelData * 18
            Model {
                source: "#Cylinder"
                scale: Qt.vector3d(.27,.46,.27)
                materials: rig.iceMaterial ? [rig.iceMaterial] : ([alloy])
            }
            Model {
                source: "#Cone"
                y: -36
                eulerRotation.z: 180
                scale: Qt.vector3d(.19,.31+Math.sin(rig.clock*17+modelData)*.055,.19)
                materials: rig.iceMaterial ? [rig.iceMaterial] : ([optic])
            }
        }
    }
}
