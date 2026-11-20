import QtQuick

Item {
    id: panel
    property color tone: "#9a8ba6"
    property real blood: 0
    property string shape: InterfaceTheme.current.shape
    property bool compact: height < 110

    Rectangle {
        anchors.fill: parent
        anchors.margins: panel.compact ? 3 : 5
        color: "transparent"
        border.color: Qt.darker(panel.tone,2.8)
        radius: panel.shape==="arch" ? 11 : panel.shape==="scope" ? 8 : 2
    }
    Canvas {
        id: corners
        anchors.fill: parent
        visible:panel.shape!=="plain"
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: panel
            function onShapeChanged() { corners.requestPaint() }
            function onToneChanged() { corners.requestPaint() }
            function onCompactChanged() { corners.requestPaint() }
        }
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0,0,width,height)
            if (panel.shape==="rules" || panel.shape==="arch") {
                ctx.strokeStyle=panel.tone
                ctx.lineWidth=1
                for (const y of [7,height-7]) {
                    ctx.beginPath()
                    ctx.moveTo(width*.19,y)
                    ctx.lineTo(width*.81,y)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(width*.5-4,y)
                    ctx.lineTo(width*.5,y-3)
                    ctx.lineTo(width*.5+4,y)
                    ctx.lineTo(width*.5,y+3)
                    ctx.closePath()
                    ctx.stroke()
                }
                return
            }
            const arm = panel.compact ? 17 : 31
            const inset = panel.compact ? 4 : 7
            for (let i = 0; i < 4; ++i) {
                ctx.save()
                ctx.translate(i % 2 ? width - inset : inset, i < 2 ? inset : height - inset)
                ctx.scale(i % 2 ? -1 : 1, i < 2 ? 1 : -1)
                ctx.beginPath()
                ctx.moveTo(0, arm)
                ctx.lineTo(0, 9)
                ctx.lineTo(9, 0)
                ctx.lineTo(arm, 0)
                ctx.lineWidth = 3.5
                ctx.strokeStyle = "#d1121420"
                ctx.stroke()
                ctx.lineWidth = 1.1
                ctx.strokeStyle = panel.tone
                ctx.stroke()
                ctx.fillStyle = "#301722"
                ctx.beginPath()
                ctx.arc(9, 9, panel.shape==="scope" ? 5 : 3, 0, Math.PI * 2)
                ctx.fill()
                ctx.strokeStyle = Qt.darker(panel.tone,1.4)
                ctx.lineWidth = .8
                ctx.stroke()
                ctx.restore()
            }
        }
    }
    BloodStain {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 3
        width: Math.min(parent.width * .42, panel.compact ? 166 : 252)
        height: Math.min(width * .55, parent.height * .72)
        opacity: panel.blood
        visible: opacity > 0
        mirrorX: true
        seed: 17
    }
    BloodStain {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 3
        width: Math.min(parent.width * .39, panel.compact ? 108 : 188)
        height: Math.min(width * .46, parent.height * .46)
        opacity: panel.blood * .76
        visible: opacity > 0
        mirrorY: true
        seed: 36
    }
}
