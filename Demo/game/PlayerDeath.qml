import QtQuick

Item {
    id: collapse
    objectName:"playerDeath"
    required property real progress
    readonly property real blood:Math.min(1,progress*6)*(1-Math.max(0,progress-.65))
    Rectangle {
        anchors.fill:parent
        color:"#a41832"
        opacity:collapse.blood*.69
    }
    Rectangle {
        anchors.fill:parent
        opacity:collapse.blood
        gradient:Gradient {
            GradientStop {position:0;color:"#eb240412"}
            GradientStop {position:.34;color:"#1e4c111a"}
            GradientStop {position:.67;color:"#294c111a"}
            GradientStop {position:1;color:"#f217030b"}
        }
    }
    Rectangle {
        anchors.fill:parent
        color:"#030106"
        opacity:Math.pow(Math.max(0,(collapse.progress-.27)/.73),1.27)
    }
    MouseArea {anchors.fill:parent;acceptedButtons:Qt.AllButtons;preventStealing:true}
}
