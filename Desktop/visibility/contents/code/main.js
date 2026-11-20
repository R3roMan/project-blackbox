// Report exposure and the active window's outer rectangle for Idle flight.
const service="org.projectblackbox.Desktop"
function notify(method,...args) {
    callDBus(service,"/Blackbox",service,method,...args)
}
let followed=null
function reportPerch() {
    if (!followed || !followed.normalWindow || followed.fullScreen || followed.minimized) {
        notify("AppPerch",0,0,0,0)
        return
    }
    const frame=followed.frameGeometry
    notify("AppPerch",Math.round(frame.x),Math.round(frame.y),Math.round(frame.width),Math.round(frame.height))
}
function reportBlackbox() {
    const window=workspace.activeWindow
    if (window && window.dock) return
    if (followed!==window) {
        if (followed) {
            followed.frameGeometryChanged.disconnect(reportPerch)
            followed.fullScreenChanged.disconnect(reportPerch)
        }
        followed=window
        if (followed) {
            followed.frameGeometryChanged.connect(reportPerch)
            followed.fullScreenChanged.connect(reportPerch)
        }
    }
    notify("Visibility",!window || Boolean(window.desktopWindow))
    reportPerch()
}
for (const [name,key] of [["left","Left"],["right","Right"],["up","Up"],["down","Down"]]) {
    registerShortcut("BlackboxIdle"+key,"Blackbox Idle · "+key,"Meta+Ctrl+"+key,
        ()=>notify("Command","idle-"+name))
}
workspace.windowActivated.connect(reportBlackbox)
workspace.windowAdded.connect(reportBlackbox)
workspace.windowRemoved.connect(window=>{
    if (window===followed) followed=null
    reportBlackbox()
})
workspace.currentDesktopChanged.connect(reportBlackbox)
workspace.currentActivityChanged.connect(reportBlackbox)
reportBlackbox()
