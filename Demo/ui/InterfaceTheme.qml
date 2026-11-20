pragma Singleton
import QtQuick

QtObject {
    property string selection:"bloodShrine"
    signal selectionRequested(string key)
    readonly property var presets:[
        {key:"bloodShrine",title:"Blood Shrine",base:"#22121f",surface:"#2a1826",slot:"#22151f",hover:"#3c2130",line:"#976071",accent:"#efae85",blood:.79,radius:12,serif:true,shape:"arch"},
        {key:"armory",title:"Armory Grid",base:"#1d1824",surface:"#25202d",slot:"#24202b",hover:"#383042",line:"#a27e9a",accent:"#efae91",blood:.48,radius:5,serif:false,shape:"corners"},
        {key:"terminal",title:"Field Terminal",base:"#121e24",surface:"#182830",slot:"#172329",hover:"#24404a",line:"#526f7b",accent:"#92e1db",blood:.31,radius:2,serif:false,shape:"corners"},
        {key:"dossier",title:"Black Dossier",base:"#21171c",surface:"#2a2126",slot:"#271d22",hover:"#3b2c31",line:"#8b6d7c",accent:"#e1ac9c",blood:.50,radius:3,serif:true,shape:"rules"},
        {key:"lockdown",title:"Lockdown",base:"#171729",surface:"#221d33",slot:"#211d30",hover:"#342b49",line:"#786a97",accent:"#c8b3ed",blood:.43,radius:8,serif:false,shape:"scope"},
        {key:"dark",title:"Dark",base:"#151519",surface:"#202026",slot:"#1c1b22",hover:"#323039",line:"#716773",accent:"#ead5db",blood:.23,radius:7,serif:false,shape:"plain"}
    ]
    readonly property var current:style(selection)
    readonly property color weapon:"#f4bc81"
    readonly property color active:"#89e3d4"
    readonly property color passive:"#d5b7ff"
    readonly property color inventory:"#a9dcf7"
    readonly property color text:"#f8eaec"
    readonly property color secondary:"#d9bcc9"
    readonly property color equipped:"#a2efaf"
    readonly property color inactive:"#ff8995"
    readonly property string heading:current.serif ? "Noto Serif" : "Inter"

    function style(key) { return presets.find(theme=>theme.key===key) || presets[0] }
    function group(key) { return key==="weapon" ? weapon : key==="active" ? active : passive }
}
