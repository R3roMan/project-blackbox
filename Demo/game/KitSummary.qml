import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear

ScrollView {
    id:summary
    required property var run
    required property int revision
    property bool paged:false
    property int page:0
    readonly property var relevantKits: {
        revision
        return Gear.kits.filter(kit=>Gear.kitMembers(run,kit).some(part=>part.owned))
    }
    visible:relevantKits.length>0
    onRelevantKitsChanged:page=Math.min(page,Math.max(0,relevantKits.length-1))
    implicitHeight:paged ? kitRows.implicitHeight : Math.min(Ui.UiMetrics.text(90),kitRows.implicitHeight)
    contentWidth:availableWidth
    clip:true
    ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
    ScrollBar.vertical.policy:paged ? ScrollBar.AlwaysOff : ScrollBar.AsNeeded
    Binding {target:summary.contentItem;property:"interactive";value:false;when:summary.paged}

    ColumnLayout {
        id:kitRows
        width:summary.availableWidth
        spacing:5
        Repeater {
            model:summary.paged ? summary.relevantKits.slice(summary.page,summary.page+1) : summary.relevantKits
            delegate:ColumnLayout {
                id:kitRow
                required property var modelData
                Layout.fillWidth:true
                spacing:3
                readonly property var members:{summary.revision;return Gear.kitMembers(summary.run,modelData)}
                RowLayout {
                    Layout.fillWidth:true
                    Text {
                        Layout.fillWidth:true
                        text:kitRow.modelData.title
                        color:Ui.InterfaceTheme.text
                        font.family:Ui.InterfaceTheme.heading
                        font.bold:true
                        font.pixelSize:Ui.UiMetrics.text(13)
                        wrapMode:Text.WordWrap
                    }
                    Ui.KitStatus {run:summary.run;kit:kitRow.modelData;revision:summary.revision}
                }
                Flow {
                    Layout.fillWidth:true
                    spacing:8
                    Repeater {
                        model:kitRow.members
                        Text {
                            required property var modelData
                            objectName:"kitPart-"+modelData.id
                            width:Math.min(implicitWidth,parent.width)
                            text:modelData.title
                            color:modelData.owned ? Ui.InterfaceTheme.equipped : Ui.InterfaceTheme.secondary
                            font.family:"Inter"
                            font.pixelSize:Ui.UiMetrics.text(12)
                            wrapMode:Text.WordWrap
                        }
                    }
                }
                Text {
                    Layout.fillWidth:true
                    text:kitRow.modelData.bonus
                    color:Ui.InterfaceTheme.secondary
                    font.family:"Inter"
                    font.pixelSize:Ui.UiMetrics.text(12)
                    wrapMode:Text.WordWrap
                }
            }
        }
        RowLayout {
            visible:summary.paged && summary.relevantKits.length>1
            Ui.ActionButton {text:"‹";Accessible.name:"Previous kit";enabled:summary.page>0;onClicked:summary.page--}
            Text {
                text:qsTr("Kit %1 of %2").arg(summary.page+1).arg(summary.relevantKits.length)
                color:Ui.InterfaceTheme.secondary;font.pixelSize:Ui.UiMetrics.text(11)
            }
            Ui.ActionButton {text:"›";Accessible.name:"Next kit";enabled:summary.page+1<summary.relevantKits.length;onClicked:summary.page++}
        }
    }
}
