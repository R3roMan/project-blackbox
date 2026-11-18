import QtQuick
import QtQuick3D

View3D {
    id:shaft
    required property real progress
    required property bool returning
    property real strength:1
    explicitTextureWidth:Math.max(1,Math.round(Math.min(1440,width*Screen.devicePixelRatio)))
    explicitTextureHeight:Math.max(1,Math.round(explicitTextureWidth*height/Math.max(1,width)))
    environment:SceneEnvironment {backgroundMode:SceneEnvironment.Transparent}
    PerspectiveCamera {
        y:-(shaft.returning ? 1-shaft.progress : shaft.progress)*950
        fieldOfView:58+Math.sin(shaft.progress*Math.PI)*5*shaft.strength
        clipNear:2; clipFar:3000
    }
    PointLight {y:-440; z:50; color:"#7165b4"; brightness:4; quadraticFade:.7}
    DirectionalLight {eulerRotation:Qt.vector3d(-27,29,0); color:"#5b7097"; brightness:1.5; ambientColor:"#15101e"}
    PrincipledMaterial {id:rock; baseColor:"#16121d"; roughness:.92}
    PrincipledMaterial {id:vein; baseColor:"#554b87"; emissiveFactor:Qt.vector3d(.04,.02,.12); roughness:.72}
    Repeater3D {
        model:48
        delegate:Model {
            required property int index
            readonly property int row:Math.floor(index/4)
            source:index%4 === 3 ? "#Cone" : "#Sphere"
            x:(index%2 ? 1 : -1)*(225+index%3*43)
            y:190-row*125
            z:-360-index%4*95
            eulerRotation:Qt.vector3d(index*37,index*53,index*17)
            scale:Qt.vector3d(1.2+index%3*.29,2.2+index%4*.42,1.2)
            materials:[index%7 ? rock : vein]
        }
    }
}
