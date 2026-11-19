import QtQuick
import QtQuick.Controls

Button {
    id: control

    property string hintText:""
    property var hintStats:[]
    property string entryChapter:""
    property string entryId:""
    signal entryRequested(string chapter, string id)
    readonly property bool hasEntry:entryChapter.length>0 && entryId.length>0
    property bool hintEnabled:true
    property int hintDelay:400
    property bool primary: false
    property color accent: "#ffb47c"

    hoverEnabled: true
    implicitHeight: Math.max(38, UiMetrics.text(14)+19)
    leftPadding: 14
    rightPadding: 14
    topPadding: 8
    bottomPadding: 8
    font.family: "Inter"
    font.pixelSize: UiMetrics.text(14)
    font.weight: Font.DemiBold

    // A Space press can start in combat and outlast the wave that received it.
    Keys.onPressed: function(event) {
        if (control.hasEntry && (event.key === Qt.Key_Plus || event.key === Qt.Key_Equal)) {
            control.entryRequested(control.entryChapter,control.entryId)
            event.accepted = true
        } else {
            event.accepted = event.key === Qt.Key_Space && event.isAutoRepeat
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: !control.enabled ? "#8b8c95" : control.primary ? "#1c1315" : "#f8eef0"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 6
        color: !control.enabled ? "#27242d"
            : control.primary ? (control.down ? "#e69466" : control.hovered ? "#ffd2a5" : control.accent)
            : control.down ? "#3d2e38" : control.hovered ? "#362b38" : "#e41c1a24"
        border.color: control.visualFocus ? "#fff2de"
            : control.primary && control.enabled ? Qt.lighter(control.accent, 1.17)
                : control.hovered && control.enabled ? "#b387a5" : "#6d5b73"
        border.width: control.visualFocus ? 2 : 1
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 5
            height: 1
            radius: 1
            color: control.primary ? "#70fff7e8" : "#327f6e91"
            visible: control.enabled
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 4
            height: 2
            radius: 1
            color: control.primary ? "#73331e" : "#10101a"
            opacity: .73
        }
    }
    ToolTip {
        id:wideHint
        visible:!control.hasEntry && control.hovered && control.hintEnabled && control.hintText.length>0
        text:control.hintText
        delay:control.hintDelay
        timeout:12000
        width:Math.min(480,Math.max(240,control.Window.window ? control.Window.window.width-28 : 440))
        margins:8
        x: {
            const origin=control.mapToItem(null,0,0).x
            const extent=control.Window.window ? control.Window.window.width : 760
            return Math.max(8-origin,Math.min((control.width-width)/2,extent-width-origin-8))
        }
        y: {
            const origin=control.mapToItem(null,0,0).y
            const extent=control.Window.window ? control.Window.window.height : 650
            const desired=origin>height+8 ? -height-8 : control.height+8
            return Math.max(8-origin,Math.min(desired,extent-height-origin-8))
        }
        contentItem:Text {text:wideHint.text;color:"#f3e6dd";font.family:"Inter";font.pixelSize:UiMetrics.text(13);wrapMode:Text.WordWrap;lineHeight:1.2}
        background:Rectangle {color:"#fa211923";radius:7;border.color:"#ae8575";border.width:1}
    }


    Loader {
        active:control.hasEntry
        sourceComponent:FieldHint {
            anchorItem:control
            hovered:control.enabled && control.hovered && control.hintEnabled
            delay:control.hintDelay
            details:control.hintText
            comparisons:control.hintStats
            chapter:control.entryChapter
            entryId:control.entryId
            onEntryRequested:function(chapter,id) { control.entryRequested(chapter,id) }
        }
    }
}
