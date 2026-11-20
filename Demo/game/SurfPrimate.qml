import QtQuick
import QtQuick3D

Node {
    id:ape
    required property real clock
    property string action:"flight"
    property string expression:"neutral"
    readonly property real beat:Math.sin(clock*6.3)
    readonly property bool banana:action==="banana"
    readonly property bool globe:action==="globe"
    readonly property bool vine:action==="vine"
    readonly property bool parking:action==="board"
    PrincipledMaterial {id:fur;baseColor:"#694899";roughness:.83}
    PrincipledMaterial {id:skin;baseColor:"#aa83bb";roughness:.75}
    PrincipledMaterial {id:wetSuit;baseColor:"#203e55";roughness:.52}
    PrincipledMaterial {id:yellow;baseColor:"#ffd04a";clearcoatAmount:.35}
    PrincipledMaterial {id:stripe;baseColor:"#14324b";roughness:.43}
    PrincipledMaterial {id:black;baseColor:"#1b142a"}
    PrincipledMaterial {id:ivory;baseColor:"#fff0af"}
    PrincipledMaterial {id:ocean;baseColor:"#3280ad";roughness:.46}
    PrincipledMaterial {id:land;baseColor:"#99c764";roughness:.59}
    PrincipledMaterial {id:leaf;baseColor:"#436d48";roughness:.96}

    Node {
        y:ape.parking ? -31-ape.beat*13 : -26
        x:ape.parking ? -18-ape.beat*12 : 0
        eulerRotation.z:ape.parking ? -22+ape.beat*20 : -7+ape.beat*4
        visible:!ape.vine
        Model {source:"#Sphere";scale:Qt.vector3d(.98,.055,.31);materials:[yellow]}
        Model {source:"#Sphere";y:3;scale:Qt.vector3d(.91,.016,.048);materials:[stripe]}
        Model {source:"#Cone";x:-29;y:-6;scale:Qt.vector3d(.12,.15,.04);eulerRotation.x:180;materials:[stripe]}
    }
    Node {
        y:ape.vine ? ape.beat*5 : 0
        eulerRotation.z:ape.vine ? ape.beat*14 : ape.action==="laugh" ? ape.beat*9 : 0
        Model {source:"#Sphere";y:-3;scale:Qt.vector3d(.36,.43,.28);materials:[fur]}
        Model {source:"#Sphere";y:-7;z:9;scale:Qt.vector3d(.32,.34,.24);materials:[wetSuit]}
        Model {source:"#Sphere";y:19;z:2;scale:Qt.vector3d(.33,.32,.28);materials:[fur]}
        Model {source:"#Sphere";y:15;z:16;scale:Qt.vector3d(.25,.17,.13);materials:[skin]}
        Model {source:"#Sphere";y:12;z:21;scale:Qt.vector3d(ape.expression==="happy" || ape.action==="laugh" ? .17 : .10,
            ape.action==="laugh" ? .066+ape.beat*.024 : ape.banana ? .035+(.032*(ape.beat+1)) : .027,.055);materials:[black]}
        Model {visible:ape.expression==="happy" || ape.action==="laugh";source:"#Sphere";y:13;z:23;scale:Qt.vector3d(.11,.023,.012);materials:[ivory]}
        Model {source:"#Sphere";y:20;z:24;scale:Qt.vector3d(.10,.047,.045);materials:[skin]}
        Model {source:"#Sphere";x:-6;y:24;z:22;scale:Qt.vector3d(.069,.073,.044);materials:[ivory]}
        Model {source:"#Sphere";x:6;y:24;z:22;scale:Qt.vector3d(.069,.073,.044);materials:[ivory]}
        Model {source:"#Sphere";x:-4;y:24;z:25;scale:Qt.vector3d(.031,.061,.025);materials:[black]}
        Model {source:"#Sphere";x:7;y:24;z:25;scale:Qt.vector3d(.031,.061,.025);materials:[black]}
        Model {source:"#Sphere";x:-16;y:21;z:1;scale:Qt.vector3d(.065,.095,.066);materials:[skin]}
        Model {source:"#Sphere";x:16;y:21;z:1;scale:Qt.vector3d(.065,.095,.066);materials:[skin]}
        Model {source:"#Sphere";y:32;eulerRotation.z:-12;scale:Qt.vector3d(.25,.082,.24);materials:[wetSuit]}
        Model {source:"#Sphere";x:9;y:32;z:11;scale:Qt.vector3d(.15,.031,.17);materials:[wetSuit]}
        Repeater3D {
            model:2
            delegate:Node {
                id:arm
                required property int index
                readonly property int side:index ? 1 : -1
                readonly property bool thumbs:ape.action==="thumbs" && index===1
                readonly property bool toss:ape.action==="throw" && index===0
                x:side*17;y:7
                eulerRotation.z:side*(thumbs ? 125 : toss ? 105+ape.beat*40 : ape.vine ? 142
                    : ape.globe && index ? 120 : ape.banana && !index ? 95 : 26+ape.beat*8)
                Model {source:"#Sphere";y:-9;scale:Qt.vector3d(.11,.236,.10);materials:[fur]}
                Model {source:"#Sphere";y:-18;z:3;scale:Qt.vector3d(.11,.094,.088);materials:[skin]}
                Model {visible:arm.thumbs;source:"#Sphere";x:5;y:-20;z:5;eulerRotation.z:-36;scale:Qt.vector3d(.038,.098,.05);materials:[skin]}
                Model {source:"#Sphere";x:-side*6;y:-23;z:7;scale:Qt.vector3d(.126,.065,.19);materials:[stripe]}
            }
        }
        Repeater3D {
            model:ape.expression==="upset" ? [-1,1] : []
            Model {
                required property int modelData
                source:"#Sphere";x:modelData*6;y:27;z:27;eulerRotation.z:modelData*29
                scale:Qt.vector3d(.11,.032,.023);materials:[black]
            }
        }
        Node {
            visible:ape.banana
            x:-14+ape.beat*4;y:11+ape.beat*4;z:23
            eulerRotation.z:-52+ape.beat*17
            Model {source:"#Sphere";scale:Qt.vector3d(.25,.05,.066);materials:[yellow]}
            Model {source:"#Sphere";x:8;y:3;scale:Qt.vector3d(.13,.046,.052);materials:[ivory]}
        }
        Node {
            visible:ape.globe
            x:29;y:31;z:8
            eulerRotation.y:ape.clock*210
            Model {source:"#Sphere";scale:Qt.vector3d(.175,.175,.175);materials:[ocean]}
            Repeater3D {
                model:7
                Model {
                    required property int index
                    source:"#Sphere"
                    x:Math.cos(index*2.1)*7.3;y:Math.sin(index*4.7)*4.3;z:Math.sin(index*2.1)*7.3
                    scale:Qt.vector3d(.081,.049,.052);materials:[land]
                }
            }
        }
    }
    Repeater3D {
        model:ape.vine ? 13 : 0
        Model {
            required property int index
            x:Math.sin(index*.27+ape.clock*3)*10;y:19+index*4
            source:"#Sphere";scale:Qt.vector3d(index%4 ? .021 : .074,.064,.024);materials:[leaf]
        }
    }
}
