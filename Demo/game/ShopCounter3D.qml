pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D
import "Loadout.js" as Gear

View3D {
    id: counter
    objectName: "shopCounter3D"
    required property var cards
    required property string selectedId
    property bool motion: true
    property int detail:1
    property real dustTime: 0
    NumberAnimation on dustTime { from:0; to:1; duration:2850; loops:Animation.Infinite; running:counter.motion && counter.visible }
    renderMode: View3D.Offscreen
    explicitTextureWidth: Math.max(1,Math.round(Math.min(1550,width*Screen.devicePixelRatio)))
    explicitTextureHeight: Math.max(1,Math.round(explicitTextureWidth*height/Math.max(1,width)))
    SurfaceSet {id:shopSurface; detailed:counter.detail===3; organic:false; bone:true; timber:true}
    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Transparent
        antialiasingMode: SceneEnvironment.MSAA
        antialiasingQuality: SceneEnvironment.Medium
        lightProbe:shopSurface.detailed ? shopSurface.lightProbe : null
        probeExposure:.44
    }
    PerspectiveCamera {
        z: 724
        y: 37
        eulerRotation.x: -3.5
        fieldOfView: 2*Math.atan(Math.max(102,384*counter.height/counter.width)/z)*180/Math.PI
    }
    DirectionalLight { eulerRotation: Qt.vector3d(-34,18,-12); color:"#ffddb2"; brightness:2.1; ambientColor:"#765e75" }
    DirectionalLight { eulerRotation: Qt.vector3d(-7,-100,15); color:"#83baff"; brightness:1.53 }
    LitSurface {surfaces:shopSurface; finish:"wood"; id:oak; baseColor:"#5a3028"; roughness:.76}
    LitSurface {surfaces:shopSurface; finish:"wood"; id:edge; baseColor:"#97724e"; roughness:.68}
    LitSurface {surfaces:shopSurface; finish:"steel"; id:rust; baseColor:"#44404a"; metalness:.62; roughness:.65}
    LitSurface {surfaces:shopSurface; finish:"bone"; id:bone; baseColor:"#c5ac8d"; roughness:.77}
    PrincipledMaterial { id: socket; baseColor:"#12090f"; lighting:PrincipledMaterial.NoLighting }
    LitSurface {surfaces:shopSurface; finish:"weave"; id:jacket; baseColor:"#322733"; roughness:.93}
    PrincipledMaterial { id: blood; baseColor:"#731328"; roughness:.28 }
    PrincipledMaterial { id: bottle; baseColor:"#42673c"; metalness:.25; roughness:.22 }
    LitSurface {surfaces:shopSurface; finish:"weave"; id:paper; baseColor:"#ceac67"; roughness:.85}
    LitSurface {surfaces:shopSurface; finish:"steel"; id:brass; baseColor:"#cb9b60"; roughness:.33; metalness:.72}

    Node {
        y: -47
        Model { source:"#Cube"; z:17; scale:Qt.vector3d(7.8,.26,1.5); materials:[oak] }
        Model { source:"#Cube"; y:14; z:18; scale:Qt.vector3d(7.83,.045,1.55); materials:[edge] }
        Model { source:"#Cube"; y:-42; z:77; scale:Qt.vector3d(7.49,.62,.18); materials:[oak] }
        Model { source:"#Cube"; y:-77; z:88; scale:Qt.vector3d(7.63,.05,.17); materials:[rust] }
        Repeater3D {
            model: 40
            delegate: Model {
                required property int index
                source:"#Sphere"
                x: -374+(index*133)%746
                y: index%5 ? 17 : -27-index%4*8
                z: index%5 ? 42+index%4*12 : 89.5
                eulerRotation.y: index*28
                scale: index%5 ? Qt.vector3d(.22+index%5*.11,.016,.10+index%3*.05)
                    : Qt.vector3d(.047,.14+index%3*.24,.012)
                materials:[blood]
            }
        }
        Repeater3D {
            model: 8
            delegate: Model {
                required property int index
                source:"#Cylinder"
                x:-278+index*12; y:24; z:94-index%3*9
                eulerRotation.z: index%3 ? -73 : 0
                scale:Qt.vector3d(.049,.14,.049)
                materials:[brass]
            }
        }
        Node {
            x:-227; y:27; z:135
            eulerRotation.y: 19
            Model { source:"#Cube"; x:-13; scale:Qt.vector3d(.80,.12,.23); materials:[rust] }
            Model { source:"#Cylinder"; x:51; y:1; eulerRotation.z:90; scale:Qt.vector3d(.058,.77,.058); materials:[rust] }
            Model { source:"#Cube"; x:-38; y:-8; eulerRotation.z:-24; scale:Qt.vector3d(.14,.32,.21); materials:[oak] }
        }
        Node {
            x:71; y:26; z:161
            eulerRotation.y: 21
            Model { source:"#Cube"; scale:Qt.vector3d(.29,.20,.25); materials:[blood] }
            Model { source:"#Cube"; y:2; scale:Qt.vector3d(.051,.207,.27); materials:[brass] }
            Model { source:"#Cube"; y:2; scale:Qt.vector3d(.30,.208,.040); materials:[brass] }
            Model { source:"#Sphere"; x:-5; y:11; eulerRotation.z:24; scale:Qt.vector3d(.13,.038,.055); materials:[brass] }
            Model { source:"#Sphere"; x:5; y:11; eulerRotation.z:-25; scale:Qt.vector3d(.13,.038,.055); materials:[brass] }
        }
    }

    Node {
        x: 286
        y: 6
        z: -35
        Model { source:"#Cube"; y:-52; scale:Qt.vector3d(1.26,.078,.97); materials:[oak] }
        Model { source:"#Cube"; x:-53; y:13; z:-51; scale:Qt.vector3d(.14,1.40,.18); materials:[oak] }
        Model { source:"#Cube"; x:53; y:13; z:-51; scale:Qt.vector3d(.14,1.40,.18); materials:[oak] }
        Repeater3D {
            model: 5
            delegate: Model {
                required property int index
                source:"#Cube"; y:-29+index*23; z:-52
                scale:Qt.vector3d(1.23,.13,.18); materials:[index%2 ? oak : edge]
            }
        }
        Model { source:"#Cube"; x:-53; y:-75; z:-35; scale:Qt.vector3d(.093,.65,.11); materials:[oak] }
        Model { source:"#Cube"; x:53; y:-75; z:-35; scale:Qt.vector3d(.093,.65,.11); materials:[oak] }
        Node {
            x: 18
            y: -13
            z: 9
            eulerRotation: Qt.vector3d(-8,-8,-22)
            Model { source:"#Sphere"; y:-22; scale:Qt.vector3d(.89,1.03,.53); materials:[jacket] }
            Model { source:"#Sphere"; y:14; z:23; scale:Qt.vector3d(.064,.96,.092); materials:[bone] }
            Repeater3D {
                model: 10
                delegate: Model {
                    required property int index
                    readonly property real side: index%2 ? 1 : -1
                    source:"#Sphere"
                    x: side*(16-Math.floor(index/2)*2.2)
                    y: 18-Math.floor(index/2)*8.5
                    z: 27
                    eulerRotation.z: side*25
                    scale:Qt.vector3d(.28,.053,.11)
                    materials:[bone]
                }
            }
            Model { source:"#Sphere"; y:69; z:12; scale:Qt.vector3d(.68,.78,.58); materials:[bone] }
            Model { source:"#Cube"; x:4; y:96; z:29; eulerRotation.z:25; scale:Qt.vector3d(.015,.17,.019); materials:[socket] }
            Model { source:"#Cube"; x:11; y:88; z:37; eulerRotation.z:76; scale:Qt.vector3d(.014,.13,.017); materials:[socket] }
            Model { source:"#Sphere"; y:45; z:24; scale:Qt.vector3d(.47,.27,.38); materials:[bone] }
            Model { source:"#Sphere"; x:-13; y:68; z:39; scale:Qt.vector3d(.23,.17,.065); materials:[socket] }
            Model { source:"#Sphere"; x:13; y:68; z:39; scale:Qt.vector3d(.24,.17,.065); materials:[socket] }
            Model { source:"#Cone"; y:57; z:43; scale:Qt.vector3d(.092,.16,.062); materials:[socket] }
            Model { source:"#Cube"; y:48; z:39; scale:Qt.vector3d(.31,.085,.09); materials:[socket] }
            Repeater3D {
                model: 7
                delegate: Model {
                    required property int index
                    source:"#Cube"; x:(index-3)*4.5; y:49; z:42
                    scale:Qt.vector3d(.026,.044,.060); materials:[bone]
                }
            }
            Model { source:"#Sphere"; x:-48; y:-12; z:17; eulerRotation.z:-47; scale:Qt.vector3d(.08,.50,.086); materials:[bone] }
            Model { source:"#Sphere"; x:45; y:-10; z:20; eulerRotation.z:52; scale:Qt.vector3d(.11,.48,.10); materials:[bone] }
            Model { source:"#Sphere"; x:69; y:-20; z:38; eulerRotation.z:-47; scale:Qt.vector3d(.11,.45,.11); materials:[bone] }
            Node {
                x: 81; y: -3; z: 42
                eulerRotation.z: -18
                Model { source:"#Cylinder"; scale:Qt.vector3d(.18,.40,.18); materials:[bottle] }
                Model { source:"#Cylinder"; scale:Qt.vector3d(.188,.12,.188); materials:[paper] }
                Model { source:"#Cylinder"; y:22; scale:Qt.vector3d(.091,.23,.091); materials:[bottle] }
                Model { source:"#Cylinder"; y:34; scale:Qt.vector3d(.102,.035,.10); materials:[brass] }
                Model { source:"#Sphere"; x:1; y:-13; z:10; scale:Qt.vector3d(.21,.079,.14); materials:[bone] }
            }
        }
        Repeater3D {
            model: 19
            delegate: Model {
                required property int index
                readonly property real drift: (counter.dustTime+index*.319)%1
                source:"#Cube"
                x: 13+index%6*9+drift*16
                y: 64-index%5*8-drift*73
                z: 55+index%4*6
                rotation: Qt.quaternion(.82,drift*.58,index%3*.19,0)
                scale:Qt.vector3d(.012+index%4*.013,.014+index%3*.012,.012)
                opacity: (1-drift)*.73
                materials:[index%4 ? bone : jacket]
            }
        }
    }

    Repeater3D {
        model: counter.cards
        delegate: Node {
            id: merchandise
            required property int index
            required property var modelData
            readonly property var weapon: modelData.group === "weapon" && modelData.gearId ? Gear.weapons[modelData.gearId] : null
            readonly property color tag: modelData.sold ? "#51434d" : Gear.rarities[modelData.rarity]?.color || "#9ebc9d"
            readonly property bool chosen: counter.selectedId === modelData.id
            x: -170+index*56
            y: chosen ? -1 : -17
            z: 49-index%2*22
            eulerRotation.y: 26+index%3*7
            Behavior on y { NumberAnimation { duration: counter.motion ? 140 : 0; easing.type:Easing.OutQuad } }
            LitSurface {surfaces:shopSurface; finish:"steel"; id:enamel; baseColor:merchandise.tag; roughness:.43; metalness:.39}
            Model {
                source: merchandise.weapon ? "#Cube" : merchandise.modelData.action === "mystery" ? "#Cube" : merchandise.index%2 ? "#Cylinder" : "#Sphere"
                scale: merchandise.weapon ? Qt.vector3d(.44,.14,.18) : Qt.vector3d(.31,.25,.24)
                materials:[enamel]
            }
            Model {
                visible: !!merchandise.weapon
                source:"#Cylinder"; x:25; eulerRotation.z:90
                scale:Qt.vector3d(.048,.21,.048); materials:[rust]
            }
            Model {
                visible: !merchandise.weapon
                source:"#Cube"; y:1; z:13
                scale:Qt.vector3d(.25,.053,.018); materials:[merchandise.chosen ? brass : paper]
            }
        }
    }
}
