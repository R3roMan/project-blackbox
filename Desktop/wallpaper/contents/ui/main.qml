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
        const rect=desktop?.availableScreenRect
        if (rect?.width>0 && rect.height>0) {
            const local=rect.x>=0 && rect.y>=0 && rect.x+rect.width<=width+1 && rect.y+rect.height<=height+1
            const left=Math.max(0,rect.x-(local ? 0 : Screen.virtualX))
            const top=Math.max(0,rect.y-(local ? 0 : Screen.virtualY))
            return Qt.rect(left+6,top+6,Math.max(0,Math.min(width-left,rect.width)-12),
                Math.max(0,Math.min(height-top,rect.height)-12))
        }
        return Qt.rect(6,6,Math.max(0,width-12),Math.max(0,height-72))
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
