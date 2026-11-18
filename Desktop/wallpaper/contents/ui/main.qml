import QtQuick
import org.kde.plasma.plasmoid
WallpaperItem {
    id:wallpaper
    Image {anchors.fill:parent;fillMode:Image.PreserveAspectCrop;source:Qt.resolvedUrl("../../../../../project-blackbox/V0.1/kde/contents/images/shrine.png")}
    Text {anchors.centerIn:parent;visible:runtime.status===Loader.Error;color:"#ffe1bd";text:"Blackbox needs rebuilding for this Qt installation. See the Blackbox Desktop README.";wrapMode:Text.WordWrap;width:Math.min(600,parent.width-30)}
    Loader {id:runtime;anchors.fill:parent;source:Qt.resolvedUrl("../../../../../project-blackbox/runtime/Host.qml")}
}
