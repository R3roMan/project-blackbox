// Report exposure and window frames. The pet needs geometry only.
const service="org.projectblackbox.Desktop"
function notify(method,...args) {
    callDBus(service,"/Blackbox",service,method,...args)
}
const tracked=new Map()
let nextId=0
let lastReport=""
const geometrySignals=["frameGeometryChanged","fullScreenChanged","minimizedChanged","desktopsChanged","activitiesChanged"]
function reportPerches() {
    const active=workspace.activeWindow
    const windows=workspace.windowList().filter(window=>window.normalWindow && !window.minimized
        && !window.fullScreen && (window.onAllDesktops || Array.from(window.desktops || []).includes(workspace.currentDesktop))
        && (!window.activities?.length || Array.from(window.activities).includes(workspace.currentActivity)))
    if (windows.includes(active)) {
        windows.splice(windows.indexOf(active),1)
        windows.unshift(active)
    }
    const frames=windows.slice(0,24).map(window=>{
        const r=window.frameGeometry
        return [String(tracked.get(window)),Math.round(r.x),Math.round(r.y),Math.round(r.width),Math.round(r.height)]
    })
    const fullscreen=Boolean(active?.normalWindow && active.fullScreen)
    const json=JSON.stringify(frames)
    const signature=json+fullscreen
    if (signature!==lastReport) {
        lastReport=signature
        notify("AppPerches",json,fullscreen)
    }
}
function reportBlackbox() {
    const window=workspace.activeWindow
    if (!window || !window.dock) notify("Visibility",!window || Boolean(window.desktopWindow))
    reportPerches()
}
function track(window) {
    if (tracked.has(window)) return
    tracked.set(window,++nextId)
    for (const name of geometrySignals) window[name]?.connect(reportPerches)
}
for (const window of workspace.windowList()) track(window)
for (const [name,key] of [["left","Left"],["right","Right"],["up","Up"],["down","Down"]]) {
    registerShortcut("BlackboxIdle"+key,"Blackbox Idle · "+key,"Meta+Ctrl+"+key,
        ()=>notify("Command","idle-"+name))
}
workspace.windowActivated.connect(reportBlackbox)
workspace.windowAdded.connect(window=>{track(window);reportBlackbox()})
workspace.windowRemoved.connect(window=>{tracked.delete(window);reportBlackbox()})
workspace.currentDesktopChanged.connect(reportBlackbox)
workspace.currentActivityChanged.connect(reportBlackbox)
reportBlackbox()
