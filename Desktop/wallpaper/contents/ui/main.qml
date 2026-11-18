import QtQuick
import org.kde.plasma.plasmoid
WallpaperItem {
    id:wallpaper
    // During Play the interactive surface needs to be above the containment's
    // desktop click area. The real panels are separate Plasma windows.
    z:runtime.item?.home && runtime.item.claimed && ["play","idle"].includes(runtime.item.mode) ? 1 : -1

    // The WallpaperItem paints behind Plasma's real panels. Use the
    // containment's available rectangle for the interactive HUD and menus.
    readonly property Item desktop: {
        let item=parent
        while (item && item.availableScreenRect === undefined)
            item=item.parent
        return item
    }
    function desktopArea() {
        if (desktop?.availableScreenRect.width>0)
            return desktop.availableScreenRect
        return Qt.rect(0,0,width,Math.max(0,height-50))
    }
    Image {anchors.fill:parent;fillMode:Image.PreserveAspectCrop;source:Qt.resolvedUrl("../../../../../project-blackbox/V0.1/kde/contents/images/shrine.png")}
    Text {anchors.centerIn:parent;visible:runtime.status===Loader.Error;color:"#ffe1bd";text:"Blackbox needs rebuilding for this Qt installation. See the Blackbox Desktop README.";wrapMode:Text.WordWrap;width:Math.min(600,parent.width-30)}
    Loader {
        id:runtime
        anchors.fill:parent
        source:Qt.resolvedUrl("../../../../../project-blackbox/runtime/Host.qml")
        onLoaded:item.useWorkArea=true
        Binding {
            target:runtime.item
            property:"workArea"
            when:runtime.status===Loader.Ready
            value:wallpaper.desktopArea()
        }
        Binding {
            target:runtime.item
            property:"editingDesktop"
            when:runtime.status===Loader.Ready
            value:wallpaper.desktop?.plasmoid?.corona?.editMode || false
        }
    }
}
