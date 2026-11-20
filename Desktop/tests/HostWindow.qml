import QtQuick
import QtQuick.Controls
import "../stage/share/project-blackbox/runtime" as Runtime
import "../stage/share/project-blackbox/native" as Native
ApplicationWindow {
    id:window
    width:1000;height:700;visible:true
    property bool home:Native.Desktop.atHome
    property var state:Native.Desktop.state
    property var options:Native.Desktop.config
    function setMode(value) {Native.Desktop.setOption("mode",value)}
    function command(value) {Native.Desktop.command(value)}
    function exposed(value) {Native.Desktop.reportHome(value)}
    function sensorSettings(cpu,gpu) {Native.Desktop.setOption("cpuAmmo",cpu);Native.Desktop.setOption("gpuEffects",gpu)}
    function background(value) {Native.Desktop.setOption("wallpaper_front",value)}
    Runtime.Host {id:host;anchors.fill:parent;screenName:"qa-screen"}
    Component.onCompleted:Native.Desktop.reportHome(true)
}
