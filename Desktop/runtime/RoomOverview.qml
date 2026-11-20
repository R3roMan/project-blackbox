import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D as Studio
import "../Demo/ui" as Ui
import "../Demo/game/Scenery.js" as Scenery

FocusScope {
    id:overview
    objectName:"roomOverview"
    required property string currentRoom
    required property var pictures
    property url backdrop:""
    property bool motion:true
    property var available:["up","left","front","right","down","back"]
    property string selected:currentRoom
    property real yaw:0
    property real pitch:0
    signal closeRequested()
    signal roomRequested(string room)
    readonly property var faces:[
        {room:"front",title:"Shrine",x:0,y:0,z:90,pitch:0,yaw:0},
        {room:"left",title:"West Approach",x:-90,y:0,z:0,pitch:0,yaw:-90},
        {room:"right",title:"Droid Lab",x:90,y:0,z:0,pitch:0,yaw:90},
        {room:"up",title:"Star Sky",x:0,y:90,z:0,pitch:-90,yaw:0},
        {room:"down",title:"Abyss",x:0,y:-90,z:0,pitch:90,yaw:0},
        {room:"back",title:"Pure Code",x:0,y:0,z:-90,pitch:0,yaw:180}
    ]
    function stock(room) {
        return Scenery.asset(room) || Qt.resolvedUrl("../V0.1/kde/contents/images/sky.jpg")
    }
    readonly property var neighbors:({
        front:{left:"left",right:"right",up:"up",down:"down"},
        left:{left:"back",right:"front",up:"up",down:"down"},
        right:{left:"front",right:"back",up:"up",down:"down"},
        up:{left:"left",right:"right",up:"back",down:"front"},
        down:{left:"left",right:"right",up:"front",down:"back"},
        back:{left:"right",right:"left",up:"down",down:"up"}
    })
    function select(room) {
        if (!available.includes(room)) return
        const face=faces.find(entry=>entry.room===room)
        if (!face) return
        selected=room
        const target=-face.yaw+(face.pitch ? -22 : -19)
        yaw+=((target-yaw)%360+540)%360-180
        pitch=-face.pitch+(face.pitch ? -10 : 15)
    }
    function step(offset) {
        const valid=faces.filter(face=>available.includes(face.room))
        const index=valid.findIndex(face=>face.room===selected)
        if (valid.length) select(valid[(index+offset+valid.length)%valid.length].room)
    }
    function enter() {if (available.includes(selected)) roomRequested(selected)}
    focus:true
    Component.onCompleted:{select(currentRoom);forceActiveFocus()}
    Keys.onEscapePressed:closeRequested()
    Keys.onLeftPressed:select(neighbors[selected]?.left)
    Keys.onRightPressed:select(neighbors[selected]?.right)
    Keys.onUpPressed:select(neighbors[selected]?.up)
    Keys.onDownPressed:select(neighbors[selected]?.down)
    Keys.onReturnPressed:enter()
    Keys.onEnterPressed:enter()
    Behavior on yaw {enabled:overview.motion && !rotationDrag.active; NumberAnimation {duration:300;easing.type:Easing.OutCubic}}
    Behavior on pitch {enabled:overview.motion && !rotationDrag.active; NumberAnimation {duration:300;easing.type:Easing.OutCubic}}
    Rectangle {anchors.fill:parent;color:"#0c0912"}
    Image {
        anchors.fill:parent
        source:overview.backdrop
        sourceSize.width:1600;asynchronous:true;fillMode:Image.PreserveAspectCrop
        opacity:.73
    }
    Rectangle {
        anchors.fill:parent
        gradient:Gradient {
            GradientStop {position:0;color:"#ad0a0810"}
            GradientStop {position:.5;color:"#24191225"}
            GradientStop {position:1;color:"#eb0a0710"}
        }
    }
    MouseArea {anchors.fill:parent}
    ColumnLayout {
        anchors.fill:parent
        anchors.margins:Math.min(26,parent.width*.04)
        spacing:8
        RowLayout {
            Layout.fillWidth:true
            Text {
                Layout.fillWidth:true
                text:"Blackbox"
                color:Ui.InterfaceTheme.text
                font.family:Ui.InterfaceTheme.heading
                font.bold:true;font.pixelSize:Ui.UiMetrics.text(27)
            }
            Ui.ActionButton {text:"Close";onClicked:overview.closeRequested()}
        }
        Item {
            Layout.fillWidth:true;Layout.fillHeight:true
            Loader {
                anchors.fill:parent
                active:GraphicsInfo.api!==GraphicsInfo.Software
                sourceComponent:Studio.View3D {
                    id:cube
                    camera:eye
                    Studio.PerspectiveCamera {
                        id:eye
                        z:overview.width<600 ? 615 : 495
                        fieldOfView:40
                    }
                    Studio.Node {
                        eulerRotation:Qt.vector3d(overview.pitch,overview.yaw,0)
                        Studio.Repeater3D {
                            model:overview.faces
                            delegate:Studio.Model {
                                id:face
                                required property var modelData
                                objectName:modelData.room
                                source:"#Rectangle"
                                pickable:true
                                position:Qt.vector3d(modelData.x,modelData.y,modelData.z)
                                scale:Qt.vector3d(1.79,1.79,1)
                                eulerRotation:Qt.vector3d(modelData.pitch,modelData.yaw,0)
                                materials:Studio.PrincipledMaterial {
                                    lighting:Studio.PrincipledMaterial.NoLighting
                                    roughness:1
                                    baseColorMap:Studio.Texture {
                                        sourceItem:Rectangle {
                                            width:512;height:512
                                            color:"#21182a"
                                            Image {
                                                anchors.fill:parent
                                                source:overview.pictures[face.modelData.room] || overview.stock(face.modelData.room)
                                                sourceSize.width:640;fillMode:Image.PreserveAspectCrop
                                                clip:true;asynchronous:true
                                            }
                                            Rectangle {
                                                anchors.fill:parent;color:overview.available.includes(face.modelData.room) ? "#2813051b" : "#a01f1628"
                                                border.width:overview.selected===face.modelData.room ? 13 : 5
                                                border.color:overview.selected===face.modelData.room ? "#dcaa7b" : "#694659"
                                            }
                                            Rectangle {anchors.bottom:parent.bottom;width:parent.width;height:92;color:"#dc100b1a"}
                                            Text {
                                                anchors.bottom:parent.bottom;anchors.bottomMargin:24;anchors.horizontalCenter:parent.horizontalCenter
                                                text:face.modelData.title;color:"#fff1e2"
                                                font.family:Ui.InterfaceTheme.heading;font.bold:true;font.pixelSize:38
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    TapHandler {
                        onTapped:function(point) {
                            const room=cube.pick(point.position.x,point.position.y).objectHit?.objectName
                            if (!room || !overview.available.includes(room)) return
                            if (overview.selected===room) overview.enter()
                            else overview.select(room)
                        }
                    }
                }
            }
            DragHandler {
                id:rotationDrag
                target:null
                enabled:GraphicsInfo.api!==GraphicsInfo.Software
                property real startYaw:0
                property real startPitch:0
                onActiveChanged:if (active) {startYaw=overview.yaw;startPitch=overview.pitch}
                onActiveTranslationChanged:if (active) {
                    overview.yaw=startYaw+activeTranslation.x*.62
                    overview.pitch=Math.max(-125,Math.min(125,startPitch-activeTranslation.y*.59))
                }
            }
            WheelHandler {
                target:null
                onWheel:function(event) {overview.step(event.angleDelta.y>0 ? -1 : 1);event.accepted=true}
            }
            Image {
                anchors.centerIn:parent
                visible:GraphicsInfo.api===GraphicsInfo.Software
                width:Math.min(parent.width-22,550);height:Math.min(parent.height,410)
                source:visible ? overview.pictures[overview.selected] || overview.stock(overview.selected) : ""
                sourceSize.width:600;fillMode:Image.PreserveAspectFit
            }
        }
        Text {
            Layout.alignment:Qt.AlignHCenter
            text:GraphicsInfo.api===GraphicsInfo.Software ? "Arrow keys to turn  ·  Enter to open" : "Drag or use arrow keys to turn  ·  Enter to open"
            color:Ui.InterfaceTheme.text
            opacity:.66
            font.pixelSize:Ui.UiMetrics.text(12)
            visible:overview.height>=410
        }
        Flow {
            Layout.alignment:Qt.AlignHCenter
            Layout.preferredWidth:Math.min(740,overview.width-36)
            Layout.preferredHeight:implicitHeight
            spacing:6
            Repeater {
                model:overview.faces
                Ui.ActionButton {
                    required property var modelData
                    objectName:"roomMap-"+modelData.room
                    text:modelData.title
                    primary:overview.selected===modelData.room
                    enabled:overview.available.includes(modelData.room)
                    Accessible.description:overview.currentRoom===modelData.room ? "Current room" : ""
                    onClicked:if (primary) overview.enter();else overview.select(modelData.room)
                }
            }
        }
        Ui.ActionButton {
            Layout.alignment:Qt.AlignHCenter
            text:overview.selected===overview.currentRoom ? "Return to "+overview.faces.find(face=>face.room===overview.selected)?.title
                : "Enter "+overview.faces.find(face=>face.room===overview.selected)?.title
            primary:true
            enabled:overview.available.includes(overview.selected)
            onClicked:overview.enter()
        }
    }
}
