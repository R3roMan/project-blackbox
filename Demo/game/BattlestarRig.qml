pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: vessel
    required property int targetId
    required property bool live
    required property bool charging
    required property bool beaming
    property real clock: 0

    PrincipledMaterial { id: hull; baseColor: "#171622"; metalness: .67; roughness: .39 }
    PrincipledMaterial { id: armour; baseColor: "#302131"; metalness: .63; roughness: .35 }
    PrincipledMaterial { id: seam; baseColor: "#8d253d"; metalness: .43; roughness: .40 }
    PrincipledMaterial {
        id: hot
        baseColor: vessel.beaming ? "#fff3cc" : vessel.charging ? Qt.lighter("#ff3c54", 1.3 + .2 * Math.sin(vessel.clock * 27)) : "#ff3c54"
        lighting: PrincipledMaterial.NoLighting
    }
    Model {
        source: "#Cube"
        objectName: String(vessel.targetId)
        pickable: vessel.live
        scale: Qt.vector3d(.91,.53,1.25)
        materials: [hull]
    }
    Model {
        source: "#Cone"
        objectName: String(vessel.targetId)
        pickable: vessel.live
        z: 16
        eulerRotation.x: 91
        scale: Qt.vector3d(.93,1.5,.66)
        materials: [armour]
    }
    Repeater3D {
        model: [-1, 1]
        delegate: Node {
            id: wing
            required property int modelData
            x: modelData * 73
            z: -16
            eulerRotation.y: modelData * -18
            Model {
                source: "#Cube"
                objectName: String(vessel.targetId)
                pickable: vessel.live
                eulerRotation.z: wing.modelData * 18
                scale: Qt.vector3d(.78,.26,1.09)
                materials: [hull]
            }
            Model {
                source: "#Cube"
                x: wing.modelData * 32
                z: -9
                y: 12
                eulerRotation.z: wing.modelData * 49
                scale: Qt.vector3d(.17,.82,.88)
                materials: [armour]
            }
            Model {
                source: "#Cube"
                x: wing.modelData * 37
                y: 25
                z: 8
                scale: Qt.vector3d(.10,.065,.72)
                materials: [seam]
            }
            Model {
                source: "#Cylinder"
                x: wing.modelData * 20
                y: -14
                z: 45
                eulerRotation.x: 90
                scale: Qt.vector3d(.19,.26,.19)
                materials: [seam]
            }
        }
    }
    Model {
        source: "#Cylinder"
        objectName: String(vessel.targetId)
        pickable: vessel.live
        y: -9
        z: 49
        eulerRotation.x: 90
        scale: Qt.vector3d(.37,.59,.35)
        materials: [armour]
    }
    Model {
        source: "#Sphere"
        y: -9
        z: 80
        scale: Qt.vector3d(.22,.22,.09)
        materials: [hot]
    }
    Repeater3D {
        model: 5
        delegate: Model {
            required property int index
            source: "#Cube"
            x: (index - 2) * 18
            z: 43
            y: 23
            scale: Qt.vector3d(.09,.05,.32)
            materials: [hot]
        }
    }
}
