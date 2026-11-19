pragma Singleton
import QtQuick
import QtCore

Settings {
    location:String(StandardPaths.writableLocation(StandardPaths.ConfigLocation))+"/project-blackbox-demo.ini"
    category:"FieldStyle"
    property color hudColor:"#ffd3a4"
    property color petGlow:"#62f7df"
    property color aimColor:"#eec3a4"
    property string aimShape:"Weapon"
    property real aimSpeed:1
}
