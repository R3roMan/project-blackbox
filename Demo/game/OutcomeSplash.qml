import QtQuick

Item {
    id: splash
    objectName: "outcomeSplash"
    required property bool loss
    property bool motion:true
    property string message:""
    readonly property color ink:loss ? "#abed4d" : "#f52545"
    readonly property color shadow:loss ? "#294417" : "#630c22"
    Rectangle {anchors.fill:parent;color:"#b9070810"}
    Canvas {
        id: paint
        anchors.centerIn:parent
        width:Math.min(parent.width*.82,970)
        height:Math.min(parent.height*.63,520)
        onVisibleChanged:if (visible) requestPaint()
        Connections {target:splash;function onLossChanged(){paint.requestPaint()}}
        onPaint: {
            const c=getContext("2d")
            c.reset();c.clearRect(0,0,width,height)
            c.scale(width/1000,height/525)
            c.fillStyle=splash.shadow
            c.beginPath();c.moveTo(206,277)
            for (let i=0;i<36;i++) {
                const angle=i*2*Math.PI/36,reach=.65+((i*13)%17)/38
                c.lineTo(500+Math.cos(angle)*345*reach,250+Math.sin(angle)*150*reach)
            }
            c.closePath();c.fill()
            for (let i=0;i<49;i++) {
                const a=i*2.39996, r=150+(i*37)%330, x=500+Math.cos(a)*r, y=250+Math.sin(a)*r*.44
                const size=2+(i*19)%13
                c.fillStyle=i%3===0 ? splash.ink : splash.shadow
                c.beginPath();c.ellipse(x,y,size,size*(1+i%3*.38));c.fill()
            }
            c.fillStyle=splash.ink
            c.globalAlpha=.68
            for (let i=0;i<10;i++) {
                const x=281+i*47, y=260+i%3*7, reach=50+i*61%114
                c.beginPath();c.moveTo(x-5,y)
                c.quadraticCurveTo(x+4,y+reach*.59,x+1,y+reach)
                c.quadraticCurveTo(x+15,y+reach,x+8,y+12)
                c.closePath();c.fill()
            }
        }
    }
    Text {
        anchors.centerIn:parent
        text:splash.message || (splash.loss ? "LOSE" : "WIN")
        color:splash.ink
        style:Text.Outline
        styleColor:splash.shadow
        font.family:"Archivo Black"
        font.weight:Font.Black
        font.pixelSize:Math.round(Math.min(splash.width*.19,splash.height*.30))
        font.letterSpacing:splash.width*.009
        rotation:-4
        Accessible.name:text
    }
    MouseArea {anchors.fill:parent;acceptedButtons:Qt.AllButtons;preventStealing:true}
    SequentialAnimation on opacity {
        running:splash.visible && splash.motion
        NumberAnimation {from:.45;to:1;duration:210;easing.type:Easing.OutCubic}
    }
}
