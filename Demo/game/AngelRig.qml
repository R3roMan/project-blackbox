import QtQuick
import QtQuick3D
import "AttackArt.js" as Art

Node {
    id: figure
    property var surfaces:null
    required property int targetId
    required property string kind
    required property color skin
    required property color glow
    required property real strike
    required property real age
    property real fuse: 0
    required property bool cover
    required property bool live
    property bool animate: true
    property bool rushing: false
    readonly property bool fallenBoss: kind === "lucifoverus"

    LitSurface { surfaces:figure.surfaces; finish:"weave"; id:robe; baseColor: figure.skin; roughness: .82 }
    LitSurface { surfaces:figure.surfaces; finish:"weave"; id:seam; baseColor: figure.fallenBoss ? "#efa962" : "#c9c6c9"; roughness: .56; metalness: figure.fallenBoss ? .64 : 0 }
    LitSurface { surfaces:figure.surfaces; finish:"bone"; id:carbon; baseColor:"#15121c"; roughness:.68 }
    PrincipledMaterial { id: gleam; baseColor: figure.glow; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: bloodlight; baseColor: "#fb446c"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: tears; baseColor: "#86b2cc"; metalness: .27; roughness: .20 }
    PrincipledMaterial { id: haloEdge; baseColor: figure.fallenBoss ? "#ce785d" : "#8e83a1"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: haloBlack; baseColor: "#171019"; lighting: PrincipledMaterial.NoLighting }
    SickleHornGeometry {id:horn; textured:!!figure.surfaces?.detailed}
    ScallopedWingGeometry {id:wing; textured:!!figure.surfaces?.detailed}
    LitSurface { surfaces:figure.surfaces; finish:"wing"; id:membrane; baseColor:figure.fallenBoss ? "#631d32" : "#362d41"; roughness:.72; cullMode:Material.NoCulling }
    LitSurface { surfaces:figure.surfaces; finish:"horn"; id:ivory; baseColor:figure.fallenBoss ? "#cd6143" : "#a29ba6"; roughness:.61; cullMode:Material.NoCulling }

    Model {
        objectName: String(figure.targetId)
        pickable: figure.live
        source: "#Cone"
        y: -22
        scale: Qt.vector3d(1.70, 1.82, .80)
        materials: [robe]
    }
    Model {
        objectName: String(figure.targetId)
        pickable: figure.live
        source: "#Sphere"
        y: 34
        scale: Qt.vector3d(1.08, .95, .83)
        materials: [robe]
    }
    Repeater3D {
        model: 5
        Model {
            required property int index
            source: "#Cube"
            y: -31
            x: (index - 2) * 22
            z: 26 - Math.abs(index - 2) * 2
            eulerRotation.z: (index - 2) * -12
            scale: Qt.vector3d(.035, 1.16, .05)
            opacity: .52
            materials: [index === 2 ? seam : carbon]
        }
    }
    Model {
        objectName: String(figure.targetId)
        pickable: figure.live
        source: "#Sphere"
        y: 70
        z: 13
        scale: Qt.vector3d(.58, .66, .57)
        materials: [figure.kind === "jos" ? robe : carbon]
    }
    Repeater3D {
        model: 20
        delegate: Node {
            required property int index
            readonly property real angle: index * Math.PI / 10
            x: Math.cos(angle) * 50
            y: 132 + Math.sin(angle) * 22
            z: Math.sin(angle) * 38 + 9
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(.186,.091,.167)
                materials: [haloEdge]
            }
            Model {
                source: "#Sphere"
                z: 4
                scale: Qt.vector3d(.175,.075,.151)
                materials: [haloBlack]
            }
        }
    }
    Repeater3D {
        model: [-1, 1]
        Node {
            id: side
            required property int modelData
            readonly property int sign: modelData
            Model {
                geometry:horn; x:side.sign*19; y:89; z:16
                scale:Qt.vector3d(side.sign*.65,.62,.62)
                materials:[ivory]
            }
            Model {
                visible: !figure.cover
                source: "#Sphere"
                x: side.sign * 13
                y: 75
                z: 39
                scale: Qt.vector3d(.14, .105, .06)
                materials: [gleam]
            }
            Model {
                visible: figure.kind === "jos" && !figure.cover
                source: "#Sphere"
                x: side.sign * 13
                y: 60 - (figure.animate ? (figure.age * 24 % 14) : 0)
                z: 37
                scale: Qt.vector3d(.035, .114, .041)
                materials: [tears]
            }
            Model {
                objectName: String(figure.targetId)
                pickable: figure.live
                geometry:wing
                x:side.sign*49; y:33; z:-27
                eulerRotation.y:side.sign*(12+figure.strike*24)
                scale:Qt.vector3d(side.sign*1.1,1.14,1.04)
                materials:[membrane]
            }
            Model {
                objectName: String(figure.targetId)
                pickable: figure.live
                source: "#Sphere"
                x: side.sign * (figure.cover ? 34 : 54 - figure.strike * 15)
                y: figure.cover ? 53 : 7 + figure.strike * 20
                z: 31
                eulerRotation.z: side.sign * (figure.cover ? -35 : 23 + figure.strike * 44)
                scale: Qt.vector3d(.27, .81, .27)
                materials: [robe]
            }
            Model {
                source: "#Sphere"
                x: side.sign * (figure.cover ? 12 : 62 - figure.strike * 31)
                y: figure.cover ? 77 : -20 + figure.strike * 40
                z: figure.cover ? 48 : 43 + 30 * Math.abs(figure.strike)
                scale: Qt.vector3d(.26, .30, .20)
                materials: [figure.kind === "jos" ? robe : seam]
            }
        }
    }
    Loader3D {
        active: figure.kind === "seraphijus"
        sourceComponent: Node {
            y: 17
            z: 45
            PrincipledMaterial { id: plateRim; baseColor: "#c2ab94"; metalness: .46; roughness: .6 }
            PrincipledMaterial {
                id: litSegment
                baseColor: figure.fuse <= 4 ? "#ff7978" : "#ffe3b0"
                lighting: PrincipledMaterial.NoLighting
            }
            Model {
                source: "#Cube"
                scale: Qt.vector3d(.74,.56,.13)
                materials: [plateRim]
            }
            Model {
                source: "#Cube"
                z: 7
                scale: Qt.vector3d(.66,.47,.027)
                materials: [carbon]
            }
            Repeater3D {
                model: 14
                Model {
                    required property int index
                    readonly property var segment: Art.segments[index % 7]
                    source: "#Cube"
                    x: (index < 7 ? -15 : 15) + segment[0] * 20
                    y: -segment[1] * 18
                    z: 10
                    scale: Qt.vector3d(segment[2] * .18, segment[3] * .18, .014)
                    opacity: Art.countdownSegment(figure.fuse, index) ? 1 : .10
                    materials: [litSegment]
                }
            }
        }
    }

    Repeater3D {
        model: figure.fallenBoss ? 18 : 0
        Model {
            required property int index
            readonly property real orbit: index * 2.399 + (figure.animate ? figure.age * (1 + index % 3 * .26) : 0)
            readonly property real flare: figure.animate ? (.54 + .35 * Math.sin(figure.age * 8 + index * 1.77)) : .5
            readonly property real size: .035 + flare * .095 + Math.abs(figure.strike) * .035
            source: index % 3 ? "#Sphere" : "#Cone"
            x: Math.cos(orbit) * (88 + index % 5 * 17)
            y: -22 + index % 7 * 23 + 17 * Math.sin(orbit * 2)
            z: Math.sin(orbit) * (69 + index % 4 * 16)
            eulerRotation.z: orbit * 57
            scale: Qt.vector3d(size, size * 1.4, size)
            opacity: flare
            materials: [index % 3 ? bloodlight : gleam]
        }
    }
    Node {
        visible: figure.kind === "lucifoverus"
        x: figure.rushing ? 43 : 71 - 35 * Math.abs(figure.strike)
        y: 10
        z: 45 + Math.abs(figure.strike) * 36
        eulerRotation: Qt.vector3d(figure.rushing ? 87 : 76 * Math.abs(figure.strike),
            figure.rushing ? -13 : 0, figure.rushing ? -3 : -13)
        Model {
            source: "#Cylinder"
            scale: Qt.vector3d(.085, 1.87, .085)
            materials: [carbon]
        }
        Model {
            source: "#Cube"
            y: 76
            scale: Qt.vector3d(.58, .085, .105)
            materials: [seam]
        }
        Repeater3D {
            model: 3
            Model {
                required property int index
                source: "#Cone"
                x: (index - 1) * 27
                y: index === 1 ? 110 : 98
                scale: Qt.vector3d(.19, index === 1 ? .62 : .44, .13)
                materials: [gleam]
            }
        }
    }
}
