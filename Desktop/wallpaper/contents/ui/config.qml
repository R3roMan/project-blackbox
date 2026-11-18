import QtQuick
import QtQuick.Controls
Item {
    implicitWidth:580;implicitHeight:620
    Loader {anchors.fill:parent;source:Qt.resolvedUrl("../../../../../project-blackbox/runtime/DesktopOptions.qml")}
}
