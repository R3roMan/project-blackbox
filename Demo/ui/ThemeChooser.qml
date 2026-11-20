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
    Accessible.name:"Blackbox interface theme"
    onActivated:themeRequested(currentValue)
}
