import QtQuick
import QtQuick3D
import "Rules.js" as Rules
import "MusterData.js" as Muster

View3D {
    id: portrait
    required property string enemyType
    property bool motion: true
    property real modelScale:1
    property real clock: 0
    property int revision: 0
    property var enemy: Muster.actor(enemyType)
    readonly property var spec: Rules.enemyTypes[enemyType]
    explicitTextureWidth: Math.max(1,Math.round(Math.min(600,width*Screen.devicePixelRatio)))
    explicitTextureHeight: Math.max(1,Math.round(explicitTextureWidth*height/Math.max(1,width)))
    renderMode: View3D.Offscreen
    camera:portraitCamera
    onClockChanged: {
        enemy.age = clock
        revision += 1
    }
    Timer {
        interval:42
        repeat:true
        running: portrait.visible && portrait.motion
        onTriggered:portrait.clock=(portrait.clock+.042)%60
    }
    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Transparent
        antialiasingMode: SceneEnvironment.MSAA
        antialiasingQuality: SceneEnvironment.Medium
    }
    PerspectiveCamera {
        id:portraitCamera
        z:410
        y:10
        fieldOfView:2*Math.atan(Math.max(220*portrait.modelScale,150*portrait.height/Math.max(1,portrait.width))/z)*180/Math.PI
        clipNear:1
        clipFar:1000
    }
    DirectionalLight { eulerRotation:Qt.vector3d(-24,-33,0); brightness:1.35; color:"#fff5e9"; ambientColor:"#554f52" }
    DirectionalLight { eulerRotation:Qt.vector3d(14,136,0); brightness:.58; color:"#d6e1eb" }
    Node {
        readonly property real proportion: (portrait.spec.ship ? .31 : 1/portrait.spec.size)*portrait.modelScale
        scale: Qt.vector3d(proportion,proportion,proportion)
        y: portrait.spec.ship ? 23 : 0
        z: Math.sin(portrait.clock*1.13)*3
        eulerRotation.z: Math.sin(portrait.clock*1.57)*2
        Loader3D {
            sourceComponent: portrait.spec.ship ? carrier : creature
        }
        Component {
            id: creature
            Threat3D {
                enemy: portrait.enemy
                revision: portrait.revision
                animate: portrait.motion
                preview:true
            }
        }
        Component {
            id: carrier
            ShipModel {
                enemy: portrait.enemy
                revision: portrait.revision
                animate: portrait.motion
            }
        }
    }
}
