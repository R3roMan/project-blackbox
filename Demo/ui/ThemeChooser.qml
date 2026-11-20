import QtQuick
import QtQuick.Controls

ComboBox {
    id:selector
    objectName:"blackboxTheme"
    property string selection:InterfaceTheme.selection
    signal themeRequested(string key)
    model:InterfaceTheme.presets
    textRole:"title"
    valueRole:"key"
    currentIndex:Math.max(0,InterfaceTheme.presets.findIndex(theme=>theme.key===selection))
    readonly property var style:InterfaceTheme.style(selection)
    Accessible.name:"Blackbox interface theme"
    font.family:"Inter"
    font.pixelSize:UiMetrics.text(13)
    implicitWidth:160
    implicitHeight:38
    onActivated:themeRequested(currentValue)
    indicator:Text {
        x:selector.width-width-11
        anchors.verticalCenter:parent.verticalCenter
        text:selector.popup.visible ? "▴" : "▾"
        color:selector.style.accent
    }
    background:Rectangle {
        radius:Math.min(7,selector.style.radius)
        color:selector.style.slot
        border.color:selector.visualFocus ? selector.style.accent : selector.style.line
    }
    contentItem:Text {
        text:selector.displayText
        font:selector.font
        color:InterfaceTheme.text
        elide:Text.ElideRight
        leftPadding:10
        rightPadding:26
        verticalAlignment:Text.AlignVCenter
    }
    popup.popupType:Popup.Item
    popup.width:selector.width
    popup.background:Rectangle {
        color:selector.style.base
        border.color:selector.style.line
        radius:Math.min(7,selector.style.radius)
    }
    delegate:ItemDelegate {
        required property var modelData
        required property int index
        width:Math.max(1,selector.width-4)
        implicitHeight:36
        highlighted:selector.highlightedIndex===index
        contentItem:Text {
            text:parent.modelData.title
            color:InterfaceTheme.text
            font:selector.font
            verticalAlignment:Text.AlignVCenter
        }
        background:Rectangle {
            color:parent.highlighted ? selector.style.hover : selector.style.base
            border.color:parent.highlighted ? selector.style.line : "transparent"
            radius:Math.min(6,selector.style.radius)
        }
    }
}
