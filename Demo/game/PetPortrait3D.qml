import QtQuick
import QtQuick3D

View3D {
    id: portrait
    required property var helper
    property bool detailed:false
    property bool animate:false
    property real clock:0
    explicitTextureWidth:Math.max(1,Math.min(520,Math.round(width*Screen.devicePixelRatio)))
    explicitTextureHeight:Math.max(1,Math.round(explicitTextureWidth*height/Math.max(1,width)))
    camera:eye
    environment:SceneEnvironment {
        backgroundMode:SceneEnvironment.Transparent
        antialiasingMode:SceneEnvironment.MSAA
        antialiasingQuality:SceneEnvironment.Medium
    }
    OrthographicCamera {
        id:eye
        z:240
        y:0
        horizontalMagnification:Math.max(.01,Math.min(portrait.width/152,portrait.height/105))
        verticalMagnification:horizontalMagnification
    }
    DirectionalLight { eulerRotation:Qt.vector3d(-29,-34,0); brightness:2.1; color:"#ffe1bd"; ambientColor:"#69637c" }
    DirectionalLight { eulerRotation:Qt.vector3d(11,141,0); brightness:1.7; color:"#b4cfff" }
    PetModel {helper:portrait.helper; phase:portrait.clock; strike:0; detailed:portrait.detailed; animate:portrait.animate; eulerRotation:Qt.vector3d(-7,-18,0)}
}
