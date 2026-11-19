pragma Singleton
import QtQml

QtObject {
    property real master:1
    property real music:1
    property real effects:1
    property real ambience:1
    property real interfaceGain:1

    function gain(bus) {
        switch (bus) {
        case "music": return master * music
        case "ambience": return master * ambience
        case "interface": return master * interfaceGain
        default: return master * effects
        }
    }
}
