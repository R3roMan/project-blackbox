import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Encounters.js" as Mission
import "EnemyLore.js" as Lore
import "MusterData.js" as Muster
import "Conditions.js" as Weather
import "../ui" as Ui

Item {
    id: muster
    objectName: "enemyMuster"
    required property var stage
    required property var discoveries
    signal entryRequested(string chapter, string id)
    property bool software: false
    property bool motion: true
    property bool compact: false
    property real paradeHeight: 160
    property int hoveredMember:-1
    readonly property var company: stage.groups.filter(function(group) { return group.rank !== "Overlord" })
    readonly property string overlord: Mission.boss(stage.wave)
    readonly property var placements:Muster.placements(company,stage.wave*7919,overlord.length>0)
    readonly property real cameraRadius:Muster.radius(company,placements,parade.width/Math.max(1,parade.height))
    implicitHeight:paradeHeight+38
    Rectangle {
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.bottom:parent.bottom
        height:Math.max(30,Ui.UiMetrics.text(23))
        color:"#ed211823"
        border.color:"#91637a"
        radius:4
        RowLayout {
            anchors.fill:parent
            anchors.leftMargin:12
            anchors.rightMargin:12
            spacing:12
            Text {
                objectName:"musterTotal"
                Layout.fillWidth:true
                text:"Wave "+muster.stage.wave+"  ·  Scaling ×"+(1+Math.floor(muster.stage.wave/10)*Mission.difficulty(muster.stage.difficulty).scale).toFixed(2)
                color:"#ffe0bc"
                font.family:"IBM Plex Mono"
                font.pixelSize:Ui.UiMetrics.text(muster.compact ? 12 : 15)
                elide:Text.ElideRight
            }
            Text {
                readonly property var weather:Weather.entries[muster.stage.weather] || Weather.entries.clear
                visible:weather.id !== "clear"
                text:weather.glyph+" "+weather.title
                color:weather.tint
                font.family:"Inter"
                font.pixelSize:Ui.UiMetrics.text(muster.compact ? 12 : 15)
            }
        }
    }
    Item {
        id: parade
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
                        actors:[Muster.actor(muster.overlord)]
                        portraitMode:true
                        silhouette:true
                        motion:false
                        Component.onCompleted: {
                            actors[0].depth = Mission.enemyTypes[muster.overlord].size*340
                            actors = actors.slice()
                        }
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
                anchorItem:parent; hovered:parent.containsMouse && muster.hoveredMember < 0
                enemyType:muster.overlord; discoveries:muster.discoveries
                onEntryRequested:function(chapter,id) { muster.entryRequested(chapter,id) }
            }
        }
        Loader {
            id:nativeParade
            anchors.fill:parent
            anchors.margins:6
            active:!muster.software
            sourceComponent:MusterScene3D {company:muster.company; placements:muster.placements; motion:muster.motion}
        }
        HoverHandler {
            id:paradeHover
            enabled:!!nativeParade.item
            function updateMember() {
                if (!hovered || !nativeParade.item) {
                    muster.hoveredMember=-1
                    return
                }
                const local=nativeParade.mapFromItem(parade,point.position)
                muster.hoveredMember=nativeParade.item.indexAt(local.x,local.y)
            }
            onPointChanged:updateMember()
            onHoveredChanged:updateMember()
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
                    width:Math.max(28,132*member.spec.size*parade.height/muster.cameraRadius)
                    height:Math.max(30,180*member.spec.size*parade.height/muster.cameraRadius)
                    readonly property var position:muster.placements[index] || {x:.5,y:.5}
                    x:army.width*position.x-width/2
                    y:Math.max(0,Math.min(army.height-height,army.height*position.y-height/2))
                    readonly property var spec: Mission.enemyTypes[modelData.type]
                    readonly property color tone: Lore.origins[spec.origin].color
                    Loader {
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
                            actors:[Muster.actor(member.modelData.type)]
                            Component.onCompleted: {
                                actors[0].depth = member.spec.size*340
                                actors = actors.slice()
                            }
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
                            anchorItem:parent; hovered:muster.software ? parent.containsMouse : muster.hoveredMember===member.index
                            enemyType:member.modelData.type; discoveries:muster.discoveries
                            onEntryRequested:function(chapter,id) { muster.entryRequested(chapter,id) }
                        }
                    }
                }
            }
        }
    }
}
