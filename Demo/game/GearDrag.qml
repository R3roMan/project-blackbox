import QtQuick

Item {
    id: drag
    required property string group
    required property string title
    property int fromIndex: -1
    property int bagCell: -1
    property string offerId: ""
    property bool available: true
    property bool showGrip: false
    readonly property bool dragging: ghost.Drag.active
    signal started()

    Rectangle {
        anchors.fill: parent
        visible: drag.available && drag.showGrip
        radius: 3
        color: "#524054"
        border.color: "#7f6d89"
        Text {
            anchors.centerIn: parent
            text: "⠿"
            font.pixelSize: 12
            color: "#f0deee"
        }
    }

    DragHandler {
        id: gesture
        enabled: drag.available
        target: null
        onActiveChanged: {
            if (active) {
                drag.started()
                ghost.Drag.start()
            } else if (ghost.Drag.active) {
                ghost.Drag.drop()
            }
        }
    }
    Rectangle {
        id: ghost
        readonly property point snap: drag.mapFromItem(null, gesture.centroid.scenePosition.x, gesture.centroid.scenePosition.y)
        x: snap.x - width / 2
        y: snap.y - height / 2
        visible: Drag.active
        z: 50
        width: 105
        height: 45
        radius: 6
        color: "#dc364861"
        border.color: "#c6edfc"
        Drag.source: drag
        Drag.keys: [drag.bagCell >= 0 ? "bag-" + drag.group : drag.group]
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
        Text {
            width: parent.width - 10
            anchors.centerIn: parent
            text: drag.title
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#f0f7ff"
            font.family: "Inter"
            font.pixelSize: 11
        }
    }
}
