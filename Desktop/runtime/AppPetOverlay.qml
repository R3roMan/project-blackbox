import QtQuick
import QtQuick.Window
import org.kde.layershell as LayerShell

Window {
    id:overlay
    objectName:"blackboxAppPet"
    property var targetScreen:null
    LayerShell.Window.screen:targetScreen
    LayerShell.Window.anchors:LayerShell.Window.AnchorTop | LayerShell.Window.AnchorRight |
        LayerShell.Window.AnchorBottom | LayerShell.Window.AnchorLeft
    LayerShell.Window.exclusionZone:-1
    LayerShell.Window.layer:LayerShell.Window.LayerTop
    LayerShell.Window.keyboardInteractivity:LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.activateOnShow:false
    LayerShell.Window.scope:"project-blackbox-idle-pet"
    flags:Qt.Tool | Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus
    color:"transparent"
}
