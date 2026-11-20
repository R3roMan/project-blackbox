import QtQuick
import org.kde.kwin as KWin
import org.kde.plasma.workspace.dbus as DBus
import "../../../../../project-blackbox/runtime" as Blackbox
import "../../../../../project-blackbox/Demo/ui" as Ui

KWin.SceneEffect {
    id:effect
    visible:false
    readonly property string service:"org.projectblackbox.Desktop"
    readonly property string path:"/Blackbox"
    property var roomContext:({})
    property bool opening:false
    property int activation:0

    function call(member,args,finished) {
        const reply=DBus.SessionBus.asyncCall({service:effect.service,path:effect.path,
            iface:effect.service,member:member,arguments:args})
        if (!finished) return
        const handle=()=>{console.warn("BLACKBOX DEBUG",member,reply.isError,reply.value,typeof reply.value,reply.error?.message);finished(reply.isError ? undefined : reply.value)}
        if (reply.isFinished) handle()
        else reply.finished.connect(handle)
    }
    function toggle() {
        if (visible || opening) {
            dismiss()
            return
        }
        console.warn("BLACKBOX DEBUG toggle")
        opening=true
        const request=++activation
        call("CubeContext",[],function(raw) {
            if (request!==effect.activation) return
            effect.opening=false
            if (typeof raw!=="string") return
            const state=JSON.parse(raw)
            if (!state.available?.length) return
            effect.roomContext=state
            effect.visible=true
        })
    }
    function dismiss() {
        activation++
        opening=false
        visible=false
    }
    function reportVisibility(active) {
        if (!active) {
            call("CubeVisible",[false],null)
            return
        }
        const request=activation
        call("CubeVisible",[true],function(accepted) {
            if (request===effect.activation && effect.visible && !accepted) effect.dismiss()
        })
    }
    onVisibleChanged:reportVisibility(visible)

    DBus.DBusServiceWatcher {
        watchedService:effect.service
        onRegisteredChanged:if (!registered) effect.dismiss()
    }
    DBus.SignalWatcher {
        service:effect.service
        path:effect.path
        iface:effect.service
        function onCubeRequested() {effect.toggle()}
    }
    Timer {
        running:effect.visible
        interval:1250
        repeat:true
        onTriggered:effect.reportVisibility(true)
    }
    KWin.ShortcutHandler {
        name:"BlackboxCube"
        text:"Toggle Blackbox Cube"
        sequence:"Meta+Alt+C"
        onActivated:effect.toggle()
    }
    Instantiator {
        model:effect.configuration.BorderActivate
        delegate:KWin.ScreenEdgeHandler {
            required property int modelData
            mode:KWin.ScreenEdgeHandler.Pointer
            edge:modelData
            onActivated:effect.toggle()
        }
    }
    Instantiator {
        model:effect.configuration.TouchBorderActivate
        delegate:KWin.ScreenEdgeHandler {
            required property int modelData
            mode:KWin.ScreenEdgeHandler.Touch
            edge:modelData
            onActivated:effect.toggle()
        }
    }
    delegate:Blackbox.RoomOverview {
        currentRoom:effect.roomContext.currentRoom || "front"
        available:effect.roomContext.available || []
        pictures:effect.roomContext.pictures || ({})
        backdrop:effect.roomContext.backdrop || ""
        motion:!!effect.roomContext.motion
        Component.onCompleted:{
            Ui.InterfaceTheme.selection=effect.roomContext.theme || "bloodShrine"
            Ui.UiMetrics.textScale=effect.roomContext.textScale || 1
        }
        onCloseRequested:effect.dismiss()
        onRoomRequested:function(room) {
            effect.dismiss()
            effect.call("CubeSelect",[room],null)
        }
    }
}
