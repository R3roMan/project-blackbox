import QtQuick
import QtQuick3D

Node {
    id: slime
    property Material iceMaterial:null
    property var surfaces:null

    required property int targetId
    required property bool horned
    required property bool live
    required property bool warning
    required property bool motion
    required property color skin
    required property color accent
    required property real age
    required property real strike

    readonly property real gape: Math.max(Math.max(0, strike), warning ? .49 : 0)
    readonly property real jiggle: motion ? Math.sin(age * 7) : 0
    readonly property real heave: motion ? Math.sin(age * 4) : .15

    LitSurface {
        id: flesh
        surfaces:slime.surfaces
        finish:"bone"
        normalStrength:.27
        baseColor: slime.skin
        roughness: .23
        specularAmount: .78
    }
    PrincipledMaterial {
        id: mucous
        baseColor: Qt.lighter(slime.skin, 1.57)
        roughness: .17
        specularAmount: .92
    }
    PrincipledMaterial { id: darkness; baseColor: "#171e0a"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: pupil; baseColor: "#21140c"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: glow; baseColor: slime.accent; lighting: PrincipledMaterial.NoLighting }
    LitSurface {surfaces:slime.surfaces; finish:"bone"; id:teeth; baseColor:"#d4c58a"; roughness:.52}
    LitSurface {surfaces:slime.surfaces; finish:"horn"; id:horn; baseColor:"#62522e"; roughness:.60}

    Model {
        source: "#Sphere"
        objectName: String(slime.targetId)
        pickable: slime.live
        y: -13
        scale: Qt.vector3d(1.77 + slime.jiggle * .052, 1.20 - slime.jiggle * .061, 1.02)
        materials: slime.iceMaterial ? [slime.iceMaterial] : ([flesh])
    }
    Model {
        source: "#Sphere"
        objectName: String(slime.targetId)
        pickable: slime.live
        y: 30 + slime.heave * 2.5
        z: 31
        scale: Qt.vector3d(1.40, .79, .82)
        materials: slime.iceMaterial ? [slime.iceMaterial] : ([mucous])
    }
    Model { objectName:"eye:"+slime.targetId; pickable:slime.live;
        source: "#Sphere"
        y: 54
        z: 70
        scale: Qt.vector3d(.36, .23, .115)
        materials: slime.iceMaterial ? [slime.iceMaterial] : ([glow])
    }
    Model { objectName:"eye:"+slime.targetId; pickable:slime.live;
        source: "#Sphere"
        y: 55
        z: 76
        scale: Qt.vector3d(.09, .18, .04)
        materials: slime.iceMaterial ? [slime.iceMaterial] : ([pupil])
    }
    Model {
        source: "#Sphere"
        y: 55
        x: -8
        z: 78
        scale: Qt.vector3d(.04,.043,.04)
        materials: slime.iceMaterial ? [slime.iceMaterial] : ([teeth])
    }
    Model {
        source: "#Sphere"
        objectName: String(slime.targetId)
        pickable: slime.live
        y: -6 - slime.gape * 12
        z: 56
        scale: Qt.vector3d(1.12, .47 + slime.gape * .25, .33)
        materials: slime.iceMaterial ? [slime.iceMaterial] : ([mucous])
    }
    Model {
        source: "#Sphere"
        y: 14 - slime.gape * 10
        z: 74
        scale: Qt.vector3d(.86, .22 + slime.gape * .54, .11)
        materials: slime.iceMaterial ? [slime.iceMaterial] : ([darkness])
    }

    Repeater3D {
        model: slime.horned ? 8 : 3
        Model {
            required property int index
            readonly property bool lower: slime.horned && index > 4
            source: "#Cone"
            x: slime.horned ? (lower ? (index - 6) * 21 : (index - 2) * 14) : (index - 1) * 18
            y: lower ? 7 - slime.gape * 29 : 23 + slime.gape * 6 - Math.abs(x) * .075
            z: 79
            eulerRotation.z: lower ? -9 : 173 + index * 4
            scale: Qt.vector3d(.078, index % 3 === 0 ? .17 : .124, .069)
            materials: slime.iceMaterial ? [slime.iceMaterial] : ([teeth])
        }
    }

    Repeater3D {
        model: [-1, 1]
        Node {
            id: side
            required property int modelData
            x: modelData * 59
            y: 5
            z: -17
            eulerRotation.z: modelData * (12 + slime.heave * 18 - slime.gape * 9)
            Model {
                source: "#Cone"
                objectName: String(slime.targetId)
                pickable: slime.live
                x: side.modelData * 38
                y: 12
                eulerRotation.z: -side.modelData * 66
                scale: Qt.vector3d(slime.horned ? .66 : .55, slime.horned ? 1.13 : .88, .19)
                materials: slime.iceMaterial ? [slime.iceMaterial] : ([flesh])
            }
            Model {
                source: "#Sphere"
                x: side.modelData * 70
                y: -20 + slime.jiggle * 5
                scale: Qt.vector3d(.13, .32, .14)
                materials: slime.iceMaterial ? [slime.iceMaterial] : ([mucous])
            }
        }
    }

    Repeater3D {
        model: slime.horned ? [-1, 1] : []
        Node {
            id: tusk
            required property int modelData
            x: modelData * 45
            y: 67
            z: 23
            eulerRotation.z: -modelData * 24
            Model {
                source: "#Cone"
                objectName:"outer:"+slime.targetId
                pickable:slime.live
                scale: Qt.vector3d(.41,.73,.32)
                materials: slime.iceMaterial ? [slime.iceMaterial] : ([horn])
            }
            Model {
                source: "#Cone"
                x: tusk.modelData * 21
                y: 29
                eulerRotation.z: tusk.modelData * 13
                scale: Qt.vector3d(.19,.54,.22)
                materials: slime.iceMaterial ? [slime.iceMaterial] : ([teeth])
            }
        }
    }

    Repeater3D {
        model: slime.horned ? 12 : 8
        Model {
            required property int index
            readonly property real oscillation: slime.motion ? (slime.age * (.55 + index % 3 * .16) + index * .37) % 1 : .4
            source: "#Sphere"
            x: (index % 6 - 2.5) * 21 + Math.sin(index * 66) * 8
            y: -12 - oscillation * (38 + index % 5 * 12)
            z: 39 + (index % 3) * 9
            scale: Qt.vector3d(.075 + index % 3 * .019, .12 + oscillation * .15, .081)
            opacity: .95 - oscillation * .65
            materials: slime.iceMaterial ? [slime.iceMaterial] : ([index % 3 ? mucous : glow])
        }
    }
}
