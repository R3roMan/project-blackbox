import QtQuick
import QtQuick3D

Node {
    id: rig
    required property int targetId
    required property bool live
    required property real phase
    required property real strike
    required property bool charging
    readonly property real bend: Math.sin(phase*3.8)*9
    readonly property real bite: Math.max(0,strike)

    PrincipledMaterial { id: scales; baseColor: "#263b31"; roughness: .67; metalness: .22 }
    PrincipledMaterial { id: ridge; baseColor: "#597059"; roughness: .76 }
    PrincipledMaterial { id: hood; baseColor: "#17281e"; roughness: .56 }
    PrincipledMaterial { id: fangs; baseColor: "#d6d3ac"; roughness: .42 }
    PrincipledMaterial {
        id: eyes
        baseColor: rig.charging ? "#f0ddff" : "#b4fd6f"
        lighting: PrincipledMaterial.NoLighting
    }

    Repeater3D {
        model: 15
        delegate: Model {
            required property int index
            readonly property real turn: index * Math.PI*2 / 15
            objectName: String(rig.targetId)
            pickable: rig.live
            source: "#Sphere"
            x: Math.cos(turn) * (65 + Math.sin(rig.phase*2 + turn)*4)
            y: -62 + Math.sin(turn*2)*11
            z: -21 + Math.sin(turn)*49
            scale: Qt.vector3d(.51,.40,.52)
            materials: [index % 4 ? scales : ridge]
        }
    }
    Repeater3D {
        model: 6
        delegate: Model {
            required property int index
            objectName: String(rig.targetId)
            pickable: rig.live
            source: "#Sphere"
            x: Math.sin(index*.68)*26 + rig.bend * index/5
            y: -48 + index*18
            z: Math.sin(index*.46)*22
            scale: Qt.vector3d(.49-index*.018,.49,.50-index*.015)
            materials: [index % 2 ? scales : ridge]
        }
    }
    Node {
        x: rig.bend + 2
        y: 65 + rig.bite*9
        z: 24 + rig.bite*12
        eulerRotation.x: rig.strike*19
        Model {
            objectName: String(rig.targetId)
            pickable: rig.live
            source: "#Sphere"
            scale: Qt.vector3d(.80,.46,.73)
            materials: [hood]
        }
        Model {
            objectName: String(rig.targetId)
            pickable: rig.live
            source: "#Sphere"
            y: -13-rig.bite*12
            z: 18
            scale: Qt.vector3d(.64,.17,.56)
            materials: [scales]
        }
        Repeater3D {
            model: [-1,1]
            delegate: Node {
                required property int modelData
                x: modelData*25
                Model {
                    source: "#Sphere"
                    y: 7
                    z: 25
                    scale: Qt.vector3d(.12,.065,.075)
                    materials: [eyes]
                }
                Model {
                    source: "#Cone"
                    y: -15-rig.bite*2
                    z: 37
                    eulerRotation.z: 180
                    scale: Qt.vector3d(.064,.21,.062)
                    materials: [fangs]
                }
                Model {
                    source: "#Cone"
                    x: modelData*8
                    y: 17
                    z: -17
                    eulerRotation.z: -modelData*37
                    scale: Qt.vector3d(.15,.32,.14)
                    materials: [ridge]
                }
            }
        }
    }
}
