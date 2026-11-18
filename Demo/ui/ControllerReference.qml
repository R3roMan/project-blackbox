import QtQuick
import QtQuick.Layouts
Rectangle {
    implicitHeight:410
    radius:9;color:"#ed211822";border.color:"#936957"
    ColumnLayout {
        anchors.fill:parent;anchors.margins:18;spacing:12
        Text {text:"CONTROLLER LAYOUT · REFERENCE ONLY";font.family:"serif";font.pixelSize:21;color:"#efbf86";Layout.fillWidth:true;wrapMode:Text.WordWrap}
        Text {text:"This page illustrates a future controller mapping. Play this build with keyboard and mouse.";color:"#d9c5bd";font.pixelSize:12;wrapMode:Text.WordWrap;Layout.fillWidth:true}
        Canvas {
            Layout.preferredHeight:145;Layout.fillWidth:true
            onPaint: {
                const c=getContext("2d");c.reset();c.translate(width/2,height*.54);const scale=Math.min(1,width/410);c.scale(scale,scale)
                c.fillStyle="#403342";c.strokeStyle="#ac7d6a";c.lineWidth=3
                c.beginPath();c.moveTo(-125,-45);c.bezierCurveTo(-176,-40,-181,68,-139,64);c.lineTo(-76,31);c.lineTo(76,31);c.bezierCurveTo(176,100,176,-40,125,-45);c.closePath();c.fill();c.stroke()
                c.fillStyle="#1b1521";c.fillRect(-113,-12,44,14);c.fillRect(-98,-27,14,44)
                for(const x of [-48,48]) {c.beginPath();c.arc(x,20,20,0,6.283);c.fill();c.stroke()}
                c.font="bold 11px monospace";c.textAlign="center"
                for(const [text,x,y,tint] of [["Y",104,-29,"#e7c770"],["B",124,-8,"#ef8992"],["A",104,13,"#9dd5b1"],["X",84,-8,"#95c9ed"]]) {c.fillStyle=tint;c.beginPath();c.arc(x,y,9,0,6.283);c.fill();c.fillStyle="#241b29";c.fillText(text,x,y+4)}
                c.fillStyle="#e7bc90";c.fillText("LB / LT",-101,-57);c.fillText("RB / RT",101,-57);c.fillText("MENU",0,-4)
            }
        }
        GridLayout {
            Layout.fillWidth:true;columns:width>670 ? 2 : 1;columnSpacing:22;rowSpacing:8
            Repeater {model:["D-pad · Turn wallpapers","Right stick · Aim","RT / X · Fire / reload or staff spell","Hold LT · Aim through the scope","LB / RB · Active Q / E","Y · Switch weapon","Hold A · Seal the Abyss","Hold B · Field shield · Menu pauses"]
                Text {required property string modelData;text:modelData;Layout.fillWidth:true;color:"#ecd8cc";font.pixelSize:12;wrapMode:Text.WordWrap}}
        }
    }
}
