import QtQuick
import QtQuick3D
import "Rules.js" as Rules

Node {
    id: ship
    required property var enemy
    required property int revision
    property bool animate: true
    property real visibility: 1
    readonly property bool coreOpen: { revision; return enemy.turrets.every(function(part) { return !part.hp }) }
    readonly property real wreck: { revision; return enemy.wreck }
    readonly property real barrier: { revision; return enemy.barrier }
    readonly property real shatter: { revision; return enemy.shatter || 0 }
    readonly property bool live: { revision; return enemy.warp <= 0 && enemy.hp > 0 }
    readonly property real clock: { revision; return animate ? enemy.age : 0 }

    opacity: visibility
    eulerRotation: Qt.vector3d(Rules.front(enemy.front).pitch, Rules.front(enemy.front).yaw, 0)
    PrincipledMaterial { id: armor; baseColor: "#33364f"; metalness: .44; roughness: .52 }
    PrincipledMaterial { id: panels; baseColor: "#6b7494"; metalness: .65; roughness: .45 }
    PrincipledMaterial { id: ports; baseColor: "#1d2234"; roughness: .72 }
    PrincipledMaterial { id: warning; baseColor: "#ffa959"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: hazard; baseColor: "#ff315a"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: field; baseColor: "#68c7ff"; lighting: PrincipledMaterial.NoLighting }

    Node {
        id: hull
        position: {
            ship.revision
            return Qt.vector3d(Rules.lanePosition(ship.enemy), Rules.elevation(ship.enemy), -ship.enemy.depth)
        }
        eulerRotation.z: ship.wreck && ship.animate ? Math.sin(ship.clock * 13) * 3.3 : 0
        Model {
            source: "#Sphere"
            scale: Qt.vector3d(8.65, 2.24, 2.33)
            materials: [armor]
        }
        Model {
            source: "#Sphere"
            y: 40
            z: 27
            scale: Qt.vector3d(7.2, 1.64, 1.95)
            materials: [panels]
        }
        Model {
            source: "#Cube"
            y: -23
            z: 61
            scale: Qt.vector3d(5.71, .18, .43)
            materials: [ports]
        }
        Repeater3D {
            model: 6
            delegate: Model {
                required property int index
                readonly property real wing: index - 2.5
                source: "#Cube"
                x: wing * 109
                y: 58 - Math.abs(wing)*9
                z: 31
                eulerRotation.y: wing * 9
                scale: Qt.vector3d(.33,.08,.91)
                materials: [index % 2 ? ports : panels]
            }
        }
        Repeater3D {
            model: 8
            delegate: Node {
                required property int index
                readonly property real outer: (index-3.5)/3.5
                x: outer*398
                y: Math.abs(outer)*-18
                z: 71-Math.abs(outer)*43
                eulerRotation.z: outer*21
                Model { source:"#Cube"; scale:Qt.vector3d(.77,.31,1.22); materials:[ports] }
                Model { source:"#Cone"; y:24; z:-18; scale:Qt.vector3d(.32, .79, .57); materials:[panels] }
                Model { source:"#Cube"; y:-8; z:63; scale:Qt.vector3d(.52,.06,.065); materials:[hazard] }
                Model {
                    source:"#Cone"
                    y:-34; z:34
                    eulerRotation.z:180
                    scale:Qt.vector3d(.18,.54,.22)
                    materials:[armor]
                }
            }
        }
        Repeater3D {
            model: 8
            Model {
                required property int index
                source: "#Cube"
                x: (index - 3.5) * 66
                y: -24
                z: 85
                scale: Qt.vector3d(.26, .065, .08)
                opacity: ship.wreck ? .25 + .75 * Math.abs(Math.sin(ship.clock * 17 + index)) : .8
                materials: [warning]
            }
        }
        Repeater3D {
            model: 3
            delegate: Node {
                id: turret
                required property int index
                readonly property var part: ship.enemy.turrets[index]
                readonly property bool broken: { ship.revision; return part.hp <= 0 }
                readonly property real recoil: { ship.revision; return part.flash }
                x: { ship.revision; return part.lane }
                y: { ship.revision; return part.height }
                z: 75 - recoil * 57
                readonly property real span: Math.hypot(part.baseLane-x,-30-y)
                PrincipledMaterial {
                    id: conductor
                    baseColor: turret.part.tint
                    lighting: PrincipledMaterial.NoLighting
                }
                Model {
                    visible: !turret.broken
                    source: "#Cylinder"
                    x: (turret.part.baseLane-turret.x)*.5
                    y: (-30-turret.y)*.50
                    z: -17
                    eulerRotation.z: -Math.atan2(turret.part.baseLane-turret.x,-30-turret.y)*180/Math.PI
                    scale: Qt.vector3d(.31, turret.span/100 + .1, .37)
                    materials: [ports]
                }
                Model {
                    visible: !turret.broken
                    source: "#Sphere"
                    scale: Qt.vector3d(.99,.76,.97)
                    materials: [panels]
                }
                Model {
                    objectName: String(turret.part.targetId)
                    visible: !turret.broken
                    pickable: visible && ship.live
                    source: "#Cylinder"
                    z: 38
                    eulerRotation.x: 90
                    scale: Qt.vector3d(.79, .29, .65)
                    materials: [ports]
                }
                Model {
                    visible: !turret.broken
                    source: "#Sphere"
                    z: 57 + 22 * turret.recoil
                    scale: Qt.vector3d(.49 + turret.recoil, .47 + turret.recoil, .09 + turret.recoil)
                    opacity: .45 + turret.recoil
                    materials: [conductor]
                }
                Model {
                    visible: turret.broken
                    source: "#Sphere"
                    z: 11
                    scale: Qt.vector3d(.87, .71, .61)
                    materials: [ports]
                }
            }
        }
        Node {
            visible: ship.coreOpen
            y: 12
            z: 81
            Model {
                objectName: String(ship.enemy.id)
                pickable: ship.live && ship.coreOpen
                source: "#Cylinder"
                eulerRotation.x: 90
                scale: Qt.vector3d(1.30, 1.23, 1.05)
                materials: [ports]
            }
            Model {
                source: "#Sphere"
                z: 65
                scale: Qt.vector3d(.84, .84, .28)
                opacity: ship.wreck ? .5 : (.74 + Math.sin(ship.clock * 5) * .25)
                materials: [warning]
            }
        }
        Model {
            visible: ship.barrier > 0
            source: "#Sphere"
            y: -54
            scale: Qt.vector3d(9.1, 4.82, 3.47)
            opacity: .19
            materials: [field]
        }
        Repeater3D {
            model: 10
            Model {
                required property int index
                readonly property real time: ship.clock * (6 + index % 3) + index * 7.87
                readonly property real cycle: ship.wreck ? (time - Math.floor(time)) : 1 - ship.shatter / .48
                visible: ship.wreck > 0 || ship.shatter > 0
                source: ship.wreck ? "#Sphere" : "#Cone"
                x: Math.cos(index * 2.4) * (275 + cycle * 124)
                y: Math.sin(index * 2.4) * (71 + cycle * 57)
                z: 109 + cycle * 80
                scale: Qt.vector3d(.08 + cycle * .49, .06 + cycle * .32, .08 + cycle * .31)
                opacity: 1 - cycle
                eulerRotation.z: index * 32
                materials: [ship.wreck ? warning : field]
            }
        }
    }
}
