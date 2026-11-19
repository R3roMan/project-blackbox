import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GridLayout {
    id: mixer
    columns:2
    columnSpacing:10
    rowSpacing:2
    property var levels:({audioMaster:SoundMix.master,audioMusic:SoundMix.music,audioEffects:SoundMix.effects,
        audioAmbience:SoundMix.ambience,audioInterface:SoundMix.interfaceGain})
    signal levelRequested(string key,real value)

    Repeater {
        model:[
            {key:"audioMaster",label:"Overall"},
            {key:"audioMusic",label:"Music"},
            {key:"audioEffects",label:"Combat effects"},
            {key:"audioAmbience",label:"Ambience"},
            {key:"audioInterface",label:"Interface"}
        ]
        Label {
            required property var modelData
            Layout.row:index
            Layout.column:0
            required property int index
            font.pixelSize:UiMetrics.text(13)
            color:"#e4d3df"
            text:modelData.label
        }
    }
    Repeater {
        model:["audioMaster","audioMusic","audioEffects","audioAmbience","audioInterface"]
        RowLayout {
            required property string modelData
            required property int index
            readonly property real level:mixer.levels[modelData] ?? 1
            Layout.row:index
            Layout.column:1
            Layout.fillWidth:true
            spacing:5
            Slider {
                objectName:parent.modelData
                Layout.fillWidth:true
                from:0;to:100;stepSize:5
                value:Math.round(parent.level*100)
                wheelEnabled:true
                Accessible.name:["Overall","Music","Combat effects","Ambience","Interface"][parent.index]+" volume"
                onMoved:mixer.levelRequested(parent.modelData,value/100)
            }
            Label {
                Layout.preferredWidth:UiMetrics.text(40)
                horizontalAlignment:Text.AlignRight
                text:Math.round(parent.level*100)+"%"
                color:"#f1cbb1"
                font.family:"IBM Plex Mono"
                font.pixelSize:UiMetrics.text(12)
            }
        }
    }
}
