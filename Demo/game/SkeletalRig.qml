pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: rig
    property var surfaces:null
    required property int targetId
    required property bool live
    required property real beam
    property real clock: 0

    LitSurface { surfaces:rig.surfaces; finish:"bone"; id:bone; baseColor:"#c6b6a0"; roughness:.49; specularAmount:.73 }
    LitSurface { surfaces:rig.surfaces; finish:"bone"; id:tooth; baseColor:"#e3d3b5"; roughness:.61 }
    PrincipledMaterial { id: hollow; baseColor: "#29212a"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: gem; baseColor: rig.beam > .5 ? "#fff4bc" : "#ffdb52"; lighting: PrincipledMaterial.NoLighting }
    LitSurface { surfaces:rig.surfaces; finish:"steel"; id:filigree; baseColor: "#aa793e"; metalness: .66; roughness: .47 }

    Model {
        source: "#Sphere"
        objectName: String(rig.targetId)
        pickable: rig.live
        z: 38
        y: 38
        scale: Qt.vector3d(.73,.64,.58)
        materials: [bone]
    }
    Model {
        source: "#Cube"
        objectName: String(rig.targetId)
        pickable: rig.live
        z: 58
        y: 15 - rig.beam*14
        scale: Qt.vector3d(.45,.22,.39)
        materials: [tooth]
    }
    Model {
        source: "#Sphere"
        y: 24
        z: 69
        scale: Qt.vector3d(.43,.12 + rig.beam*.14,.14)
        materials: [hollow]
    }
    Model {
        source: "#Cylinder"
        y: -10
        z: 10
        scale: Qt.vector3d(.20,1.10,.26)
        materials: [bone]
    }
    Repeater3D {
        model: [-1, 1]
        delegate: Node {
            id: side
            required property int modelData
            readonly property int sign: modelData
            Model {
                source: "#Sphere"
                x: side.sign*17; y:43; z:61
                scale: Qt.vector3d(.22,.16,.12)
                materials: [hollow]
            }
            Model { objectName:"eye:"+rig.targetId; pickable:rig.live;
                source: "#Cube"
                x: side.sign*17; y:43; z:69
                eulerRotation: Qt.vector3d(26,side.sign*31,45)
                scale: Qt.vector3d(.10,.11,.10)
                materials: [gem]
            }
            Repeater3D {
                model: 4
                delegate: Model {
                    required property int index
                    source: "#Cylinder"
                    x: side.sign * (23 + (3-index)*3)
                    y: 7 - index*12
                    z: 22
                    eulerRotation.z: side.sign * (65 + 5*index)
                    scale: Qt.vector3d(.069,.52-index*.064,.073)
                    materials: [index === 3 ? filigree : bone]
                }
            }
            Node {
                x: side.sign*45
                y: 24
                z: -13
                eulerRotation.z: side.sign*(17 + Math.sin(rig.clock*4)*7 - rig.beam*12)
                Model {
                    source: "#Cone"
                    objectName: String(rig.targetId)
                    pickable: rig.live
                    x: side.sign * 44
                    y: 24
                    eulerRotation.z: -side.sign*57
                    scale: Qt.vector3d(.09,1.21,.12)
                    materials: [bone]
                }
                Repeater3D {
                    model: 4
                    delegate: Model {
                        required property int index
                        source: "#Cone"
                        x: side.sign * (14 + index*16)
                        y: -index*7
                        eulerRotation.z: side.sign * (136 + index*9)
                        scale: Qt.vector3d(.075,.60-index*.08,.085)
                        materials: [index === 0 ? filigree : bone]
                    }
                }
            }
        }
    }
    Model {
        source: "#Sphere"
        visible: rig.beam > 0
        z: 72
        y: 24
        scale: Qt.vector3d(.11+rig.beam*.12,.08+rig.beam*.09,.09)
        materials: [gem]
    }
}
