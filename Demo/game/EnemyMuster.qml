import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Encounters.js" as Mission
import "EnemyLore.js" as Lore
import "MusterData.js" as Muster
import "Conditions.js" as Weather
import "Pets.js" as Pets
import "../ui" as Ui

Item {
    id: muster
    objectName: "enemyMuster"
    required property var stage
    required property var discoveries
    signal entryRequested(string chapter, string id)
    property bool software: false
    property int detail:1
    property var companion:null
    property bool motion: true
    property bool compact: false
    property real paradeHeight: 160
    property int hoveredMember:-1
    property bool nativeBossHovered:false
    readonly property var company: stage.groups.filter(function(group) { return group.rank !== "Overlord" })
    readonly property string overlord: Mission.boss(stage.wave)
    readonly property var placements:Muster.placements(company,stage.wave*7919,overlord.length>0)
    readonly property real cameraRadius:Muster.radius(company,parade.width/Math.max(1,parade.height))
    implicitHeight:paradeHeight+38
    Ui.ShrineFrame {
        objectName:"musterStrip"
        z:7
        anchors.horizontalCenter:parent.horizontalCenter
        anchors.bottom:parent.bottom
        width:Math.min(parent.width, waveBand.implicitWidth+24)
        height:Math.max(30,Ui.UiMetrics.text(23))
        fill:Ui.InterfaceTheme.current.base
        RowLayout {
            id:waveBand
            anchors.fill:parent
            anchors.leftMargin:12
            anchors.rightMargin:12
            spacing:8
            Text {
                objectName:"musterTotal"
                text:"Wave "+muster.stage.wave
                color:Ui.InterfaceTheme.text
                font.family:Ui.InterfaceTheme.heading
                font.bold:true
                font.pixelSize:Ui.UiMetrics.text(muster.compact ? 12 : 15)
            }
            Rectangle {implicitWidth:1;implicitHeight:13;color:Ui.InterfaceTheme.current.line}
            Text {
                objectName:"musterScale"
                text:"×"+(1+Math.floor(muster.stage.wave/10)*Mission.difficulty(muster.stage.difficulty).scale).toFixed(2)
                color:Ui.InterfaceTheme.weapon
                font.family:"IBM Plex Mono"
                font.pixelSize:Ui.UiMetrics.text(muster.compact ? 12 : 14)
                Accessible.name:"Difficulty scaling "+text
            }
            Text {
                readonly property var weather:Weather.entries[muster.stage.weather] || Weather.entries.clear
                readonly property bool blood:muster.stage.sky==="bloodMoon"
                visible:weather.id !== "clear" || blood
                Layout.fillWidth:true
                Layout.minimumWidth:0
                text:(weather.id!=="clear" ? weather.glyph+" "+Weather.weatherLabel(weather.id,muster.stage) : "")+(blood ? (weather.id!=="clear" ? "  ·  " : "")+"Blood Moon" : "")
                color:blood ? "#f09c9a" : weather.tint
                font.family:"Inter"
                font.pixelSize:Ui.UiMetrics.text(muster.compact ? 12 : 14)
                elide:Text.ElideRight
            }
        }
    }
    Item {
        id: parade
        clip:true
        anchors.fill:parent
        anchors.bottomMargin:38
        Loader {
            id: looming
            active: muster.overlord.length > 0
            width: parade.width*.58
            height: parade.height*1.05
            anchors.horizontalCenter: parent.horizontalCenter
            y:-parade.height*.12
            sourceComponent: Item {
                objectName: "bossMusterSilhouette"
                layer.enabled: !muster.software
                layer.effect: ShaderEffect { fragmentShader: Qt.resolvedUrl("shaders/silhouette.frag.qsb") }
                Loader {
                    anchors.fill: parent
                    sourceComponent: muster.software ? shadowPainting : shadowModel
                }
                Component {
                    id: shadowModel
                    EnemyPortrait3D { enemyType:muster.overlord; motion:muster.motion; modelScale:1.40 }
                }
                Component {
                    id: shadowPainting
                    ProjectedWorld {
                        actors:[Muster.actor(muster.overlord,Mission.enemyTypes[muster.overlord].size*405)]
                        portraitMode:true
                        silhouette:true
                        motion:false
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: looming
            acceptedButtons:Qt.NoButton
            visible: looming.active
            hoverEnabled:true
            EnemyHint {
                anchorItem:parent; hovered:muster.software ? parent.containsMouse : muster.nativeBossHovered
                pointerPosition:muster.software ? Qt.point(parent.mouseX,parent.mouseY)
                    : anchorItem.mapFromItem(parade,paradeHover.mouseX,paradeHover.mouseY)
                enemyType:muster.overlord; discoveries:muster.discoveries
                onEntryRequested:function(chapter,id) { muster.entryRequested(chapter,id) }
            }
        }
        Loader {
            id:nativeParade
            anchors.fill:parent
            anchors.margins:6
            active:!muster.software
            sourceComponent:MusterScene3D {company:muster.company; placements:muster.placements; detail:muster.detail; motion:muster.motion}
        }
        Loader {
            id:companionCorner
            objectName:"musterCompanion"
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            anchors.rightMargin:5
            anchors.bottomMargin:8
            width:muster.compact ? 101 : 154
            height:Math.min(parade.height*.72,muster.compact ? 94 : 135)
            active:!!muster.companion
            visible:active
            z:5
            sourceComponent:Item {
                readonly property real clock:muster.motion ? flight : 0
                property real flight:0
                Timer {
                    running:muster.motion && companionCorner.visible;repeat:true;interval:60
                    onTriggered:parent.flight=(parent.flight+.060)%60
                }
                Rectangle {
                    anchors.horizontalCenter:parent.horizontalCenter
                    anchors.bottom:parent.bottom
                    anchors.bottomMargin:15
                    width:parent.width*.7;height:5;radius:2
                    color:"#91ae8bca"
                }
                Loader {
                    anchors.fill:parent
                    anchors.bottomMargin:16
                    sourceComponent:muster.software ? petFlat : petNative
                }
                Component {
                    id:petNative
                    PetPortrait3D {
                        helper:muster.companion
                        detailed:muster.detail>=2
                        zoom:1.12
                        clock:companionCorner.item?.clock || 0
                        animate:muster.motion
                    }
                }
                Component {
                    id:petFlat
                    ProjectedPet {helper:muster.companion;flap:Math.sin(companionCorner.item?.clock*4 || 0)}
                }
                Text {
                    anchors.bottom:parent.bottom
                    width:parent.width
                    text:muster.companion.title
                    font.family:"Inter"
                    font.pixelSize:Ui.UiMetrics.text(muster.compact ? 10 : 12)
                    horizontalAlignment:Text.AlignHCenter
                    elide:Text.ElideRight
                    color:Pets.uniqueColor
                    style:Text.Outline
                    styleColor:"#24172f"
                    Accessible.name:"Companion "+text
                }
            }
        }
        MouseArea {
            id:paradeHover
            anchors.fill:parent
            hoverEnabled:!!nativeParade.item
            acceptedButtons:Qt.NoButton
            function updateMember() {
                if (!containsMouse || !nativeParade.item) {
                    muster.hoveredMember=-1
                    muster.nativeBossHovered=false
                    return
                }
                const local=nativeParade.mapFromItem(parade,mouseX,mouseY)
                muster.hoveredMember=nativeParade.item.indexAt(local.x,local.y)
                muster.nativeBossHovered=muster.hoveredMember<0 && looming.active
                    && Math.hypot((mouseX-looming.x-looming.width*.5)/(looming.width*.32),
                        (mouseY-looming.y-looming.height*.5)/(looming.height*.35))<1
            }
            onPositionChanged:updateMember()
            onContainsMouseChanged:updateMember()
        }
        Item {
            id: army
            anchors.fill:parent
            anchors.margins:6
            Repeater {
                model: muster.company
                delegate: Item {
                    id: member
                    required property var modelData
                    required property int index
                    objectName: "muster-"+modelData.type
                    width:Math.max(28,132*Muster.displaySize(member.spec)*parade.height/muster.cameraRadius)
                    height:Math.max(30,180*Muster.displaySize(member.spec)*parade.height/muster.cameraRadius)
                    readonly property var position:muster.placements[index] || {x:.5,y:.5}
                    x:army.width*position.x-width/2
                    y:Math.max(0,Math.min(army.height-height,army.height*position.y-height/2))
                    readonly property var spec: Mission.enemyTypes[modelData.type]
                    readonly property color tone: Lore.origins[spec.origin].color
                    Loader {
                        id:bodyPainting
                        anchors.fill: parent
                        anchors.margins:0
                        active:muster.software
                        sourceComponent:painting
                    }
                    Component {
                        id: painting
                        ProjectedWorld {
                            portraitMode:true
                            motion:muster.motion
                            actors:[Muster.actor(member.modelData.type,member.spec.size*340)]
                            NumberAnimation on elapsed {
                                from:0; to:60; duration:60000; loops:Animation.Infinite
                                running:visible && muster.motion
                            }
                            onElapsedChanged: {
                                actors[0].age = elapsed+member.index*.731
                                revision += 1
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons:Qt.NoButton
                        hoverEnabled:muster.software
                        Accessible.name: Muster.tooltip(member.modelData,muster.discoveries)
                        EnemyHint {
                            anchorItem:parent
                            hovered:muster.software ? parent.containsMouse && !!bodyPainting.item?.pickTarget(parent.mouseX,parent.mouseY)
                                : muster.hoveredMember===member.index
                            pointerPosition:muster.software ? Qt.point(parent.mouseX,parent.mouseY)
                                : anchorItem.mapFromItem(parade,paradeHover.mouseX,paradeHover.mouseY)
                            enemyType:member.modelData.type; discoveries:muster.discoveries
                            onEntryRequested:function(chapter,id) { muster.entryRequested(chapter,id) }
                        }
                    }
                }
            }
        }
    }
}
