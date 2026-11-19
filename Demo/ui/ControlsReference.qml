import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item {
    ScrollView {
        anchors.fill:parent;contentWidth:availableWidth;clip:true
        Column {
            width:parent.width
            spacing:16
        GridLayout {
            width:parent.width;columns:width>720 ? 2 : 1;columnSpacing:16;rowSpacing:12
            Repeater {
                model:[
                    {title:"LOOK & AIM",rows:[["A D / ← →","Look left / right; walk back through the shrine."],["W S / ↑ ↓","Sky and Abyss are reached from the shrine."],["Mouse edges","Cross an edge once to turn; move away to re-arm it."],["Hold Shift","Aim a gun to mark on hit for 4s. Lean in with a staff or melee weapon."]]},
                    {title:"FIRE & DEFEND",rows:[["Left mouse / hold","Fire. Hold to repeat; watch the reticle recover."],["R / right mouse","Reload, melee trick, staff spell or trident stab."],["Hold Space","Raise shield. Release to shoot. Blocking spends it."],["Perfect block","A block within 0.2 seconds credits 25% recovery."]]},
                    {title:"YOUR BUILD",rows:[["1 / 2 / wheel","Choose your first or second weapon."],["Q / E","Independent active abilities and cooldown bars."],["T / Esc","Pause and inspect your combined loadout and bag."],["Between waves","Drag items to slots; hover for effects and upgrades."]]},
                    {title:"SURVIVE",rows:[["Hold F in Abyss","Seal the pool for this wave. Progress is saved."],[". / timer setting","Show or hide elapsed wave time."],["1× corner button","Cycle 1×, 2× and 0.5× simulation speed."],["F11","Toggle full screen. Tutorial battle teaches the basics."]]}
                ]
                Rectangle {
                    required property var modelData
                    Layout.fillWidth:true;Layout.preferredHeight:260
                    color:"#ef211822";border.color:"#936957";radius:9
                    ColumnLayout {
                        anchors.fill:parent;anchors.margins:15;spacing:14
                        Text {text:modelData.title;color:"#efbf86";font.family:"serif";font.pixelSize:21;font.bold:true}
                        Repeater {
                            model:modelData.rows
                            RowLayout {
                                required property var modelData
                                Layout.fillWidth:true;spacing:12
                                Rectangle {Layout.preferredWidth:137;Layout.preferredHeight:33;radius:4;color:"#372936";border.color:"#ac8062"
                                    Text {anchors.centerIn:parent;text:modelData[0];color:"#fff0d1";font.family:"monospace";font.pixelSize:11}}
                                Text {Layout.fillWidth:true;text:modelData[1];color:"#ead9d0";wrapMode:Text.WordWrap;font.pixelSize:12}
                            }
                        }
                        Item {Layout.fillHeight:true}
                    }
                }
            }
        }
        ControllerReference {width:parent.width;height:width>670 ? 410 : 510}
        }
    }
}
