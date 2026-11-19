import QtQuick
import "Conditions.js" as Conditions
import "Scenery.js" as Scenery

Item {
    id:land
    required property string front
    property string phase:"daytime"
    property string weather:"clear"
    property real clock:0
    property real solarTime:clock
    property bool cloudy:false
    property bool windy:false
    property int detail:1
    property bool motion:true
    property bool specimen:false
    property bool bloody:false
    property bool swarm:false
    readonly property bool frozen:weather==="winter"
    readonly property bool hot:weather==="heatwave" || weather==="inferno"
    readonly property bool night:Conditions.isNight(phase)
    readonly property bool dusk:phase==="sunset"
    readonly property bool dawn:phase==="sunrise"
    readonly property var sky:Conditions.sky(phase,solarTime,front)

    // Grade the photographic foreground; the separately matted sky stays luminous.
    Rectangle {
        anchors.fill:parent
        color:land.front==="down" ? "transparent" : land.night ? (land.phase==="bloodMoon" ? "#be210a19" : "#c006152e")
            : land.dusk ? "#6649384d" : land.dawn ? "#48445470" : land.frozen ? "#363f7fa5"
            : land.hot ? "#3dc07d3c" : land.cloudy ? "#44405261" : "transparent"
    }
    LandscapeSky {
        anchors.fill:parent
        visible:land.front!=="down"
        front:land.front;phase:land.phase;weather:land.weather
        clock:land.clock;solarTime:land.solarTime;cloudy:land.cloudy;windy:land.windy;motion:land.motion
    }
    Loader {
        anchors.fill:parent
        active:land.front==="right" && land.bloody
        sourceComponent:LabBlood {}
    }
    Loader {
        anchors.fill:parent
        active:land.swarm && land.night && (land.front==="front" || land.front==="left")
        sourceComponent:Fireflies {
            lakeside:land.front==="left"
            clock:land.clock;motion:land.motion;detail:land.detail
        }
    }
    Image {
        objectName:"labSpecimen"
        visible:land.front==="right" && land.specimen
        source:visible ? "../assets/landscape/specimen.webp" : ""
        readonly property real drift:land.motion && !land.frozen ? land.clock : 0
        width:land.width*.123;height:land.height*.222
        x:land.width*(.5+.002*Math.sin(drift*.48))-width*.5
        y:land.height*(.46+.008*Math.sin(drift*.67))-height*.5
        rotation:Math.sin(drift*.39)*2
        opacity:land.frozen ? .27 : land.night ? .49 : .63
        fillMode:Image.PreserveAspectFit
        smooth:true
    }
    Image {
        anchors.fill:parent
        visible:land.front==="right" && land.frozen
        source:visible ? "../assets/landscape/lab-frost.webp" : ""
        fillMode:Image.Stretch
        opacity:land.night ? .76 : .98
        asynchronous:true
    }
    EffectCanvas {
        id:material
        anchors.fill:parent
        textureLimit:land.detail>=2 ? 1140 : 820
        frameRate:land.detail>=2 ? 15 : land.detail===1 ? 10 : 6
        readonly property int beat:land.motion ? Math.floor(land.clock*frameRate) : 0
        onBeatChanged:requestPaint()
        Connections {
            target:land
            function onWeatherChanged(){material.requestPaint()}
            function onFrontChanged(){material.requestPaint()}
            function onPhaseChanged(){material.requestPaint()}
            function onSpecimenChanged(){material.requestPaint()}
            function onDetailChanged(){material.requestPaint()}
            function onCloudyChanged(){material.requestPaint()}
        }
        function path(c,points) {
            c.beginPath();c.moveTo(points[0][0],points[0][1])
            for (let i=1;i<points.length;i++) c.lineTo(points[i][0],points[i][1])
            c.closePath()
        }
        function glow(c,x,y,r,color) {
            const g=c.createRadialGradient(x,y,0,x,y,r)
            g.addColorStop(0,color);g.addColorStop(1,"transparent")
            c.fillStyle=g;c.fillRect(x-r,y-r,r*2,r*2)
        }
        function approach(c,t) {
            const sx=land.sky.sunX*768, sy=land.sky.sunY*432
            c.save()
            path(c,[[119,279],[390,278],[452,281],[574,282],[723,285],[768,295],[768,432],
                [493,432],[477,410],[448,403],[412,405],[400,389],[374,382],[342,387],
                [311,380],[303,364],[272,362],[259,368],[231,363],[211,345],[181,340],[158,347],[144,330],[121,322]])
            c.clip()
            if (land.frozen) {
                const ice=c.createLinearGradient(0,278,0,432)
                ice.addColorStop(0,"#5386a3bd");ice.addColorStop(.54,"#b3adcce0");ice.addColorStop(1,"#cfdeecf4")
                c.fillStyle=ice;c.fillRect(0,276,768,156)
                c.lineJoin="round"
                for (let i=0;i<24;i++) {
                    const x=154+i*131%621,y=280+i*67%150,w=9+i*13%51
                    c.strokeStyle=i%3===0 ? "#728eb6cf" : "#ade8f5fc"
                    c.lineWidth=.38+(y-272)*.009
                    c.beginPath();c.moveTo(x-w,y-1);c.lineTo(x-w*.24,y+3);c.lineTo(x,y-2)
                    c.lineTo(x+w*.4,y+3);c.lineTo(x+w,y);c.stroke()
                    if (i%2===0) {c.beginPath();c.moveTo(x,y-2);c.lineTo(x+w*.15,y-8);c.lineTo(x+w*.37,y-14);c.stroke()}
                }
                c.restore()
                snowbanks(c)
                return
            }
            const rough=land.windy ? 3.15 : land.hot ? 1.7 : 1.12
            const strength=land.night ? .36 : land.cloudy ? .50 : land.hot ? .98 : .88
            const skyColor=land.phase==="bloodMoon" ? "#6bab3048" : land.night ? "#515775ba"
                : land.dusk ? "#a5f48d52" : land.dawn ? "#86ffca95" : "#5065aed6"
            const glaze=c.createLinearGradient(0,276,0,432)
            glaze.addColorStop(0,"transparent");glaze.addColorStop(.58,skyColor);glaze.addColorStop(1,"transparent")
            c.fillStyle=glaze;c.fillRect(0,276,768,156)
            const flare=land.dusk || land.dawn ? Math.max(.09,Math.min(1,(195-sy)/24)) : 1
            const count=[43,83,130,172][land.detail]
            for (let i=0;i<(land.windy ? 27 : 18);i++) {
                const y=282+i*5.8, depth=(y-270)/162, w=24+depth*71
                const x=(i*109+t*(8+depth*19)*rough)%(830+2*w)-w
                const lift=depth*(land.windy ? 6.2 : 1.8)
                c.strokeStyle=Qt.rgba(.70,.86,.91,.06+depth*(land.windy ? .35 : .18))
                c.lineWidth=.45+depth*1.32
                c.beginPath();c.moveTo(x-w,y);c.bezierCurveTo(x-w*.43,y-lift,x+w*.23,y+lift*.48,x+w,y-lift*.68);c.stroke()
            }
            if (land.hot) {
                for (let i=0;i<19;i++) {
                    const x=183+i*157%567,y=286+i*91%151,p=(i*.618+t*(.62+i%4*.11))%1
                    const size=(2+(y-280)*.034)*p
                    c.strokeStyle=Qt.rgba(.93,.89,.66,Math.sin(p*Math.PI)*.46)
                    c.lineWidth=.62;c.beginPath();c.ellipse(x-size*1.7,y-size*.42,size*3.4,size*.84);c.stroke()
                    if (p<.62) {
                        c.fillStyle=Qt.rgba(.92,.94,.89,(1-p)*.39)
                        c.beginPath();c.ellipse(x-1.4,y-p*8,2.8,2.3);c.fill()
                    }
                }
            }
            for (let i=0;i<count;i++) {
                const depth=(i*.618034)%1
                const phase=i*2.39996
                const wave=Math.sin(phase+t*(.67+depth)*rough)*.5+.5
                const y=279+depth*150+Math.sin(t*.9*rough+phase)*.65*rough
                const spread=5+depth*(land.night ? 105 : 45)
                const x=sx+Math.sin(phase*13.371)*spread+Math.sin(t*.75+phase)*4
                const shine=(.10+.64*wave*wave)*strength*flare*(.37+depth*.64)
                c.strokeStyle=land.night ? Qt.rgba(.51,.65,.87,shine) : land.dusk ? Qt.rgba(1,.61,.27,shine)
                    : land.dawn ? Qt.rgba(1,.83,.56,shine) : Qt.rgba(1,.95,.72,shine)
                c.lineWidth=.47+depth*.95
                const length=(1+wave*9)*(depth+.14)
                c.beginPath();c.moveTo(x-length,y);c.quadraticCurveTo(x,y-.48,x+length,y);c.stroke()
            }
            c.restore()
            if (land.cloudy || land.detail>=2) {
                // Moving cloud shadows cross the treeline and its reflection together.
                const drift=Scenery.cloudOffset(t,land.windy)
                c.save()
                c.scale(1,.27)
                for (let i=0;i<(land.detail>=2 ? 4 : 2);i++) {
                    const x=(i*270+drift*.76)%1080-150
                    glow(c,x,(260+i%2*53)/.27,120+i%2*50,land.cloudy ? "#49233349" : "#15263142")
                }
                c.restore()
            }
            if (land.detail>=2 && !land.night) {
                // The stone lantern and shoreline boulders cast long shadows in low sun.
                const direction=(.5-land.sky.sunX)*170
                c.fillStyle=land.cloudy ? "#1721263a" : "#38212b37"
                for (const p of [[102,332,14],[285,383,19],[378,402,27],[468,425,18]]) {
                    c.beginPath();c.moveTo(p[0]-p[2],p[1]);c.quadraticCurveTo(p[0]+direction-22,p[1]+9,p[0]+direction-p[2],p[1]+11)
                    c.quadraticCurveTo(p[0]+direction+8,p[1]+13,p[0]+p[2],p[1]);c.closePath();c.fill()
                }
            }
        }
        function snowbanks(c) {
            const banks=[[[0,310],[66,316],[121,329],[155,348],[222,350],[257,369],[305,369],[344,393],
                [400,402],[455,410],[490,432],[0,432]],
                [[0,276],[123,270],[201,274],[280,270],[394,267],[492,271],[634,273],[768,267],
                [768,282],[674,282],[535,279],[426,278],[305,276],[178,282],[0,287]],
                [[0,245],[70,249],[111,251],[158,250],[207,256],[288,257],[378,254],[427,258],[506,254],
                [585,257],[634,253],[768,259],[768,271],[636,266],[474,267],[288,265],[142,260],[0,254]]]
            for (let i=0;i<banks.length;i++) {
                c.save()
                path(c,banks[i]);c.clip()
                const snow=c.createLinearGradient(0,i===0 ? 310 : 245,0,i===0 ? 432 : 290)
                snow.addColorStop(0,land.night ? "#927692ba" : "#c0e1edfa")
                snow.addColorStop(1,land.night ? "#c19eb5d2" : "#daebf4fc")
                c.fillStyle=snow;c.fillRect(0,241,768,191)
                for(let j=0;j<112;j++) {
                    const x=j*197%768,y=246+j*131%190
                    c.fillStyle=j%4===0 ? "#43748fb0" : "#88f7fbff"
                    c.beginPath();c.ellipse(x,y,1.5+(j%5)*1.75,1.1+j%3*.46);c.fill()
                }
                c.restore()
            }
        }
        function lab(c,t) {
            const freeze=land.frozen, hot=land.hot
            const speed=freeze ? 0 : hot ? 2.9 : 1
            c.save()
            path(c,[[308,120],[339,115],[427,115],[469,121],[468,258],[309,259]])
            c.clip()
            if (!freeze) {
                const count=hot ? 51 : land.detail===0 ? 12 : 25
                for (let i=0;i<count;i++) {
                    const age=(i*.618034+t*speed*(.085+i%6*.012))%1
                    const x=313+i*47%149+Math.sin(age*6+i)*3
                    const y=258-age*134
                    const r=(.6+(i%5)*.26+age*.68)*(hot ? 1.24 : 1)
                    c.strokeStyle=Qt.rgba(.85,1,.54,.20+Math.sin(age*Math.PI)*.48)
                    c.lineWidth=.65;c.beginPath();c.arc(x,y,r,0,Math.PI*2);c.stroke()
                    c.fillStyle="#96e2ffac";c.fillRect(x-r*.6,y-r*.6,.8,.65)
                }
                if (hot) glow(c,387,249,66,"#5dcfdf37")
            } else {
                c.strokeStyle="#aaaeeaf2";c.lineWidth=.7
                for (let i=0;i<11;i++) {
                    const x=316+i*14.3, y=123+i%3*1.5, tip=y+10+i%4*5
                    c.beginPath();c.moveTo(x,y);c.lineTo(x+2,tip);c.lineTo(x+5,y+2);c.stroke()
                }
            }
            c.restore()
            if (!freeze) {
                const pipes=[[[163,2],[179,16],[197,29],[213,33]],[[234,34],[266,34],[275,39]],
                    [[494,53],[499,42],[510,34],[527,33]],[[548,33],[586,29]],
                    [[696,1],[698,42]],[[699,78],[700,101]],[[282,147],[282,176]],
                    [[491,146],[490,178]],[[246,286],[270,288]],[[511,290],[526,289]]]
                c.lineCap="round"
                for (let i=0;i<pipes.length;i++) {
                    const pipe=pipes[i]
                    const at=(t*.46*speed+i*.37)%1*(pipe.length-1), k=Math.floor(at), f=at-k
                    const u=pipe[k],v=pipe[k+1]
                    c.strokeStyle=hot ? "#b9e8fd84" : "#91c1fc86";c.lineWidth=2
                    c.beginPath();c.moveTo(u[0]+(v[0]-u[0])*f,u[1]+(v[1]-u[1])*f)
                    c.lineTo(u[0]+(v[0]-u[0])*Math.min(1,f+.18),u[1]+(v[1]-u[1])*Math.min(1,f+.18));c.stroke()
                }
            }
            if (hot) {
                glow(c,634,228,36,"#a32f221a");glow(c,641,224,10,"#a1cd672a")
                for (let i=0;i<10;i++) {
                    const age=(t*.24+i*.1)%1
                    glow(c,634+age*14+Math.sin(age*5+i)*3,223-age*62,4+age*13,Qt.rgba(.22,.22,.21,.21*(1-age)))
                }
            }
        }
        function abyss(c,t) {
            // Each column starts on the lip of a cascade in the painted rock.
            const falls=[[26,82,37,85],[103,198,41,78],[671,159,47,106],[612,271,38,38],[645,378,66,54]]
            const streams=[4,8,13,17][land.detail]
            for (const f of falls) {
                for (let i=0;i<streams;i++) {
                    const age=(i*.618034+t*(.39+i%4*.085))%1
                    const x=f[0]+(i*.381966%1)*f[2]
                    const y=f[1]+age*f[3]
                    c.strokeStyle=i%3===0 ? Qt.rgba(.49,.43,.64,.19*Math.sin(age*Math.PI)) : Qt.rgba(.008,.004,.019,.61*Math.sin(age*Math.PI))
                    c.lineWidth=i%3===0 ? .85 : 2.5
                    c.beginPath();c.moveTo(x,y);c.quadraticCurveTo(x+.6,y+3,x-.6,y+3+Math.min(10,(1-age)*f[3]));c.stroke()
                }
            }
            glow(c,512,109,9,Qt.rgba(.96,.65,.32,.08+.06*Math.sin(t*1.3)))
        }
        onPaint: {
            const c=beginPaint()
            c.clearRect(0,0,width,height)
            c.scale(width/768,height/432)
            const t=beat/frameRate
            if (land.front==="left") approach(c,t)
            else if (land.front==="right") lab(c,t)
            else if (land.front==="down") abyss(c,t)
        }
    }
}
