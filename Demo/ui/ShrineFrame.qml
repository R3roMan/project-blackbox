import QtQuick

Rectangle {
    id:frame
    property var style:InterfaceTheme.current
    property color tone:style.line
    property color fill:style.base
    property bool decorated:false
    property real blood:0
    color:fill
    radius:style.radius
    border.color:Qt.darker(tone,1.29)
    clip:decorated

    PanelPlating {
        anchors.fill:parent
        visible:frame.decorated
        shape:frame.style.shape
        tone:frame.tone
        blood:frame.blood*frame.style.blood
    }
}
