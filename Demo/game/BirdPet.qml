pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: bird
    required property var helper
    required property real phase
    required property real strike
    required property bool animate
    required property bool resting
    property bool detailed:false
    property real tuck:resting ? 1 : 0
    Behavior on tuck {enabled:bird.animate; NumberAnimation {duration:480;easing.type:Easing.OutCubic}}
    readonly property bool crow:helper.id==="crow"
    readonly property bool raven:helper.id==="archive"
    readonly property bool owl:helper.id==="owl"
    readonly property bool finch:helper.id==="finch"
    readonly property bool wendy:helper.id==="chicken"
    readonly property real flap:animate ? Math.sin(phase*(owl ? 7 : finch ? 18 : wendy ? 14 : 11))*(1-tuck) : 0
    readonly property bool attacking:strike>.04

    PetFeatherGeometry {id: feather; textured:bird.detailed}
    PetBeakGeometry {id: bill}
    PetSurface {
        id: plumage
        textured:bird.detailed
        pattern:bird.wendy ? "wendy" : bird.owl ? "owl" : bird.raven ? "archive" : bird.finch ? "finch" : "crow"
        baseColor:bird.wendy ? "#d8b48b" : bird.helper.skin
        roughness:.83
        normalStrength:.72
        cullMode:Material.NoCulling
    }
    PetSurface {
        id: coverts
        textured:bird.detailed
        pattern:plumage.pattern
        baseColor:bird.wendy ? "#ad684d" : bird.raven ? "#4b665e" : Qt.lighter(bird.helper.skin,1.29)
        roughness:.72
        normalStrength:.64
        cullMode:Material.NoCulling
    }
    PetSurface {
        id: chest
        textured:bird.detailed
        pattern:plumage.pattern
        baseColor:bird.wendy ? "#efe0b9" : bird.owl ? "#d5b582" : bird.raven ? "#c0d3cf" : bird.finch ? "#bfd097" : "#675668"
        roughness:.78
        normalStrength:.48
        cullMode:Material.NoCulling
    }
    PetSurface {
        id: primaryFlight
        textured:bird.detailed
        pattern:bird.owl || bird.wendy ? "quill-barred" : "quill"
        baseColor:plumage.baseColor
        roughness:plumage.roughness
        normalStrength:.65
        cullMode:Material.NoCulling
    }
    PetSurface {
        id: secondaryFlight
        textured:bird.detailed
        pattern:primaryFlight.pattern
        baseColor:coverts.baseColor
        roughness:coverts.roughness
        normalStrength:.65
        cullMode:Material.NoCulling
    }
    PetSurface {
        id: flightTips
        textured:bird.detailed && (bird.owl || bird.wendy || bird.raven)
        pattern:primaryFlight.pattern
        baseColor:chest.baseColor
        roughness:chest.roughness
        normalStrength:.65
        cullMode:Material.NoCulling
    }
    PrincipledMaterial {id: horn; baseColor:bird.wendy ? "#e5a54e" : bird.finch ? "#eebe69" : bird.owl ? "#a77748" : "#292534"; roughness:.54}
    PrincipledMaterial {id: comb; baseColor:"#d3434d"; roughness:.48}
    PrincipledMaterial {id: pupil; baseColor:"#130e18"; roughness:.34}
    PrincipledMaterial {id: eye; baseColor:bird.attacking ? "#ff5945" : bird.helper.accent; lighting:PrincipledMaterial.NoLighting}
    PrincipledMaterial {id: catchlight; baseColor:"#fff5de"; lighting:PrincipledMaterial.NoLighting}

    Model {
        source:"#Sphere"
        y:bird.wendy ? -9 : -5; z:-8
        scale:bird.wendy ? Qt.vector3d(.62,.49,.53) : bird.owl ? Qt.vector3d(.59,.57,.42)
            : bird.finch ? Qt.vector3d(.33,.32,.35) : Qt.vector3d(.42,.40,bird.raven ? .66 : .57)
        materials:[plumage]
    }
    Model {
        source:"#Sphere"
        y:-7; z:12
        scale:bird.finch ? Qt.vector3d(.26,.30,.34) : bird.raven ? Qt.vector3d(.36,.23,.32)
            : Qt.vector3d(.39,.40,.42)
        materials:[chest]
    }
    Node {
        id:face
        y:bird.wendy ? 24 : bird.owl ? 23 : bird.finch ? 16 : 22
        z:bird.wendy ? 20 : 16
        eulerRotation.x:bird.strike*(bird.wendy ? 34 : 15)+bird.tuck*24
        Model {
            source:"#Sphere"
            scale:bird.owl ? Qt.vector3d(.50,.42,.40) : bird.wendy ? Qt.vector3d(.28,.36,.32)
                : bird.finch ? Qt.vector3d(.30,.31,.31) : Qt.vector3d(.32,.31,.36)
            materials:[coverts]
        }
        Model {
            geometry:bill
            y:-6; z:12
            scale:bird.finch ? Qt.vector3d(.47,.53,.34) : bird.owl ? Qt.vector3d(.51,.82,.38)
                : bird.wendy ? Qt.vector3d(.72,.69,.54) : Qt.vector3d(bird.raven ? .99 : .79,.80,bird.raven ? 1.03 : .89)
            materials:[horn]
        }
        Model {
            source:"#Sphere"
            y:-11-bird.strike*9; z:19
            scale:Qt.vector3d(.13,.095,bird.finch ? .12 : .28)
            materials:[horn]
        }
        Repeater3D {
            model:[-1,1]
            Node {
                id:socket
                required property int modelData
                x:modelData*(bird.owl ? 11 : 9)
                y:2; z:bird.owl ? 18 : 15
                Model {
                    visible:bird.owl || bird.finch
                    source:"#Sphere"; z:-2
                    scale:bird.owl ? Qt.vector3d(.253,.260,.081) : Qt.vector3d(.138,.185,.070)
                    materials:[chest]
                }
                Model {
                    source:"#Sphere"
                    scale:bird.owl ? Qt.vector3d(.110,.130,.066) : Qt.vector3d(.074,.090,.057)
                    materials:[pupil]
                }
                Model {
                    source:"#Sphere"; z:3
                    scale:Qt.vector3d(bird.owl ? .074 : .050,bird.resting ? .014 : bird.attacking ? .045 : bird.owl ? .097 : .069,.045)
                    materials:[eye]
                }
                Model {visible:!bird.resting;source:"#Sphere";x:-1.5;y:1.8;z:5;scale:Qt.vector3d(.019,.020,.013);materials:[catchlight]}
                Model {
                    visible:bird.attacking || bird.owl
                    source:"#Sphere"; y:bird.attacking ? 3.9 : 7; z:6
                    eulerRotation.z:socket.modelData*(bird.attacking ? 27 : 9)
                    scale:Qt.vector3d(bird.owl ? .175 : .106,.039,.041);materials:[plumage]
                }
                Model {
                    visible:bird.owl || bird.raven
                    geometry:feather
                    x:socket.modelData*2; y:14; z:-7
                    eulerRotation.z:socket.modelData>0 ? 54 : 126
                    scale:Qt.vector3d(bird.owl ? .17 : .12,.44,.55);materials:[secondaryFlight]
                }
            }
        }
        Repeater3D {
            model:bird.wendy ? 4 : 0
            Model {
                required property int index
                source:"#Sphere"; y:16+index%2*4;z:12-index*6
                scale:Qt.vector3d(.085,.145+index%2*.035,.106);materials:[comb]
            }
        }
        Model {
            visible:bird.wendy
            source:"#Sphere"; y:-16; z:18
            scale:Qt.vector3d(.089,.169,.09); materials:[comb]
        }
    }
    Repeater3D {
        model:[-1,1]
        Node {
            id:joint
            required property int modelData
            x:modelData*(bird.finch ? 10 : 15); y:3; z:-7
            eulerRotation.z:modelData*(3-bird.tuck*37+bird.flap*(bird.owl ? 25 : bird.wendy ? 19 : 32))
            eulerRotation.y:modelData*(bird.strike*18-8+bird.tuck*63)
            scale:Qt.vector3d(modelData,1,1)
            Model {
                source:"#Sphere"; x:13; z:4
                scale:Qt.vector3d(bird.owl ? .57 : .39,.13,.26);materials:[coverts]
            }
            Repeater3D {
                model:bird.finch ? 5 : 7
                Model {
                    required property int index
                    geometry:feather
                    x:4+index*2.75; y:-index*.3; z:-11+index*3.6
                    eulerRotation.y:(6-index*4.4)+(bird.owl ? 11 : 0)
                    eulerRotation.z:bird.wendy ? 8-index*3 : -index*3.5
                    scale:Qt.vector3d((bird.owl ? .64 : bird.raven ? .62 : bird.finch ? .42 : bird.wendy ? .38 : .53)
                        -index*(bird.owl ? .040 : .032),.63,bird.owl ? .88 : bird.raven ? .58 : .70)
                    materials:[index%3===2 ? secondaryFlight : primaryFlight]
                }
            }
            Repeater3D {
                model:4
                Model {
                    required property int index
                    geometry:feather
                    x:7+index*6; y:5; z:-13+index*4.2
                    eulerRotation.y:31-index*5
                    scale:Qt.vector3d(bird.owl ? .24 : .19,.48,.56)
                    materials:[bird.owl || bird.wendy || bird.raven ? flightTips : secondaryFlight]
                }
            }
        }
    }
    Repeater3D {
        model:bird.wendy ? 5 : bird.owl ? 3 : 4
        Model {
            required property int index
            readonly property real fan:index-(bird.wendy ? 2 : bird.owl ? 1 : 1.5)
            geometry:feather
            x:fan*5; y:bird.wendy ? 5 : -12; z:-25
            eulerRotation:Qt.vector3d(0,(bird.wendy ? 76 : 87)+fan*9,bird.wendy ? 45+fan*6 : -6)
            scale:Qt.vector3d(bird.wendy ? .41 : bird.owl ? .27 : bird.finch ? .24 : bird.raven ? .61 : .44,.76,.78)
            materials:[index%2 ? secondaryFlight : primaryFlight]
        }
    }
    Repeater3D {
        model:[-1,1]
        Node {
            id:foot
            required property int modelData
            x:modelData*(bird.wendy ? 12 : 7)
            y:bird.wendy ? -24 : -22
            z:bird.wendy ? 4 : 0
            eulerRotation.x:-18-bird.tuck*44+bird.strike*61+bird.flap*9*modelData
            readonly property real shank:bird.wendy ? 20 : bird.owl ? 11 : bird.finch ? 9 : 12
            Model {
                source:"#Cylinder"; y:-foot.shank*.45
                scale:Qt.vector3d(bird.wendy ? .036 : .028,foot.shank*.01,.031)
                materials:[bird.owl ? chest : horn]
            }
            Repeater3D {
                model:3
                Model {
                    required property int index
                    source:"#Cone"
                    x:(index-1)*3.5; y:-foot.shank; z:3+bird.strike*8
                    eulerRotation:Qt.vector3d(90,(index-1)*7,0)
                    scale:Qt.vector3d(.028,bird.wendy ? .13 : .088,.034)
                    materials:[horn]
                }
            }
        }
    }
}
