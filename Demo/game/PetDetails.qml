pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: pet
    required property var helper
    required property real phase
    required property real strike
    required property real flap
    property bool resting:false
    readonly property string form:helper.form
    readonly property bool wyvern:helper.id==="wyvern"
    readonly property bool firefly:helper.id==="firefly"
    readonly property bool sprites:["chibi","fairy"].includes(form)
    readonly property color shade:Qt.darker(helper.skin,1.47)
    readonly property color highlight:helper.accent

    PrincipledMaterial {id:plate; baseColor:Qt.lighter(pet.helper.skin,1.30); roughness:.42; metalness:.44}
    PrincipledMaterial {id:groove; baseColor:pet.shade; roughness:.60}
    PrincipledMaterial {id:light; baseColor:pet.helper.accent; lighting:PrincipledMaterial.NoLighting}
    PrincipledMaterial {id:pale; baseColor:"#ead0b6"; roughness:.70}
    PrincipledMaterial {id:glass; baseColor:Qt.rgba(pet.highlight.r,pet.highlight.g,pet.highlight.b,.43); roughness:.28; cullMode:Material.NoCulling; alphaMode:PrincipledMaterial.Blend}

    Loader3D {
        active:pet.form==="wasp" || pet.firefly
        sourceComponent:Node {
            Repeater3D {
                model:pet.firefly ? 3 : 4
                Model {
                    required property int index
                    source:"#Sphere"; y:-5+Math.sin(index)*4; z:-18-index*8
                    scale:Qt.vector3d(.35-index*.051,.28-index*.038,.19)
                    materials:[pet.firefly ? light : index%2 ? groove : plate]
                }
            }
            Model {
                visible:!pet.firefly
                source:"#Cone";y:-5;z:-47-pet.strike*18;eulerRotation.x:-80
                scale:Qt.vector3d(.12,.46,.11);materials:[pale]
            }
            Repeater3D {
                model:[-1,1]
                Model {
                    required property int modelData
                    source:"#Sphere";x:modelData*30;y:10+pet.flap*7;z:-16
                    eulerRotation.z:modelData*(16+pet.flap*22)
                    scale:Qt.vector3d(.43,.048,.21);materials:[glass]
                }
            }
        }
    }
    Loader3D {
        active:pet.form==="bat" || pet.form==="drake"
        sourceComponent:Node {
            ScallopedWingGeometry {id: membrane}
            Repeater3D {
                model:[-1,1]
                Node {
                    id:rib
                    required property int modelData
                    x:modelData*14;y:7;z:-6
                    scale:Qt.vector3d(modelData,1,1)
                    eulerRotation.z:modelData*(8+pet.flap*37-(pet.resting ? 44 : 0))
                    Model {
                        geometry:membrane
                        scale:Qt.vector3d(pet.wyvern ? .48 : .39,pet.form==="bat" ? .59 : .45,.53)
                        materials:[plate]
                    }
                    Model {source:"#Cylinder";x:15;y:7;z:12;eulerRotation.z:-65;scale:Qt.vector3d(.022,.36,.022);materials:[groove]}
                    Model {
                        source:"#Cone";x:pet.form==="bat" ? 2 : 9;y:29;z:29
                        eulerRotation.z:-26;scale:Qt.vector3d(.075,pet.form==="bat" ? .33 : .22,.078);materials:[pale]
                    }
                }
            }
            Repeater3D {
                model:pet.form==="drake" ? (pet.wyvern ? 7 : 5) : 0
                Model {
                    required property int index
                    source:"#Cone";y:17-index*2.1;z:10-index*10
                    eulerRotation.x:-19;scale:Qt.vector3d(.094,.17-index*.014,.084);materials:[index%2 ? pale : plate]
                }
            }
            Model {visible:pet.form==="drake";source:"#Sphere";y:11;z:36;scale:Qt.vector3d(.22,.17,.31);materials:[plate]}
            Repeater3D {
                model:pet.form==="drake" ? 4 : 2
                Model {
                    required property int index
                    source:"#Cone";x:(index-(pet.form==="drake" ? 1.5 : .5))*6;y:4;z:29
                    eulerRotation.z:180;scale:Qt.vector3d(.047,.127,.046);materials:[pale]
                }
            }
        }
    }
    Loader3D {
        active:pet.form==="moth" && !pet.firefly || pet.form==="ray"
        sourceComponent:Node {
            Repeater3D {
                model:[-1,1]
                Node {
                    id:side
                    required property int modelData
                    x:modelData*33; y:5+pet.flap*9
                    Model {
                        source:"#Sphere"; z:1; eulerRotation.z:side.modelData*(-25+pet.flap*13)
                        scale:pet.form==="ray" ? Qt.vector3d(.42,.094,.32) : Qt.vector3d(.36,.073,.30)
                        materials:[plate]
                    }
                    Model {source:"#Sphere";y:4;z:8;scale:Qt.vector3d(.13,.06,.13);materials:[groove]}
                    Model {source:"#Sphere";y:6;z:11;scale:Qt.vector3d(.067,.039,.066);materials:[light]}
                    Model {
                        visible:pet.form==="moth"
                        source:"#Cylinder";x:side.modelData*-19;y:26;z:17
                        eulerRotation.z:side.modelData*-36;scale:Qt.vector3d(.015,.26,.016);materials:[groove]
                    }
                }
            }
            Model {
                visible:pet.form==="ray"
                source:"#Cone";z:-31;eulerRotation:Qt.vector3d(-91,Math.sin(pet.phase*5)*17,0)
                scale:Qt.vector3d(.046,.52,.077);materials:[plate]
            }
        }
    }
    Loader3D {
        active:["beetle","kite"].includes(pet.form)
        sourceComponent:Node {
            Repeater3D {
                model:[-1,1]
                Node {
                    id:engine
                    required property int modelData
                    x:modelData*(pet.form==="kite" ? 30 : 15); z:-9
                    eulerRotation.z:modelData*(4+pet.strike*20-(pet.resting ? 27 : 0))
                    Model {
                        source:pet.form==="kite" ? "#Cube" : "#Sphere"
                        eulerRotation.y:pet.form==="kite" ? engine.modelData*33 : 0
                        y:pet.form==="kite" ? 5 : 12
                        scale:pet.form==="kite" ? Qt.vector3d(.41,.12,.17) : Qt.vector3d(.27,.27,.50)
                        materials:[plate]
                    }
                    Repeater3D {
                        model:3
                        Model {
                            required property int index
                            source:"#Cube";x:engine.modelData*(3+index*4);y:5;z:12-index*9
                            eulerRotation.z:engine.modelData*-30
                            scale:Qt.vector3d(.113,.023,.057);materials:[index===1 ? light : groove]
                        }
                    }
                }
            }
            Model {
                source:pet.form==="kite" ? "#Cylinder" : "#Cone"
                z:pet.form==="kite" ? -5 : 23
                y:pet.form==="kite" ? -15 : 15
                eulerRotation.x:pet.form==="kite" ? 0 : 54
                scale:pet.form==="kite" ? Qt.vector3d(.41,.07,.41) : Qt.vector3d(.13,.44,.13)
                materials:[light]
            }
        }
    }
    Loader3D {
        active:pet.form==="fox" || pet.sprites
        sourceComponent:Node {
            Repeater3D {
                model:[-1,1]
                Node {
                    id:mark
                    required property int modelData
                    x:modelData*(pet.form==="fox" ? 9 : 17)
                    y:23; z:22
                    eulerRotation.z:modelData*18
                    Model {
                        source:pet.form==="fox" ? "#Cone" : "#Sphere"
                        y:pet.form==="fox" ? 9 : 3
                        scale:pet.form==="fox" ? Qt.vector3d(.11,.31,.085) : Qt.vector3d(.16,pet.form==="chibi" ? .53 : .26,.14)
                        materials:[pet.form==="chibi" ? light : pale]
                    }
                    Model {
                        visible:pet.sprites
                        source:"#Sphere";x:mark.modelData*17;y:-10+pet.flap*5;z:-29
                        eulerRotation.z:mark.modelData*(-33+pet.flap*18)
                        scale:Qt.vector3d(.21,pet.form==="fairy" ? .48 : .32,.091);materials:[glass]
                    }
                }
            }
            Model {
                visible:pet.form==="fox"
                source:"#Sphere";y:-3;z:-36;eulerRotation:Qt.vector3d(46,Math.sin(pet.phase*4)*26,0)
                scale:Qt.vector3d(.22,.24,.65);materials:[pale]
            }
            Model {visible:pet.form==="fox";source:"#Sphere";z:32;y:6;scale:Qt.vector3d(.24,.116,.25);materials:[pale]}
            Repeater3D {
                model:pet.form==="fairy" ? 5 : 0
                Model {
                    required property int index
                    source:"#Cone";x:(index-2)*6;y:43-Math.abs(index-2)*1.4;z:22
                    scale:Qt.vector3d(.049,.175,.051);eulerRotation.z:(index-2)*14;materials:[plate]
                }
            }
        }
    }
    Repeater3D {
        model:pet.form==="brain" ? 6 : pet.form==="minishade" ? 5 : 0
        Model {
            required property int index
            source:"#Sphere"
            x:Math.cos(index*2.399)*19
            y:pet.form==="brain" ? 22+Math.sin(index*.9)*5 : 2-index*7
            z:pet.form==="brain" ? 12+Math.sin(index*2.399)*14 : -10+Math.sin(pet.phase*3+index)*12
            eulerRotation.z: Math.sin(index)*55
            scale:Qt.vector3d(.037,pet.form==="brain" ? .21 : .18,.046)
            opacity:pet.form==="minishade" ? .23+pet.strike : .65
            materials:[light]
        }
    }
}
