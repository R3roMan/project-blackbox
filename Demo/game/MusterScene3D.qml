import QtQuick
import QtQuick3D
import "MusterData.js" as Muster
import "Encounters.js" as Mission

View3D {
    id: scene
    objectName:"enemyMusterViewport"
    required property var company
    required property var placements
    property bool motion: true
    property real clock: 0
    property int revision: 0
    function indexAt(x,y) {
        for (const hit of pickAll(x,y)) {
            const index=Number(hit.objectHit?.objectName)-1
            if (index >= 0 && index < company.length)
                return index
        }
        return -1
    }
    readonly property real radius:Muster.radius(company,placements,width/Math.max(1,height))
    explicitTextureWidth: Math.max(1,Math.round(Math.min(2560,width*Screen.devicePixelRatio)))
    explicitTextureHeight: Math.max(1,Math.round(explicitTextureWidth*height/Math.max(1,width)))
    camera:previewCamera
    Timer {
        interval:42
        repeat:true
        running:scene.visible && scene.motion
        onTriggered:scene.clock=(scene.clock+.042)%60
    }
    onClockChanged:revision += 1
    environment: SceneEnvironment {
        backgroundMode:SceneEnvironment.Transparent
        antialiasingMode:SceneEnvironment.MSAA
        antialiasingQuality:SceneEnvironment.Medium
    }
    OrthographicCamera {
        id:previewCamera
        z:750; y:12
        horizontalMagnification:Math.max(.001,scene.height/(2*scene.radius))
        verticalMagnification:horizontalMagnification
        clipNear:1; clipFar:2000
    }
    DirectionalLight {eulerRotation:Qt.vector3d(-25,-26,0); brightness:2.5; color:"#ffe0cf"; ambientColor:"#726c89"}
    DirectionalLight {eulerRotation:Qt.vector3d(12,143,0); brightness:2.2; color:"#bdd2ff"}
    Repeater3D {
        model:scene.company
        delegate:Node {
            id:figure
            required property var modelData
            required property int index
            property var enemy:{
                const actor=Muster.actor(modelData.type)
                actor.id=index+1
                return actor
            }
            readonly property var spot:scene.placements[index] || {x:.5,y:.5}
            x:(spot.x-.5)*2*scene.radius*scene.width/Math.max(1,scene.height)
            y:(.5-spot.y)*2*scene.radius+Math.sin(scene.clock*1.7+index*1.2)*5
            z:-index%3*4
            eulerRotation.z:Math.sin(scene.clock*1.3+index)*2.3
            Connections {
                target:scene
                function onClockChanged() {figure.enemy.age=scene.clock+figure.index*.731}
            }
            Threat3D {enemy:figure.enemy; revision:scene.revision; animate:scene.motion; preview:true}
        }
    }
}
