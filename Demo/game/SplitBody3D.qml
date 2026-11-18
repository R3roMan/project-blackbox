import QtQuick
import QtQuick3D
import "Rules.js" as Rules
import "CutArt.js" as Art

Node {
    id: cut
    objectName: "severedBody"
    required property var piece
    required property Geometry hemisphere
    required property Geometry seam
    required property Geometry wing
    required property bool motion
    required property int revision

    readonly property var creature: Rules.enemyTypes[piece.type]
    readonly property var location: Rules.front(piece.front)
    readonly property real size: piece.size
    eulerRotation: Qt.vector3d(location.pitch,location.yaw,0)

    PrincipledMaterial { id: skin; baseColor: cut.creature.skin; roughness: .78; cullMode: Material.NoCulling }
    PrincipledMaterial {
        id: membrane
        baseColor: Qt.darker(cut.creature.accent,1.68)
        roughness: .65
        cullMode: Material.NoCulling
    }
    PrincipledMaterial { id: socket; baseColor: "#221420"; roughness: .75; cullMode: Material.NoCulling }

    Node {
        position: Qt.vector3d(cut.piece.lane,cut.piece.elevation,-cut.piece.depth)
        scale: Qt.vector3d(cut.size,cut.size,cut.size)
        Repeater3D {
            model: [-1,1]
            delegate: Node {
                id: half
                required property int modelData
                readonly property var pose: { cut.revision; return Art.motion(cut.piece,modelData,cut.motion) }
                readonly property real angle: pose.cut*Math.PI/180
                objectName: modelData < 0 ? "leftDemonHalf" : "rightDemonHalf"
                position: Qt.vector3d(pose.offset*Math.cos(angle),pose.offset*Math.sin(angle)+pose.rise,pose.offset*.15)
                eulerRotation: Qt.vector3d(pose.roll*.38,pose.yaw,pose.cut+pose.roll)
                scale: Qt.vector3d(modelData,1,1)
                opacity: pose.alpha
                PrincipledMaterial {
                    id: wound
                    baseColor: half.pose.seam
                    emissiveFactor: Qt.vector3d(.30,.017,.054)
                    roughness: .43
                    cullMode: Material.NoCulling
                }
                Model {
                    geometry: cut.hemisphere
                    scale: Qt.vector3d(1.32,1.41,.92)
                    materials: [skin]
                }
                Model {
                    geometry: cut.seam
                    scale: Qt.vector3d(1.32,1.41,.92)
                    materials: [wound]
                }
                Model {
                    geometry: cut.hemisphere
                    y: 41
                    z: 28
                    scale: Qt.vector3d(.72,.63,.54)
                    materials: [skin]
                }
                Model {
                    geometry: cut.seam
                    y: 41
                    z: 28
                    scale: Qt.vector3d(.72,.63,.54)
                    materials: [wound]
                }
                Model {
                    geometry: cut.hemisphere
                    y: 48
                    z: 52
                    scale: Qt.vector3d(.35,.22,.13)
                    materials: [socket]
                }
                Model {
                    geometry: cut.wing
                    z: -10
                    scale: cut.creature.devour ? Qt.vector3d(.61,.62,.76) : Qt.vector3d(1.07,1.06,1)
                    materials: [membrane]
                }
            }
        }
    }
}
