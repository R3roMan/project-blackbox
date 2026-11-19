pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import "MeleeArt.js" as Art

Node {
    id: rig
    property var surfaces:null
    required property string weaponId
    required property color accent
    property real action: 0
    property real spin: 0
    property bool primed: false
    property bool held: false
    property real clock: 0

    function skin(key) {
        switch (key) {
        case "wood": return wood
        case "metal": return steel
        case "white": return edge
        case "accent": return glow
        case "bronze": return brass
        case "wrap": return wrap
        case "red": return red
        case "shadow": return shadow
        default: return dark
        }
    }

    LitSurface { surfaces:rig.surfaces; finish:"weave"; id:wood; baseColor: "#805334"; roughness: .73 }
    LitSurface { surfaces:rig.surfaces; finish:"steel"; id:steel; baseColor:"#9298a9"; roughness:rig.surfaces?.detailed ? .17 : .23; metalness:.81
        specularAmount:.86;clearcoatAmount:rig.surfaces?.detailed ? .55 : 0 }
    LitSurface { surfaces:rig.surfaces; finish:"steel"; id:edge; baseColor:"#e4effd"; roughness:rig.surfaces?.detailed ? .11 : .18; metalness:.74;
        specularAmount:.92;clearcoatAmount:rig.surfaces?.detailed ? .65 : 0; emissiveFactor: Qt.vector3d(.11,.13,.17) }
    PrincipledMaterial { id: dark; baseColor: "#222532"; roughness: .52; metalness: .42 }
    LitSurface { surfaces:rig.surfaces; finish:"weave"; id:wrap; baseColor: "#592439"; roughness: .92 }
    LitSurface { surfaces:rig.surfaces; finish:"steel"; id:brass; baseColor: "#b78154"; roughness: .37; metalness: .60 }
    PrincipledMaterial { id: glow; baseColor: rig.primed ? Qt.lighter(rig.accent, 1.35) : rig.accent; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: shadow; baseColor: "#130921"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: red; baseColor: "#9c342e"; roughness: .39; metalness: .52 }

    Loader3D {
        active: rig.weaponId === "katana"
        sourceComponent: Node {
            Repeater3D {
                model: [false,true]
                delegate: Model {
                    id: katanaFace
                    required property bool modelData
                    readonly property var blade: Art.katanaBlade(modelData)
                    geometry: ProceduralMesh {
                        positions: katanaFace.blade.positions
                        normals: katanaFace.blade.normals
                        indexes: katanaFace.blade.indexes
                    }
                    materials: [modelData ? edge : steel]
                }
            }
            Repeater3D {
                model: 9
                delegate: Model {
                    required property int index
                    source: "#Cylinder"
                    z: -24+index*8
                    scale: Qt.vector3d(.204,.028,.204)
                    eulerRotation: Qt.vector3d(90,0,index%2 ? 5 : -5)
                    materials: [dark]
                }
            }
        }
    }

    Repeater3D {
        model: rig.weaponId === "duoknives" ? 2 : 1
        delegate: Node {
            required property int index
            readonly property bool dual: rig.weaponId === "duoknives"
            readonly property int side: index ? 1 : -1
            x: dual ? side * 70 : 0
            y: dual ? 13 * index : 0
            eulerRotation.x: dual ? side * rig.action * 360 : 0
            eulerRotation.z: dual ? side * 24 : 0
            eulerRotation.y: dual ? side * 31 : 0
            Repeater3D {
                model: Art.parts[rig.weaponId]
                delegate: Model {
                    required property var modelData
                    readonly property bool saberEdge: rig.weaponId === "darksaber" && modelData.z < -60
                    readonly property bool rail: rig.weaponId === "mechasword" && modelData.z < -93
                    readonly property real emission: saberEdge ? 1-.055*rig.action : 1
                    source: modelData.mesh
                    x: modelData.x
                    y: modelData.y
                    z: saberEdge ? -50 + (modelData.z + 50) * emission : modelData.z - (rail ? rig.action * 16 : 0)
                    eulerRotation: Qt.vector3d(modelData.pitch, modelData.yaw, modelData.roll)
                    scale: Qt.vector3d(modelData.width / 100, modelData.height / 100, modelData.length * emission / 100)
                    materials: [rig.skin(modelData.material)]
                }
            }
            Model {
                visible: rig.held
                source: "#Sphere"
                x: 8
                y: 9
                z: rig.weaponId === "chainsaw" ? 37 : 34
                scale: Qt.vector3d(.35,.23,.42)
                materials: [dark]
            }
            Repeater3D {
                model: rig.held ? 4 : 0
                delegate: Model {
                    required property int index
                    source: "#Cube"
                    x: 14
                    y: 13
                    z: 22 + index*7
                    eulerRotation.z: -32
                    scale: Qt.vector3d(.15,.17,.039)
                    materials: [index === 0 ? edge : steel]
                }
            }
        }
    }

    Repeater3D {
        model: rig.weaponId === "nailclub" ? 11 : 0
        delegate: Model {
            required property int index
            readonly property real angle: index * 2.399
            source: "#Cone"
            x: Math.sin(angle) * 21
            y: Math.cos(angle) * 21
            z: -32 - index * 9.5
            eulerRotation.z: -angle * 180 / Math.PI
            scale: Qt.vector3d(.08,.33,.08)
            materials: [steel]
        }
    }
    Repeater3D {
        model: rig.weaponId === "chainsaw" ? 18 : 0
        delegate: Model {
            required property int index
            readonly property real turn: index * Math.PI / 9 + rig.spin * Math.PI / 180
            source: "#Cone"
            x: Math.sin(turn) * 28
            y: 3
            z: -118 + Math.cos(turn) * 103
            eulerRotation: Qt.vector3d(90, turn * 180 / Math.PI, 0)
            scale: Qt.vector3d(.09,.19,.09)
            materials: [edge]
        }
    }
    Model {
        visible: rig.weaponId === "chainsaw" && rig.action > .1
        source: "#Cube"
        x: 30 + rig.action * 21
        z: 19 + rig.action * 47
        eulerRotation.y: 27
        scale: Qt.vector3d(.042,.042,.85 * rig.action)
        materials: [glow]
    }
    Repeater3D {
        model: rig.weaponId === "helltrident" ? 12 : 0
        delegate: Model {
            required property int index
            readonly property real drift: (rig.clock * (1.9 + index%3*.19) + index*.193)%1
            source: "#Cone"
            x: (index%3-1)*23 + Math.sin(drift*6+index)*7
            y: 4 + drift*39
            z: -146 - (index%3 === 1 ? 21 : 1) - drift*14
            eulerRotation.z: (index%3-1)*11
            opacity: (1-drift)*.70
            scale: Qt.vector3d(.07+rig.action*.04, .09+drift*.19, .07)
            materials: [index%4 ? glow : edge]
        }
    }
}
