import QtQuick
import QtQuick.Controls
import "Rules.js" as Rules

Rectangle {
    id: map
    required property string frontId
    required property var counts
    required property var turns
    required property bool navigable
    signal turnRequested(string direction)

    implicitWidth: 80
    implicitHeight: 80
    radius: 7
    color: "#da141a28"
    border.color: "#514b66"
    Accessible.name: "Location map"

    Repeater {
        model: [
            {id:"front", x:0, y:0}, {id:"left", x:-1, y:0}, {id:"right", x:1, y:0},
            {id:"up", x:0, y:-1}, {id:"down", x:0, y:1}
        ]
        Button {
            id: dot
            required property var modelData
            readonly property bool here: map.frontId === modelData.id
            readonly property var alert: map.counts[modelData.id]
            readonly property string route: Object.keys(map.turns).find(function(key) { return map.turns[key] === dot.modelData.id }) || ""
            objectName: "view-" + modelData.id
            x: (map.width - width) / 2 + modelData.x * 22
            y: (map.height - height) / 2 + modelData.y * 22
            width: 22
            height: 22
            padding: 0
            enabled: map.navigable && route.length > 0 && !here
            Accessible.name: Rules.front(modelData.id).title + (here ? ", current view" : "")
            onClicked: map.turnRequested(route)
            ToolTip.visible: hovered
            ToolTip.text: Accessible.name
            background: Item {
                Rectangle {
                    anchors.centerIn: parent
                    width: dot.here ? 12 : 9
                    height: width
                    radius: width / 2
                    color: dot.here ? "#77f5dd" : dot.alert.dangerous || dot.alert.count ? "#ef687e" : "#7c8298"
                    border.color: dot.visualFocus || dot.hovered ? "#ffffff" : "#1a1724"
                }
                Rectangle {
                    visible: dot.alert.coin
                    width: 6; height: 6
                    anchors.top: parent.top
                    anchors.right: parent.right
                    radius: 3
                    color: "#f5be61"
                    border.color: "#442540"
                }
            }
        }
    }
}
