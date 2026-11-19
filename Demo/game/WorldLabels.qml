import QtQuick
import "Rules.js" as Rules

Item {
    id: labels
    required property var actors
    required property int revision
    required property Item world
    required property string frontId
    required property bool active
    required property bool turning
    required property real blindness

    Repeater {
        model: labels.actors
        Item {
            id: tag
            required property var modelData
            readonly property var enemy: Rules.byId(labels.actors, modelData.id) || modelData
            readonly property bool marked: { labels.revision; return Rules.isMarked(enemy) }
            readonly property bool fatalMark: { labels.revision; return enemy.criticalMark > 0 }
            readonly property real winding: { labels.revision; return Rules.warningProgress(enemy) }
            readonly property var point: {
                labels.revision
                if (!labels.world || !visible)
                    return Qt.point(0, 0)
                const projected = labels.world.projection(Rules.lanePosition(enemy), Rules.elevation(enemy), enemy.depth)
                return labels.world.mapToItem(labels, projected.x, projected.y)
            }
            readonly property real relativeSize: { labels.revision; return Math.min(110, Math.max(22, labels.height * 115 / enemy.depth)) }
            visible: {
                labels.revision
                return labels.active && !labels.turning && labels.blindness < .9 && enemy.front === labels.frontId
                    && enemy.warp <= 0 && enemy.hp > 0 && (marked || fatalMark || winding > 0)
            }
            x: point.x - relativeSize / 2
            y: point.y - relativeSize / 2
            width: relativeSize
            height: relativeSize
            Canvas {
                id: reticle
                anchors.fill: parent
                visible: tag.marked || tag.fatalMark || tag.winding > 0
                onWidthChanged: requestPaint()
                onVisibleChanged: if (visible) requestPaint()
                Connections {
                    target: tag
                    function onWindingChanged() { if (tag.visible) reticle.requestPaint() }
                    function onFatalMarkChanged() { if (tag.visible) reticle.requestPaint() }
                    function onMarkedChanged() { if (tag.visible) reticle.requestPaint() }
                }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)
                    if (tag.marked || tag.fatalMark) {
                        ctx.strokeStyle = tag.fatalMark ? "#ffdb7d" : "#ff496b"
                        ctx.lineWidth = tag.fatalMark ? 2.3 : 1.7
                        ctx.beginPath()
                        ctx.arc(width / 2, height / 2, width * .35, 0, Math.PI * 2)
                        for (let i = 0; i < 4; i += 1) {
                            const angle = i * Math.PI / 2
                            ctx.moveTo(width / 2 + Math.cos(angle) * width * .29, height / 2 + Math.sin(angle) * height * .29)
                            ctx.lineTo(width / 2 + Math.cos(angle) * width * .49, height / 2 + Math.sin(angle) * height * .49)
                        }
                        ctx.stroke()
                    }
                    if (tag.winding > 0) {
                        ctx.beginPath()
                        ctx.arc(width/2,height/2,width*.47,-Math.PI*.5,Math.PI*(-.5 + 2*tag.winding))
                        ctx.lineWidth = 4
                        ctx.strokeStyle = "#9a403247"
                        ctx.stroke()
                        ctx.lineWidth = 2
                        ctx.strokeStyle = tag.winding > .77 ? "#fffbca" : "#ff9b76"
                        ctx.stroke()
                    }
                }
            }
        }
    }
}
