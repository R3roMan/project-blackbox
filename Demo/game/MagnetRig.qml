import QtQuick
import QtQuick3D

Node {
    id: rig
    required property int targetId
    required property bool live
    required property bool warning
    required property real clock

    PrincipledMaterial { id: silver; baseColor: "#c5c6ce"; metalness: .79; roughness: .31 }
    PrincipledMaterial { id: graphite; baseColor: "#272733"; metalness: .66; roughness: .41 }
    PrincipledMaterial { id: coil; baseColor: "#8d54c7"; metalness: .47; roughness: .34 }
    PrincipledMaterial {
        id: charge
        baseColor: rig.warning ? "#fff5ff" : "#d5a6ff"
        lighting: PrincipledMaterial.NoLighting
    }

    Model {
        objectName: String(rig.targetId)
        pickable: rig.live
        source: "#Sphere"
        scale: Qt.vector3d(.91,.89,.65)
        materials: [graphite]
    }
    Model {
        source: "#Sphere"
        z: 33
        scale: Qt.vector3d(.51,.51,.20)
        materials: [silver]
    }
    Model {
        source: "#Sphere"
        z: 43
        scale: Qt.vector3d(.32,.32,.19)
        materials: [charge]
    }
    Model {
        source: "#Sphere"
        z: 52
        scale: Qt.vector3d(.09,.19,.035)
        materials: [graphite]
    }

    Repeater3D {
        model: [-1,1]
        delegate: Node {
            required property int modelData
            x: modelData * 49
            y: -14
            eulerRotation.z: -modelData * (11 + Math.sin(rig.clock*6)*6 + (rig.warning ? 16 : 0))

            Model {
                objectName: String(rig.targetId)
                pickable: rig.live
                source: "#Cube"
                scale: Qt.vector3d(.26,.82,.41)
                materials: [silver]
            }
            Model {
                objectName: String(rig.targetId)
                pickable: rig.live
                source: "#Cube"
                x: -modelData * 16
                y: -44
                eulerRotation.z: modelData * -20
                scale: Qt.vector3d(.54,.28,.39)
                materials: [graphite]
            }
            Repeater3D {
                model: 4
                delegate: Model {
                    required property int index
                    source: "#Cube"
                    y: -12 + index * 12
                    scale: Qt.vector3d(.30,.068,.45)
                    materials: [coil]
                }
            }
            Model {
                source: "#Cube"
                y: 41
                scale: Qt.vector3d(.30,.14,.46)
                materials: [charge]
            }
        }
    }
}
