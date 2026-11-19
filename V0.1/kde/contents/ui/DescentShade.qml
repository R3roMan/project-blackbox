import QtQuick

Item {
    id: shade
    required property real progress
    property real strength:1
    opacity:Math.min(.8,strength*.68)*Math.sin(Math.PI*progress)
    visible:opacity>.001

    Rectangle {
        anchors.fill:parent
        gradient:Gradient {
            orientation:Gradient.Horizontal
            GradientStop {position:0;color:"#df080511"}
            GradientStop {position:.22;color:"#7b21152f"}
            GradientStop {position:.50;color:"#0d302341"}
            GradientStop {position:.78;color:"#7b21152f"}
            GradientStop {position:1;color:"#df080511"}
        }
    }
    Rectangle {
        anchors.fill:parent
        gradient:Gradient {
            GradientStop {position:0;color:"#87080512"}
            GradientStop {position:.38;color:"transparent"}
            GradientStop {position:.64;color:"transparent"}
            GradientStop {position:1;color:"#a30a0717"}
        }
    }
}
