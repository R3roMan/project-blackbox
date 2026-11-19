.pragma library
.import "Conditions.js" as Conditions

var artwork={front:"shrine-day",left:"approach",right:"lab",down:"abyss"}
var rooms={shrine:"front",media:"left",lab:"right",sky:"up",abyss:"down"}

function asset(front) {
    if (front==="up") return Qt.resolvedUrl("../../V0.1/kde/contents/images/sky.jpg")
    return artwork[front] ? Qt.resolvedUrl("../assets/landscape/"+artwork[front]+".webp") : ""
}

function labVisit() {
    return {specimen:Math.random()<.075,bloody:Math.random()<.009}
}

function cloudOffset(seconds,windy) {
    return seconds*(windy ? 12 : 2.8)
}

function skyColors(phase,weather) {
    // The zenith in the ground views and the lower edge of the overhead view
    // meet at the same elevation. Use one palette for that shared edge.
    if (phase==="bloodMoon") return ["#100919","#1d102b","#462440","#904544"]
    if (phase==="night") return ["#050c1b","#0a172c","#1b3151","#586882"]
    if (phase==="sunset") return ["#242d53","#3b5279","#94849a","#efac82"]
    if (phase==="sunrise") return ["#415d8b","#7497c1","#c8c5ca","#f7d6ae"]
    if (Conditions.isRain(weather)) return ["#273a55","#566c85","#8b9dab","#bcc5c9"]
    if (weather==="heatwave") return ["#356eae","#639dd5","#bdd2da","#ffe4a5"]
    return ["#235888","#428bc0","#86b9d8","#cbe1e9"]
}

function roomWeather(weather,front) {
    if (Conditions.validSky(weather) || weather==="meteor" && front!=="up" && front!=="down")
        return "clear"
    return weather
}

function dayPart(hour) {
    return hour<5 || hour>=21 ? "night" : hour<8 ? "sunrise" : hour<17 ? "daytime" : "sunset"
}

// A stable, local three-hour forecast shared by every idle room.
function idleWeather(date) {
    const hour=date.getHours(), block=Math.floor(hour/3)
    const seed=date.getFullYear()*372+date.getMonth()*31+date.getDate()
    const roll=Conditions.roll(block,seed,0x276f821d)
    const cold=[11,0,1].includes(date.getMonth())
    const phase=dayPart(hour)
    const weather=roll<.41 ? "clear" : roll<.63 ? "cloudy" : roll<.76 ? "rain"
        : roll<.80 ? "thunder" : roll<.88 ? "fog" : roll<.95 ? "windy"
        : cold ? "winter" : Conditions.isNight(phase) ? "clear" : "heatwave"
    const stage={weather:weather,extraWeather:Conditions.companionWeather(weather,block,seed)}
    const minute=hour*60+date.getMinutes()
    const solarTime=phase==="sunrise" ? (minute-300)*4/3 : phase==="daytime" ? (minute-480)*4/9
        : phase==="sunset" ? minute-1020 : (minute+(hour<5 ? 180 : -1260))*.5
    return {phase:phase,solarTime:solarTime,weather:weather,cloudy:Conditions.hasWeather(weather,stage,"cloudy"),
        windy:Conditions.hasWeather(weather,stage,"windy"),swarm:Conditions.roll(block,seed,0x298fd269)<.16}
}
