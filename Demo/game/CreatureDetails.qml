import QtQuick
import QtQuick3D

Node {
    id: figure
    required property string kind
    required property int targetId
    required property color skin
    required property color accent
    required property real strike
    required property real age
    required property bool live
    required property bool anger
    property bool animate: true
    property var surfaces:null

    LitSurface {surfaces:figure.surfaces; id:body; baseColor:figure.skin; roughness:.62}
    PrincipledMaterial {
        id: light
        baseColor: figure.anger ? "#ff4d63" : figure.accent
        lighting: PrincipledMaterial.NoLighting
    }
    LitSurface {surfaces:figure.surfaces; id:voidSkin; baseColor:"#171023"; roughness:.86}
    LitSurface {surfaces:figure.surfaces; finish:"weave"; id:whiteFur; baseColor:figure.anger ? "#ffe3eb" : "#e8f7fa"; roughness:.94}
    LitSurface {surfaces:figure.surfaces; finish:"steel"; id:silver; baseColor:"#d8e7f2"; metalness:.84; roughness:.24}
    LitSurface {surfaces:figure.surfaces; finish:"stone"; id:stone; baseColor:"#4a2d37"; roughness:.88}
    PrincipledMaterial { id: embers; baseColor: "#ff6b36"; lighting: PrincipledMaterial.NoLighting }

    Loader3D {
        active: figure.kind === "gendoustagus"
        sourceComponent: Node {
            y: -23
            z: 45
            PrincipledMaterial { id: bone; baseColor: "#f2ddf4"; lighting: PrincipledMaterial.NoLighting }
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(.56,.49,.07)
                opacity: figure.animate ? .33 + .12 * Math.sin(figure.age * 5.6) : .38
                materials: [light]
            }
            Model {
                source: "#Sphere"
                y: 4
                z: 6
                scale: Qt.vector3d(.38,.32,.10)
                materials: [bone]
            }
            Model {
                source: "#Cube"
                y: -10
                z: 7
                scale: Qt.vector3d(.23,.13,.07)
                materials: [bone]
            }
            Repeater3D {
                model: [-1,1]
                Model {
                    required property int modelData
                    source: "#Sphere"
                    x: modelData * 8.5
                    y: 5
                    z: 12
                    scale: Qt.vector3d(.105,.115,.03)
                    materials: [voidSkin]
                }
            }
            Repeater3D {
                model: 3
                Model {
                    required property int index
                    source: "#Cube"
                    x: (index - 1) * 5.5
                    y: -10
                    z: 11
                    scale: Qt.vector3d(.016,.066,.016)
                    materials: [voidSkin]
                }
            }
            Model {
                source: "#Cone"
                y: -3
                z: 12
                scale: Qt.vector3d(.046,.042,.02)
                materials: [voidSkin]
            }
        }
    }
    Loader3D {
        active: figure.kind === "mystery"
        sourceComponent: Node {
            Model {
                objectName: String(figure.targetId)
                pickable: figure.live
                source: "#Sphere"
                y: 15
                scale: Qt.vector3d(.86, 1.26, .68)
                materials: [voidSkin]
            }
            Model {
                source: "#Sphere"
                y: 54
                z: 31
                scale: Qt.vector3d(.62, .63, .35)
                materials: [voidSkin]
            }
            Repeater3D {
                model: [-1, 1]
                Model {
                    required property int modelData
                    source: "#Sphere"
                    x: modelData * 12
                    y: 53
                    z: 51
                    scale: Qt.vector3d(.14, .19, .04)
                    materials: [light]
                }
            }
            Repeater3D {
                model: 6
                Node {
                    id: tendril
                    required property int index
                    readonly property real side: index < 3 ? -1 : 1
                    readonly property real sway: figure.animate ? Math.sin(figure.age * 6 - index * .97) : .1
                    x: side * (27 + index % 3 * 12)
                    y: 10 - index % 3 * 21
                    z: -4
                    eulerRotation.z: side * (54 + sway * 19 + figure.strike * 62)
                    Model {
                        source: "#Sphere"
                        y: -38
                        scale: Qt.vector3d(.26, .98, .20)
                        materials: [voidSkin]
                    }
                    Model {
                        source: "#Cone"
                        y: -87
                        x: tendril.side * -13
                        eulerRotation.z: 180 + tendril.side * 47
                        scale: Qt.vector3d(.18, .76, .13)
                        materials: [voidSkin]
                    }
                    Model {
                        source: "#Sphere"
                        y: -55
                        z: 10
                        scale: Qt.vector3d(.041, .55, .047)
                        opacity: .67
                        materials: [light]
                    }
                }
            }
        }
    }
    Loader3D {
        active: figure.kind === "meteor"
        sourceComponent: Node {
            eulerRotation.z: figure.animate ? figure.age * 38 : 18
            eulerRotation.y: figure.animate ? figure.age * 57 : 24
            Model {
                objectName: String(figure.targetId)
                pickable: figure.live
                source: "#Sphere"
                scale: Qt.vector3d(1.64, 1.31, 1.31)
                materials: [stone]
            }
            Repeater3D {
                model: 12
                Model {
                    required property int index
                    readonly property real angle: index * 2.4
                    source: "#Cube"
                    x: Math.cos(angle) * 57
                    y: Math.sin(angle) * 45
                    z: (index % 4 - 1.5) * 31
                    eulerRotation: Qt.vector3d(index * 31, index * 47, index * 73)
                    scale: Qt.vector3d(.42, .37, .41)
                    materials: [index % 3 ? body : stone]
                }
            }
            Repeater3D {
                model: 8
                Model {
                    required property int index
                    source: "#Cone"
                    x: Math.cos(index * 2.4) * 49
                    y: Math.sin(index * 2.4) * 47
                    z: -72 - index * 11
                    eulerRotation.x: -77
                    scale: Qt.vector3d(.27, .71 + index * .086, .28)
                    opacity: .60 - index * .049
                    materials: [index % 2 ? light : embers]
                }
            }
        }
    }
    Loader3D {
        active: figure.kind === "claptrap" || figure.kind === "jon"
        sourceComponent: Node {
            id: cockpit
            readonly property bool fighter: figure.kind === "jon"
            Model {
                objectName: String(figure.targetId)
                pickable: figure.live
                source: "#Sphere"
                scale: cockpit.fighter ? Qt.vector3d(.90, .58, 1.31) : Qt.vector3d(1.85, .45, 1.28)
                materials: [silver]
            }
            Model {
                objectName: String(figure.targetId)
                pickable: figure.live
                source: "#Sphere"
                y: 26
                z: 11
                scale: Qt.vector3d(.77, .48, .57)
                materials: [body]
            }
            Model {
                source: "#Sphere"
                y: 27
                z: 42
                scale: Qt.vector3d(.33, .24, .10)
                materials: [light]
            }
            Model {
                visible: figure.strike > .05
                source: "#Sphere"
                z: 86
                scale: Qt.vector3d(.21 + figure.strike * .38, .20 + figure.strike * .37, .6)
                opacity: Math.max(0, figure.strike)
                materials: [light]
            }
            Repeater3D {
                model: 6
                Model {
                    required property int index
                    readonly property real angle: index * Math.PI / 3
                    objectName: String(figure.targetId)
                    pickable: visible && figure.live
                    source: "#Cone"
                    visible: figure.kind === "claptrap" || index < 2
                    x: figure.kind === "jon" ? (index ? 70 : -70) : Math.cos(angle) * 73
                    y: figure.kind === "jon" ? -3 : -18
                    z: figure.kind === "jon" ? -39 : Math.sin(angle) * 51
                    eulerRotation.z: figure.kind === "jon" ? (index ? -113 : 113) : 163 + index * 8
                    scale: figure.kind === "jon" ? Qt.vector3d(.58, 1.07, .33) : Qt.vector3d(.18, .55, .17)
                    materials: [figure.kind === "jon" ? body : light]
                }
            }
        }
    }
    Loader3D {
        active: figure.kind === "nindumipus"
        sourceComponent: Node {
            Repeater3D {
                model: 6
                Model {
                    required property int index
                    readonly property int side: index < 3 ? -1 : 1
                    source: "#Cone"
                    x: side * (95 + 13 * (index % 3) - figure.strike * 17)
                    y: -38 + figure.strike * 57 - 8 * (index % 3)
                    z: 44 + figure.strike * 41
                    eulerRotation.z: side * (-31 + figure.strike * 103)
                    eulerRotation.x: -31 - 28 * figure.strike
                    scale: Qt.vector3d(.095, .58 - index % 3 * .07, .094)
                    materials: [silver]
                }
            }
        }
    }
    Loader3D {
        active: figure.kind === "iceterapus"
        sourceComponent: Node {
            Repeater3D {
                model: 18
                Model {
                    required property int index
                    readonly property real angle: index * 2.4
                    source: "#Cone"
                    x: Math.cos(angle) * 54
                    y: Math.sin(angle) * 61 - 8
                    z: 29 + index % 4 * 4
                    eulerRotation.z: index * 137.5 + 90
                    scale: Qt.vector3d(.29, .41 + index % 3 * .07, .27)
                    materials: [index % 4 ? whiteFur : body]
                }
            }
            Repeater3D {
                model: [-1, 1]
                Model {
                    required property int modelData
                    source: "#Sphere"
                    x: modelData * (64 + figure.strike * 26)
                    y: -12 + figure.strike * 51
                    z: 25 + figure.strike * 48
                    scale: Qt.vector3d(.36, .39, .34)
                    materials: [whiteFur]
                }
            }
        }
    }
}
