pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game/Meta.js" as Meta

Item {
    id: records
    objectName:"expeditionRecords"
    required property var best
    required property var archived
    property var selected:best || archived[0] || null
    property bool detailsOpen:false
    readonly property bool compact:width<920
    readonly property var history:archived.filter(function(report) {return report.id!==best?.id})
    function inspect(report) {
        if (!report) return
        selected=report
        detailsOpen=true
    }
    function goBack() {
        if (compact && detailsOpen) detailsOpen=false
        else closeRequested()
    }
    signal closeRequested()

    Rectangle {anchors.fill:parent;color:"#15101a"}
    Shortcut {sequence:"Escape";onActivated:records.goBack()}
    ColumnLayout {
        anchors.centerIn:parent
        width:Math.min(parent.width-28,1170)
        height:parent.height-28
        spacing:8
        RowLayout {
            Layout.fillWidth:true
            Text {
                Layout.fillWidth:true
                text:"Expedition records"
                color:"#f3d5b7"
                font.family:"Cormorant Garamond"
                font.weight:Font.Bold
                font.pixelSize:UiMetrics.text(31)
            }
            ActionButton {text:records.compact && records.detailsOpen ? "Back to records" : "Home";onClicked:records.goBack()}
        }
        RowLayout {
            Layout.fillHeight:true
            Layout.fillWidth:true
            spacing:12
            ColumnLayout {
                visible:!records.compact || !records.detailsOpen
                Layout.fillWidth:records.compact
                Layout.minimumWidth:records.compact ? 0 : 260
                Layout.maximumWidth:records.compact ? Number.POSITIVE_INFINITY : 272
                Layout.preferredWidth:272
                Layout.fillHeight:true
                spacing:7
                RecordButton {
                    objectName:"bestExpedition"
                    Layout.fillWidth:true
                    report:records.best
                    highlight:true
                    selected:!records.compact && !!report && records.selected?.id===report?.id
                    onClicked:records.inspect(report)
                }
                Text {
                    text:"Saved attempts · "+records.history.length
                    Layout.fillWidth:true
                    color:"#cbb9c9"
                    font.family:"IBM Plex Mono"
                    font.pixelSize:UiMetrics.text(12)
                }
                ListView {
                    objectName:"archivedAttempts"
                    Layout.fillHeight:true
                    Layout.fillWidth:true
                    model:records.history
                    spacing:5
                    clip:true
                    ScrollBar.vertical:ScrollBar {}
                    delegate:RecordButton {
                        required property var modelData
                        width:ListView.view.width-8
                        report:modelData
                        selected:!records.compact && records.selected?.id===report?.id
                        onClicked:records.inspect(report)
                    }
                    Label {
                        anchors.centerIn:parent
                        width:parent.width-14
                        visible:records.history.length===0
                        text:records.best && records.archived.length ? "Your best attempt is shown above."
                            : "Save an attempt from its expedition report and it will appear here."
                        color:"#cbb7c7"
                        wrapMode:Text.WordWrap
                    }
                }
            }
            RunPostcard {
                visible:!!records.selected && (!records.compact || records.detailsOpen)
                Layout.fillWidth:true;Layout.fillHeight:true
                report:records.selected;reviewing:true;reviewExit:false
                onExitRequested:records.goBack()
            }
            Rectangle {
                visible:!records.selected && !records.compact
                Layout.fillWidth:true;Layout.fillHeight:true
                radius:8;color:"#271c2b"
                Label {anchors.centerIn:parent;text:"Your first report appears after you finish a run.";color:"#eed5c1"}
            }
        }
    }

    component RecordButton:ActionButton {
        id:entry
        required property var report
        property bool highlight:false
        property bool selected:false
        primary:selected
        implicitHeight:highlight ? 81 : 62
        enabled:!!report
        readonly property string grade:report?.grades?.overall || "—"
        readonly property string date:report ? new Date(report.date*1000).toLocaleDateString(Qt.locale(),Locale.ShortFormat) : ""
        text:(highlight ? "Personal best " : "")+grade+(report ? " · Wave "+report.wave : "")
        Accessible.description:report ? "Open expedition details" : "No graded runs"
        contentItem:RowLayout {
            spacing:10
            Text {
                Layout.preferredWidth:UiMetrics.text(45)
                horizontalAlignment:Text.AlignHCenter
                text:entry.grade
                color:entry.selected ? "#351727" : Meta.colors[Meta.familyOf(entry.grade)] || "#bca9b8"
                font.family:"Archivo Black"
                font.pixelSize:UiMetrics.text(21)
                font.bold:true
            }
            ColumnLayout {
                Layout.fillWidth:true
                spacing:1
                Text {
                    Layout.fillWidth:true
                    text:entry.highlight ? "Personal best" : "Wave "+entry.report.wave
                    color:entry.selected ? "#221622" : "#ffead3"
                    font.family:"Inter"
                    font.bold:true
                    font.pixelSize:UiMetrics.text(14)
                    elide:Text.ElideRight
                }
                Text {
                    Layout.fillWidth:true
                    text:!entry.report ? "No graded runs" : entry.highlight ? "Wave "+entry.report.wave
                        +" · "+entry.report.difficulty : entry.date+" · "+entry.report.difficulty
                    color:entry.selected ? "#402833" : "#d2bccc"
                    font.family:"IBM Plex Mono"
                    font.pixelSize:UiMetrics.text(10)
                    elide:Text.ElideRight
                }
            }
            Text {
                visible:!!entry.report
                text:"›"
                color:entry.selected ? "#402833" : "#e3af96"
                font.pixelSize:UiMetrics.text(26)
                Layout.rightMargin:4
            }
        }
    }
}
