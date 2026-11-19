pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: pet
    required property var helper
    required property real phase
    required property real strike
    required property real flap
    required property real fold
    property bool detailed:false
    property string bodyPattern:""
    readonly property string form:helper.form
    readonly property bool wyvern:helper.id==="wyvern"
    readonly property bool firefly:helper.id==="firefly"
    readonly property bool sprites:["chibi","fairy"].includes(form)
    readonly property color shade:Qt.darker(helper.skin,1.47)
    readonly property color highlight:helper.accent

    PetSurface {
        id:plate
        textured:pet.detailed
        pattern:pet.bodyPattern
        baseColor:Qt.lighter(pet.helper.skin, textured && pet.form === "beetle" ? 1.65 : 1.30)
        roughness:.42
        metalness:!textured ? .44 : pet.form === "beetle" ? .31
            : ["fox","drake","moth","fairy"].includes(pet.form) ? .06 : .44
        normalStrength:pattern === "fur" || pattern === "down" ? .34 : .71
        clearcoatAmount:textured && pet.form === "beetle" ? .63 : 0
        clearcoatRoughnessAmount:.21
    }
    PrincipledMaterial {id:groove; baseColor:pet.shade; roughness:.60}
    PrincipledMaterial {id:light; baseColor:pet.helper.accent; lighting:PrincipledMaterial.NoLighting}
    PetSurface {
        id:pale
        textured:pet.detailed && pet.form === "fox"
        pattern:"fur"
        baseColor:"#ead0b6"
        roughness:.70
        normalStrength:.34
    }
    PetSurface {
        id:membraneSkin
        textured:pet.detailed
        pattern:pet.form === "bat" || pet.form === "drake" ? "membrane"
            : pet.form === "ray" ? "circuit" : pet.form === "moth" && !pet.firefly ? "moth" : ""
        baseColor:Qt.lighter(pet.helper.skin,1.47)
        roughness:.70
        normalStrength:.54
        cullMode:Material.NoCulling
    }
    PetSurface {
        id:glass
        textured:pet.detailed && (pet.sprites || pet.firefly || pet.form === "wasp")
        pattern:"veil"
        baseColor:Qt.rgba(pet.highlight.r,pet.highlight.g,pet.highlight.b,.43)
        roughness:.28
        normalStrength:.39
        cullMode:Material.NoCulling
        alphaMode:PrincipledMaterial.Blend
    }

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
                    source:"#Sphere";x:modelData*(27-pet.fold*9);y:10+pet.flap*7;z:-16
                    eulerRotation.z:modelData*(16+pet.flap*22-pet.fold*49)
                    eulerRotation.y:modelData*pet.fold*43
                    scale:Qt.vector3d(pet.firefly ? .39 : .49,.048,pet.firefly ? .14 : .22);materials:[glass]
                }
            }
        }
    }
    Loader3D {
        active:pet.form==="bat" || pet.form==="drake"
        sourceComponent:Node {
            ScallopedWingGeometry {id: membrane; textured:pet.detailed}
            Repeater3D {
                model:[-1,1]
                Node {
                    id:rib
                    required property int modelData
                    x:modelData*14;y:7;z:-6
                    scale:Qt.vector3d(modelData,1,1)
                    eulerRotation.z:modelData*(8+pet.flap*37-pet.fold*44)
                    eulerRotation.y:modelData*((pet.wyvern ? 15 : -8)+pet.fold*52)
                    Model {
                        geometry:membrane
                        scale:Qt.vector3d(pet.wyvern ? .51 : .39,pet.form==="bat" ? .66 : pet.wyvern ? .32 : .54,.53)
                        materials:[membraneSkin]
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
                model:pet.form==="drake" ? 4 : 0
                Model {
                    required property int index
                    source:pet.wyvern && index===3 ? "#Cone" : "#Sphere"
                    x:(pet.wyvern ? -1 : 1)*index*7+Math.sin(pet.phase*4-index*.6)*index*1.7
                    y:-10+index*(pet.wyvern ? 7 : -2)
                    z:-20-index*7
                    eulerRotation.z:pet.wyvern ? 43 : -20
                    scale:Qt.vector3d(.22-index*.037,.17-index*.021,.23-index*.037)
                    materials:[index===3 ? pale : index%2 ? groove : plate]
                }
            }
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
                    x:modelData*(32-pet.fold*12); y:5+pet.flap*9
                    eulerRotation.z:modelData*(pet.flap*21-pet.fold*37)
                    eulerRotation.y:modelData*pet.fold*40
                    Model {
                        source:"#Sphere"; z:1; eulerRotation.z:side.modelData*(pet.form==="ray" ? -12 : 27)
                        scale:pet.form==="ray" ? Qt.vector3d(.64,.092,.36) : Qt.vector3d(.39,.26,.12)
                        materials:[membraneSkin]
                    }
                    Model {
                        visible:pet.form==="moth"
                        source:"#Sphere";x:side.modelData*-3;y:-12;z:-7;eulerRotation.z:side.modelData*25
                        scale:Qt.vector3d(.24,.17,.145);materials:[plate]
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
                    eulerRotation.z:modelData*(4+pet.strike*20-pet.fold*27)
                    Model {
                        source:pet.form==="kite" ? "#Cube" : "#Sphere"
                        eulerRotation.y:pet.form==="kite" ? engine.modelData*33 : 0
                        y:pet.form==="kite" ? 5 : 12
                        scale:pet.form==="kite" ? Qt.vector3d(.54,.12,.24) : Qt.vector3d(.27,.27,.50)
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
                source:"#Sphere";x:19;y:-3;z:-23;eulerRotation:Qt.vector3d(13,51+Math.sin(pet.phase*4)*19,-34)
                scale:Qt.vector3d(.24,.27,.69);materials:[plate]
            }
            Model {
                visible:pet.form==="fox"
                source:"#Sphere";x:42+Math.sin(pet.phase*4)*5;y:10;z:-34;eulerRotation:Qt.vector3d(20,50,-24)
                scale:Qt.vector3d(.154,.163,.31);materials:[pale]
            }
            Model {visible:pet.form==="fox";source:"#Sphere";z:32;y:6;scale:Qt.vector3d(.24,.116,.25);materials:[pale]}
            Repeater3D {
                model:pet.form==="fox" ? 4 : 0
                Model {
                    required property int index
                    source:"#Sphere";x:index%2 ? 11 : -11;y:-27+pet.fold*11;z:index<2 ? 12 : -11
                    eulerRotation.x:Math.sin(pet.phase*6+index*2)*15
                    scale:Qt.vector3d(.071,.114,.13);materials:[index<2 ? pale : groove]
                }
            }
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
