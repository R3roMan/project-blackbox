import QtQuick
import "../game/Rules.js" as Rules
Canvas {
    id:number
    property int value:0
    readonly property string numeral:Rules.roman(value)
    implicitWidth:Math.max(24,numeral.length*18+10)
    implicitHeight:32
    Accessible.name:value+" enemies remaining"
    onValueChanged:requestPaint()
    onWidthChanged:requestPaint()
    onHeightChanged:requestPaint()
    onPaint: {
        const c=getContext("2d");c.reset();c.font="bold 25px serif";c.textAlign="center";c.fillStyle="#b62c41";c.strokeStyle="#5c1629";c.lineWidth=1
        c.strokeText(numeral,width/2,24);c.fillText(numeral,width/2,24)
        c.fillStyle="#ee8182";c.globalAlpha=.55;c.fillText(numeral,width/2-.7,23.3);c.globalAlpha=.9
        c.strokeStyle="#bd3447";c.lineWidth=1.5
        for(let i=0;i<numeral.length;i++) {const x=width/2+(i-(numeral.length-1)/2)*17+3;c.beginPath();c.moveTo(x,22);c.quadraticCurveTo(x+1,27,x-.5,28+i%3);c.stroke();c.beginPath();c.arc(x-.5,28+i%3,1.3,0,6.283);c.fill()}
    }
}
