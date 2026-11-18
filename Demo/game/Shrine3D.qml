import QtQuick
import QtQuick3D

View3D {
    id: courtyard
    objectName: "shrine3D"

    property bool motion: true
    property real orbit: 0
    property real elapsed: 0

    explicitTextureWidth: Math.round(Math.min(width * Screen.devicePixelRatio, 1600))
    explicitTextureHeight: width > 0 ? Math.round(explicitTextureWidth * height / width) : 0
    camera: eye
    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Color
        clearColor: "#272641"
        antialiasingMode: SceneEnvironment.MSAA
        antialiasingQuality: SceneEnvironment.Medium
    }

    PrincipledMaterial { id: gravel; baseColor: "#47465a"; roughness: 0.96 }
    PrincipledMaterial { id: stone; baseColor: "#777584"; roughness: 0.94 }
    PrincipledMaterial { id: lacquer; baseColor: "#a84138"; roughness: 0.65 }
    PrincipledMaterial { id: wood; baseColor: "#433443"; roughness: 0.95 }
    PrincipledMaterial { id: needles; baseColor: "#263c44"; roughness: 0.92 }
    PrincipledMaterial { id: paper; baseColor: "#ffd19a"; lighting: PrincipledMaterial.NoLighting }

    Node {
        y: 60
        z: -260
        eulerRotation.y: courtyard.orbit
        PerspectiveCamera {
            id: eye
            y: 177
            z: 780
            eulerRotation.x: -13
            fieldOfView: 48
            clipNear: 8
            clipFar: 6000
        }
    }
    DirectionalLight {
        eulerRotation: Qt.vector3d(-33, -44, 0)
        color: "#cbcfff"
        ambientColor: "#5f607a"
        brightness: 1.3
        castsShadow: true
    }
    PointLight {
        position: Qt.vector3d(105, 145, -230)
        color: "#ff9957"
        brightness: 3.0 + 0.32 * Math.sin(courtyard.elapsed * 3.7)
        quadraticFade: 0.27
    }
    FrameAnimation {
        running: courtyard.motion
        onTriggered: courtyard.elapsed += frameTime
    }
    Model {
        source: "#Cube"
        y: -17
        z: -720
        scale: Qt.vector3d(31, 0.25, 37)
        materials: [gravel]
    }
    Repeater3D {
        model: 19
        delegate: Model {
            required property int index
            source: "#Cube"
            z: 540 - index * 88
            x: Math.sin(index * 1.9) * 7
            y: -2
            eulerRotation.y: Math.sin(index) * 4
            scale: Qt.vector3d(1.62, 0.14, 0.68)
            materials: [stone]
        }
    }
    Repeater3D {
        model: [-1, 1]
        delegate: Node {
            required property int modelData
            x: 116 * modelData
            z: -260

            Model {
                source: "#Cylinder"
                y: 124
                scale: Qt.vector3d(0.37, 2.56, 0.37)
                materials: [lacquer]
            }
            Model {
                source: "#Cube"
                y: 15
                scale: Qt.vector3d(0.48, 0.3, 0.48)
                materials: [stone]
            }
            Model {
                source: "#Cube"
                x: modelData * 46
                y: 92
                z: 80
                scale: Qt.vector3d(0.29, 0.39, 0.29)
                materials: [paper]
            }
            Model {
                source: "#Cone"
                x: modelData * 46
                y: 118
                z: 80
                scale: Qt.vector3d(0.50, 0.21, 0.50)
                materials: [wood]
            }
        }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 258, -260)
        scale: Qt.vector3d(3.35, 0.22, 0.53)
        materials: [lacquer]
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 278, -260)
        scale: Qt.vector3d(3.61, 0.16, 0.64)
        materials: [wood]
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 201, -260)
        scale: Qt.vector3d(2.89, 0.14, 0.30)
        materials: [lacquer]
    }
    Repeater3D {
        model: 20
        delegate: Node {
            required property int index
            x: (index % 2 === 0 ? -1 : 1) * (220 + (index * 62 % 245))
            z: 470 - Math.floor(index / 2) * 166
            scale: Qt.vector3d(0.8 + index % 5 * 0.07, 0.85 + index % 7 * 0.10, 0.88)

            Model {
                source: "#Cylinder"
                y: 94
                scale: Qt.vector3d(0.25, 1.89, 0.25)
                materials: [wood]
            }
            Model {
                source: "#Cone"
                y: 207
                scale: Qt.vector3d(1.75, 2.69, 1.73)
                materials: [needles]
            }
            Model {
                source: "#Cone"
                y: 294
                scale: Qt.vector3d(1.14, 1.85, 1.12)
                materials: [needles]
            }
        }
    }
}
