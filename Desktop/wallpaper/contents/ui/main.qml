import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
WallpaperItem {
    id:wallpaper
    contextualActions: [
        PlasmaCore.Action {
            text:"Play"
            icon.name:"media-playback-start"
            visible:runtime.item?.idleActionsAvailable || false
            onTriggered:Qt.callLater(runtime.item.requestQuickStart)
        },
        PlasmaCore.Action {
            text:"Room overview"
            icon.name:"view-grid"
            visible:runtime.item?.idleActionsAvailable || false
            onTriggered:Qt.callLater(()=>runtime.item?.showOverview(false))
        },
        PlasmaCore.Action {
            text:"Idle settings"
            icon.name:"preferences-desktop-wallpaper"
            visible:runtime.item?.idleActionsAvailable || false
            onTriggered:Qt.callLater(runtime.item.openIdleSettings)
        }
    ]
    // Play and modal overlays sit over desktop widgets. Idle scenery stays
    // behind the Folder View icons and other standard Plasma widgets.
    z:runtime.item?.home && runtime.item.claimed
        && (runtime.item.mode==="play" || runtime.item.idleOverlay || runtime.item.quickCount) ? 1 : -1

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
            return Qt.rect(left,top,Math.max(0,Math.min(width-left,rect.width)),
                Math.max(0,Math.min(height-top,rect.height)))
        }
        return Qt.rect(0,0,width,Math.max(0,height-52))
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
            property:"desktopInputParent"
            when:runtime.status===Loader.Ready
            value:wallpaper.desktop
        }
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
