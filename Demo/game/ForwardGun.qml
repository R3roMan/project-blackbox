import QtQuick

Canvas {
    id:gun
    required property var design
    required property var pose
    required property point aim
    required property color accent
    required property bool twins
    required property int sequence
    required property real intensity
    property string sunlight:""
    property bool bayonet:false
    property real stab:0
    function position(side,t) {
        const recoil=(twins ? (sequence%2===Number(side<0) ? intensity : 0) : intensity)
        const jump=pose.pitch*.003+pose.shellTravel*.004+recoil*.032
        return Qt.point(width*(.5+side*(.25-t*.075)+aim.x*(.026+t*.061)),
            height*(.99-(.65+(design.length-60)*.001)*t+jump-aim.y*t*.075-stab*t*.16))
    }
    readonly property point muzzle:position(twins ? (sequence%2 ? -1 : 1) : 0,1)

    onWidthChanged:requestPaint()
    onHeightChanged:requestPaint()
    onPoseChanged:requestPaint()
    onAimChanged:requestPaint()
    onDesignChanged:requestPaint()
    onBayonetChanged:requestPaint()
    onSunlightChanged:requestPaint()
    onMuzzleChanged:if (visible) requestPaint()
    onVisibleChanged:if (visible) requestPaint()
    onPaint: {
        const c=getContext("2d")
        c.reset()
        c.clearRect(0,0,width,height)
        if (!visible || !width || !height)
            return
        const finish=sunlight ? Qt.tint(design.shell,sunlight==="sunrise" ? "#66eeab71" : "#69fd825c") : design.shell
        const scale=Math.min(width*(twins ? .42 : 1),height)
        function quad(from,to,leftWidth,rightWidth,fill) {
            c.beginPath();c.moveTo(from.x-leftWidth,from.y);c.lineTo(to.x-rightWidth,to.y)
            c.lineTo(to.x+rightWidth,to.y);c.lineTo(from.x+leftWidth,from.y);c.closePath()
            c.fillStyle=fill;c.fill()
        }
        for (const side of (twins ? [-1,1] : [0])) {
            const butt=position(side,-.16), shoulder=position(side,.43), mount=position(side,.61), tip=position(side,1)
            const receiver=scale*Math.min(.31,.115+design.width*.002), bore=scale*Math.min(.13,.032+design.bore*.005)
            const shade=c.createLinearGradient(butt.x-receiver,butt.y,mount.x+receiver,mount.y)
            shade.addColorStop(0,"#100f18");shade.addColorStop(.27,Qt.darker(finish,1.4))
            shade.addColorStop(.72,Qt.lighter(finish,1.34));shade.addColorStop(1,finish)
            quad(butt,shoulder,receiver,receiver*.65,"#1c1721")
            quad(shoulder,tip,bore*1.48,bore,Qt.darker(finish,1.46))
            quad(butt,mount,receiver*.79,bore*1.16,shade)
            quad(position(side,.15),mount,receiver*.20,bore*.52,"#443442")
            const features=design.form==="rotary" ? 6 : design.form==="rail" || design.form==="crystal" ? 5 : 3
            for (let i=0;i<features;i++) {
                const at=position(side,.49+i*.07), w=bore*(.93-i*.052)
                c.fillStyle=i===features-1 && design.form!=="pistol" ? accent : "#292233"
                c.fillRect(at.x-w,at.y,w*2,Math.max(2,scale*.017))
            }
            const notch=position(side,.46)
            c.fillStyle="#1a1520"
            c.fillRect(notch.x-bore*.5,notch.y-scale*.075,bore,scale*.09)
            c.fillStyle=accent
            c.fillRect(notch.x-bore*.19,notch.y-scale*.055,bore*.38,Math.max(2,scale*.016))
            if (bayonet) {
                c.fillStyle="#c3b6b8"
                c.beginPath()
                c.moveTo(mount.x+bore,mount.y)
                c.lineTo(tip.x+bore*1.32,tip.y-scale*.13)
                c.lineTo(tip.x+bore*1.70,tip.y-scale*.03)
                c.lineTo(mount.x+bore*1.5,mount.y)
                c.closePath();c.fill()
            }
            if (intensity>0 && (!twins || (side<0)===Boolean(sequence%2))) {
                const light=c.createRadialGradient(tip.x,tip.y,1,tip.x,tip.y,Math.max(2,scale*.14))
                light.addColorStop(0,"#ffffdb");light.addColorStop(.43,accent);light.addColorStop(1,"transparent")
                c.fillStyle=light;c.globalAlpha=intensity;c.fillRect(tip.x-scale*.16,tip.y-scale*.16,scale*.32,scale*.32);c.globalAlpha=1
            }
        }
    }
}
