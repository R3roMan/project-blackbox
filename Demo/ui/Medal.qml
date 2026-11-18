import QtQuick
Canvas {
    id:medal
    required property string medalId
    property bool earned:false
    property string metric:""
    property string group:"weapon"
    property color tint:earned ? "#e4b65c" : "#716b68"
    readonly property int fingerprint:Array.from(medalId).reduce(function(a,c){return (a*31+c.charCodeAt(0))>>>0},17)
    onEarnedChanged:requestPaint()
    onWidthChanged:requestPaint()
    onHeightChanged:requestPaint()
    onPaint: {
        const c=getContext("2d");c.reset();c.translate(width/2,height/2);const r=Math.min(width,height)*.37
        c.fillStyle=earned ? "#8a2638" : "#403943"
        for (let s of [-1,1]) {c.beginPath();c.moveTo(s*r*.12,r*.4);c.lineTo(s*r*.9,r*1.30);c.lineTo(s*r*.75,r*.80);c.lineTo(s*r*.3,r*.85);c.closePath();c.fill()}
        c.fillStyle=earned ? "#34251c" : "#24222a";c.strokeStyle=tint;c.lineWidth=r*.10
        c.beginPath()
        const points=8+fingerprint%5
        for (let i=0;i<points*2;i++) {const a=i*Math.PI/points,rad=r*(i%2 ? .88 : 1);c.lineTo(Math.cos(a)*rad,Math.sin(a)*rad)}
        c.closePath();c.fill();c.stroke();c.lineWidth=1.3;c.beginPath();c.arc(0,0,r*.73,0,Math.PI*2);c.stroke()
        c.strokeStyle=tint;c.fillStyle=tint;c.lineWidth=r*.07
        const theme=/wallet|spent|shops|gold/i.test(metric) ? 6 : /pet/i.test(metric) ? 7 : /fast|quick|timed/i.test(metric) ? 5 : /shield|blocks/i.test(metric) ? 4 : /boss|hitless/i.test(metric) ? 3 : /kill/i.test(metric) ? 1 : fingerprint%6
        if (theme===0) {c.beginPath();c.moveTo(0,-r*.55);c.lineTo(r*.20,r*.25);c.lineTo(0,r*.49);c.lineTo(-r*.20,r*.25);c.closePath();c.stroke()}
        else if (theme===1) {c.beginPath();c.ellipse(-r*.39,-r*.38,r*.78,r*.60);c.stroke();for (let x of [-1,1]) {c.beginPath();c.arc(x*r*.14,-r*.1,r*.07,0,6.28);c.fill()}c.fillRect(-r*.16,r*.23,r*.32,r*.15)}
        else if (theme===2) {for (let i=0;i<3;i++){c.beginPath();c.moveTo(-r*.32+i*r*.3,-r*.40);c.lineTo(-r*.48+i*r*.3,r*.44);c.stroke()}}
        else if (theme===3) {c.beginPath();for(let i=0;i<=5;i++){const a=-Math.PI/2+i*Math.PI*.8;c.lineTo(Math.cos(a)*r*.51,Math.sin(a)*r*.51)}c.stroke()}
        else if (theme===4) {c.beginPath();c.moveTo(-r*.4,-r*.3);c.lineTo(r*.4,-r*.3);c.lineTo(r*.3,r*.25);c.lineTo(0,r*.5);c.lineTo(-r*.3,r*.25);c.closePath();c.stroke()}
        else if(theme===6) {c.beginPath();c.arc(0,0,r*.43,0,6.28);c.stroke();c.font=Math.round(r*.65)+"px serif";c.textAlign="center";c.fillText("$",0,r*.22)}
        else if(theme===7) {for(const side of [-1,1]) {c.beginPath();c.moveTo(0,r*.25);c.quadraticCurveTo(side*r*.55,-r*.50,side*r*.52,r*.05);c.quadraticCurveTo(side*r*.2,r*.10,0,r*.25);c.stroke()}}
        else {c.beginPath();c.arc(0,0,r*.45,0,6.28);c.stroke();c.beginPath();c.moveTo(0,-r*.35);c.lineTo(0,0);c.lineTo(r*.24,r*.12);c.stroke()}
        // An engraved signature gives every achievement its own twenty-rune seal.
        c.lineWidth=r*.023
        for(let i=0;i<20;i++) {
            const a=i*Math.PI/10
            const outer=(fingerprint & (1<<i)) ? .69 : .63
            c.beginPath();c.moveTo(Math.cos(a)*r*.58,Math.sin(a)*r*.58);c.lineTo(Math.cos(a)*r*outer,Math.sin(a)*r*outer);c.stroke()
        }
        const gems=1+fingerprint%5
        for(let i=0;i<gems;i++){const a=-Math.PI*.8+i*Math.PI*1.6/Math.max(1,gems-1);c.beginPath();c.arc(Math.cos(a)*r*.86,Math.sin(a)*r*.86,r*.045,0,6.28);c.fill()}
    }
}
