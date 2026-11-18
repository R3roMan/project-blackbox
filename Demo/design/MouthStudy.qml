import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import "../game" as Game
import "../game/MusterData.js" as Muster

ApplicationWindow {
    id: study
    width: 1410
    height: 651
    minimumWidth: 960
    minimumHeight: 510
    visible: true
    title: "Blackbox · Hosphoragus mouth studies"
    color: "#151018"
    property real elapsed: 0
    property bool animate: true
    property int revision: 0

    Timer {
        interval: 40
        repeat: true
        running: study.animate && study.visible
        onTriggered: {
            study.elapsed = (study.elapsed + .04) % 60
            study.revision += 1
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 10
        Text {
            text: "BELLY MOUTH STUDIES"
            color: "#ffdebe"
            font.family: "DejaVu Serif"
            font.bold: true
            font.pixelSize: 38
        }
        Text {
            text: "Hosphoragus  ·  All three use the same body, wings, and pose."
            color: "#cbb2bf"
            font.family: "Inter"
            font.pixelSize: 17
        }
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 14
            Repeater {
                model: [
                    {title:"A   Round gullet", detail:"Round mouth, spaced teeth, single tongue."},
                    {title:"B   Ribbed iris", detail:"Tall mouth, raised ribs, denser teeth."},
                    {title:"C   Split jaw", detail:"Wide mouth, layered lips, forked tongue."}
                ]
                Rectangle {
                    id: card
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    color: "#211520"
                    border.color: "#694657"
                    radius: 8
                    property var specimen: Muster.actor("hosphoragus")
                    Connections {
                        target: study
                        function onRevisionChanged() { card.specimen.age = study.elapsed }
                    }
                    View3D {
                        id: stage
                        anchors { fill: parent; topMargin: 10; bottomMargin: 63 }
                        environment: SceneEnvironment {
                            backgroundMode: SceneEnvironment.Transparent
                            antialiasingMode: SceneEnvironment.MSAA
                            antialiasingQuality: SceneEnvironment.High
                        }
                        camera: labEye
                        OrthographicCamera {
                            id: labEye
                            z: 740
                            y: 25
                            horizontalMagnification: Math.min(stage.height/345,stage.width/530)
                            verticalMagnification: horizontalMagnification
                        }
                        DirectionalLight { eulerRotation: Qt.vector3d(-25,-23,0); brightness:2.05; color:"#fff2da"; ambientColor:"#615765" }
                        DirectionalLight { eulerRotation: Qt.vector3d(28,155,0); brightness:1.72; color:"#9b9aff" }
                        Game.Threat3D {
                            enemy: card.specimen
                            revision: study.revision
                            bellyStyle: card.index
                            preview: true
                        }
                    }
                    Column {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: 15 }
                        spacing: 5
                        Text { text: card.modelData.title; font.bold:true; font.family:"DejaVu Serif"; font.pixelSize:22; color:"#ffe0c2" }
                        Text { text: card.modelData.detail; font.family:"Inter"; font.pixelSize:15; color:"#d0b5c4" }
                    }
                }
            }
        }
        Button { text: study.animate ? "Pause animation" : "Play animation"; onClicked: study.animate = !study.animate }
    }
}
