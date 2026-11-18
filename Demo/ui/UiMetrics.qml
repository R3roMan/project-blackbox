pragma Singleton
import QtQml

QtObject {
    property real textScale: 1.0

    function text(base) {
        return Math.round(base * textScale)
    }
}
