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

var idlePhases=["daytime","sunset","night","sunrise"]

function idleLighting(elapsedSeconds, minutes) {
    const duration=Math.max(1,minutes || 10)*60
    const elapsed=Math.max(0,elapsedSeconds)
    const step=Math.floor(elapsed/duration)
    return {phase:idlePhases[step%idlePhases.length],step:step,solarTime:(elapsed%duration)/duration*240}
}

// Roll one forecast at each lighting change and share it across every room.
function idleWeather(date,elapsedSeconds,minutes) {
    const elapsed=Math.max(0,elapsedSeconds || 0)
    const origin=date.getTime()-elapsed*1000
    const seed=Math.round(origin/1000)>>>0
    const light=idleLighting(elapsed,minutes)
    const month=new Date(origin + light.step*Math.max(1,minutes || 10)*60000).getMonth()
    const cold=[11,0,1].includes(month)
    const roll=Conditions.roll(light.step,seed,0x276f821d)
    const weather=roll<.30 ? "clear" : roll<.47 ? "cloudy" : roll<.60 ? "rain"
        : roll<.66 ? "thunder" : roll<.79 ? "fog" : roll<.88 ? "windy"
        : cold ? "winter" : light.phase==="night" ? "windy" : "heatwave"
    const stage={weather:weather,extraWeather:Conditions.companionWeather(weather,light.step,seed)}
    return {phase:light.phase,solarTime:light.solarTime,weather:weather,
        cloudy:Conditions.hasWeather(weather,stage,"cloudy"),windy:Conditions.hasWeather(weather,stage,"windy"),
        swarm:Conditions.roll(light.step,seed,0x298fd269)<.16}
}
