.pragma library

var entries = {
    daytime:{id:"daytime",title:"Daytime",glyph:"☀",tint:"#ffe4ab",description:"The first wave is daylight. Later waves cycle through sunset, night, sunrise and daylight again. Look left from the Shrine to see the sun."},
    clear:{id:"clear", title:"Clear skies",glyph:"☀",tint:"#ffcf8a",
        description:"The normal rules of each wallpaper apply."},
    sunrise:{id:"sunrise",title:"Sunrise",glyph:"◒",tint:"#ffc08f",
        description:"Peach light and drifting horizon lightning. The moving light affects the scenery, weapons and creatures."},
    sunset:{id:"sunset",title:"Sunset",glyph:"◓",tint:"#ff9876",
        description:"A copper-red sky with distant lightning. A moving warm light catches the edges of weapons and creatures."},
    night:{id:"night",title:"Night",glyph:"☾",tint:"#b8b2ff",
        description:"Enemies gain 5% health, damage, barrier strength, speed and attack cadence. Darkness reduces visibility around the edges."},
    bloodMoon:{id:"bloodMoon",title:"Blood Moon Night",glyph:"●",tint:"#ff625e",
        description:"About one in twenty night waves turns red. Kills pay 25% more gold. Demons deal 15% more damage, move 20% faster and attack 10% faster. You have Blindness II. One Blandromedus always joins the roster."},
    cloudy:{id:"cloudy",title:"Cloudy",glyph:"☁",tint:"#b2c6d9",
        description:"Low clouds drift slowly east and cast passing shadows. High winds carry them faster. Rain and thunderstorms always bring cloud cover."},
    heatwave:{id:"heatwave",title:"Heatwave",glyph:"♨",tint:"#ffc77b",
        description:"Heat builds under clear daytime or twilight skies. The lake glitters in the haze, laboratory fluid boils and scorched equipment gives off smoke."},
    rain:{id:"rain",title:"Rain",glyph:"☂",tint:"#93c9ff",
        description:"Burn goes out. Frost fully freezes vulnerable targets. Electric damage doubles and chains through enemies across all wallpapers."},
    thunder:{id:"thunder",title:"Thunderstorm",glyph:"ϟ",tint:"#c7b8ff",
        description:"Thunderstorms keep the effects of rain and boost Electric damage to 2.25×. Lightning kills or supercharges ordinary demons. Charged demons move and attack 50% faster and deal Electric damage."},
    fog:{id:"fog",title:"Fog",glyph:"≋",tint:"#c1c8cf",
        description:"Grey mist hides distant enemies. They become easier to see as they approach. Fog can layer over any sky phase."},
    winter:{id:"winter",title:"Winter",glyph:"❄",tint:"#c3f6ff",
        description:"Every five seconds, you and all vulnerable demons receive Frost I. It slows and may freeze at the usual Frost I odds."},
    windy:{id:"windy",title:"High winds",glyph:"≋",tint:"#bde9dc",
        description:"Player and demon attacks each have a 15% wind miss chance. Pushes and pulls are 70% stronger. Every 20 seconds a gust deals light damage and Knockback I to vulnerable foes."},
    glitch:{id:"glitch",title:"Glitch",glyph:"▧",tint:"#ff94de",
        description:"For the wave, aim and view directions reverse. Left and right mouse buttons, Q and E, and weapon keys 1 and 2 exchange actions."},
    meteor:{id:"meteor",title:"Meteor shower",glyph:"✶",tint:"#ffc9a1",
        description:"A meteor approaches in Star Sky. Destroy it at range before it detonates near you."},
    inferno:{id:"inferno",title:"Inferno",glyph:"♨",tint:"#ff9576",
        description:"Fire spreads across all wallpapers, applying Burn I to you and to vulnerable enemies."},
    incursion:{id:"incursion",title:"Abyssal Takeover",glyph:"◉",tint:"#dabbfa",
        description:"Black liquid rises on every wallpaper. Go to the Abyss and hold F to seal the rift within 60 seconds. The wave waits for the seal even if all enemies die."}
}

function roll(wave, seed, salt) {
    let key = (seed ^ Math.imul(wave,0x9e3779b1) ^ salt) >>> 0
    key = Math.imul(key ^ (key >>> 16),0x45d9f3b) >>> 0
    return ((key ^ (key >>> 16)) >>> 0) / 4294967296
}

function drifting(wave,seed,rate) {
    rate = rate ?? 1
    if (wave % 10 === 0)
        return ""
    if (wave === 31 || wave >= 23 && roll(wave,seed,0x138c4fb8) < .047*rate)
        return "glitch"
    if (wave === 14 || wave >= 13 && roll(wave,seed,0x3e3f231a) < .095*rate)
        return "windy"
    return ""
}

function frequency(difficulty) {
    return difficulty === "normal" ? .85 : difficulty === "insane" ? 1.15 : 1
}

function isNight(condition) {
    return condition === "night" || condition === "bloodMoon"
}

function isRain(weather) {
    return weather === "rain" || weather === "thunder"
}

function electricScale(weather) {return weather==="thunder" ? 2.25 : weather==="rain" ? 2 : 1}

// One additional layer is rolled per wave. Rain always carries cloud cover.
function companionWeather(primary,wave,seed) {
    if (primary==="windy" || primary==="fog" || primary==="winter")
        return roll(wave,seed,0x532974bc)<.16 ? "cloudy" : ""
    if (isRain(primary))
        return roll(wave,seed,0x596253e1)<.09 ? "windy" : ""
    return ""
}

function extraWeather(primary,stage) {
    return stage && stage.weather===primary ? stage.extraWeather || "" : ""
}

function hasWeather(primary,stage,id) {
    return primary===id || extraWeather(primary,stage)===id || id==="cloudy" && isRain(primary)
}

function weatherLabel(primary,stage) {
    const names=[(entries[primary] || entries.clear).title]
    if (isRain(primary)) names.push(entries.cloudy.title)
    const extra=extraWeather(primary,stage)
    if (entries[extra]) names.push(entries[extra].title)
    return names.join(" + ")
}

function obscurity(weather,cloudy) {
    if (weather==="fog") return 1
    if (weather==="thunder") return .64
    if (weather==="rain" || weather==="winter") return .47
    if (weather==="heatwave" || cloudy) return .27
    return 0
}

function rainVariant(wave,seed) {
    return roll(wave,seed,0x490843bd)<.20 ? "thunder" : "rain"
}

function nightVariant(wave,seed) {
    return roll(wave,seed,0x760fea47)<.05 ? "bloodMoon" : "night"
}

var wavePhases=["daytime","sunset","night","sunrise"]

function validSky(phase) {
    return wavePhases.includes(phase) || phase==="bloodMoon"
}

function waveSky(wave,seed,override) {
    if (validSky(override)) return override
    const phase=wavePhases[(Math.max(1,wave)-1)%wavePhases.length]
    return phase==="night" ? nightVariant(wave,seed) : phase
}

function ramp(value,low,high) {
    const step=Math.max(0,Math.min(1,(value-low)/(high-low)))
    return step*step*(3-2*step)
}

var abyssSeconds=60

function sky(phase,elapsed,front) {
    if (front==="down")
        return {dark:1,warm:0,red:0,sun:0,sunX:.45,sunY:.55,moon:0,moonX:.56,moonY:.32,abyss:true}
    const drift=Math.max(0,Math.min(1,elapsed/240))
    const dusk=phase==="sunset", dawn=phase==="sunrise", dark=isNight(phase)
    return {dark:dark ? 1 : dusk ? .22 : dawn ? .12 : 0,warm:dusk ? .83 : dawn ? .66 : 0,
        red:phase==="bloodMoon" ? 1 : 0,sun:dark ? 0 : 1,
        sunX:(dusk ? .65 : dawn ? .31 : .42)+drift*.12,
        sunY:(dusk ? .38 : dawn ? .405 : .20)+drift*(dusk ? .08 : -.073),
        moon:dark ? 1 : 0,moonX:.55+drift*.12,moonY:.32-drift*.041,abyss:false}
}

function fogVisibility(depth) {
    return .08+.92*(1-ramp(depth,270,1660))
}
