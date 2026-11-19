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
    property int detail:1
    readonly property bool ultra:detail===3
    SurfaceSet {id:materials;detailed:scene.ultra}
    property real clock: 0
    property int revision: 0
    function indexAt(x,y) {
        for (const hit of pickAll(x,y)) {
            const index=Number((hit.objectHit?.objectName || "").split(":").pop())-1
            if (index >= 0 && index < company.length)
                return index
        }
        // The frame can precede the scene's pick data during a resize or
        // reopen. Test the projected bodies at their current animated poses.
        let selected=-1, nearest=1
        for (let index=0;index<figures.count;++index) {
            const figure=figures.objectAt(index)
            if (!figure) continue
            const centre=mapFrom3DScene(figure.scenePosition)
            const size=Muster.displaySize(Mission.enemyTypes[figure.enemy.type])*previewCamera.verticalMagnification
            const distance=Math.hypot((x-centre.x)/(82*size),(y-centre.y+15*size)/(90*size))
            if (distance < nearest) {
                selected=index
                nearest=distance
            }
        }
        return selected
    }
    readonly property real radius:Muster.radius(company,placements,width/Math.max(1,height))
    explicitTextureWidth: Math.max(1,Math.round(Math.min(scene.ultra ? 3840 : 2560,width*Screen.devicePixelRatio)))
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
        antialiasingMode:scene.detail>0 ? SceneEnvironment.MSAA : SceneEnvironment.NoAA
        antialiasingQuality:scene.detail===2 ? SceneEnvironment.High : SceneEnvironment.Medium
        lightProbe:scene.ultra ? materials.lightProbe : null
        probeExposure:.44
        tonemapMode:scene.ultra ? SceneEnvironment.TonemapModeAces : SceneEnvironment.TonemapModeLinear
        aoEnabled:scene.ultra
        aoStrength:46
        aoDistance:39
        aoBias:1.2
    }
    OrthographicCamera {
        id:previewCamera
        z:750; y:12
        horizontalMagnification:Math.max(.001,scene.height/(2*scene.radius))
        verticalMagnification:horizontalMagnification
        clipNear:1; clipFar:2000
    }
    DirectionalLight {eulerRotation:Qt.vector3d(-25,-26,0); brightness:scene.ultra ? 1.55 : 1.35; color:"#fff5e9"; ambientColor:"#554f52"}
    DirectionalLight {eulerRotation:Qt.vector3d(12,143,0); brightness:.58; color:"#d6e1eb"}
    Repeater3D {
        id:figures
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
            readonly property real modelScale:Muster.displaySize(Mission.enemyTypes[enemy.type])/Mission.enemyTypes[enemy.type].size
            scale:Qt.vector3d(modelScale,modelScale,modelScale)
            eulerRotation.z:Math.sin(scene.clock*1.3+index)*2.3
            Connections {
                target:scene
                function onClockChanged() {figure.enemy.age=scene.clock+figure.index*.731}
            }
            Threat3D {enemy:figure.enemy; revision:scene.revision; animate:scene.motion; preview:true;surfaces:scene.ultra ? materials : null}
        }
    }
}
