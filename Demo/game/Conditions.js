.pragma library

var entries = {
    daytime:{id:"daytime",title:"Daytime",glyph:"☀",tint:"#ffe4ab",description:"Every wave starts in daylight. Look left from the Shrine to see the moving sun."},
    clear:{id:"clear", title:"Clear skies",glyph:"☀",tint:"#ffcf8a",
        description:"The normal rules of each wallpaper apply."},
    sunrise:{id:"sunrise",title:"Sunrise",glyph:"◒",tint:"#ffc08f",
        description:"Peach light and drifting horizon lightning. The moving light affects the scenery, weapons and creatures."},
    sunset:{id:"sunset",title:"Sunset",glyph:"◓",tint:"#ff9876",
        description:"A copper-red sky with distant lightning. A moving warm light catches the edges of weapons and creatures."},
    night:{id:"night",title:"Night",glyph:"☾",tint:"#b8b2ff",
        description:"Enemies gain 5% health, damage, barrier strength, speed and attack cadence. You have Blindness I."},
    bloodMoon:{id:"bloodMoon",title:"Blood Moon Night",glyph:"●",tint:"#ff625e",
        description:"A rare red night. Kills pay 25% more gold. Demons deal 15% more damage, move 20% faster and attack 10% faster. You have Blindness II. One Blandromedus always joins the roster."},
    rain:{id:"rain",title:"Rain",glyph:"☂",tint:"#93c9ff",
        description:"Burn goes out. Frost fully freezes vulnerable targets. Electric damage doubles and chains through enemies across all wallpapers."},
    thunder:{id:"thunder",title:"Thunderstorm",glyph:"ϟ",tint:"#c7b8ff",
        description:"One in five rainstorms becomes a thunderstorm. Lightning targets ordinary demons. Each strike has an equal chance to kill or charge its target. Charged demons move and attack 50% faster and deal Electric damage."},
    fog:{id:"fog",title:"Fog",glyph:"≋",tint:"#c1c8cf",
        description:"Grey mist hides distant enemies. They become easier to see as they approach. Fog can linger across sunset, night and sunrise."},
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
    incursion:{id:"incursion",title:"Void incursion",glyph:"◉",tint:"#dabbfa",
        description:"Abyss creatures arrive on any wallpaper, whatever the time of day. Seal the rift from the Abyss to halt later ordinary Void spawns."}
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

function rainVariant(wave,seed) {
    return roll(wave,seed,0x490843bd)<.20 ? "thunder" : "rain"
}

function nightVariant(wave,seed) {
    return roll(wave,seed,0x760fea47)<.05 ? "bloodMoon" : "night"
}

function daypart(progress,night) {
    if (progress<.28 || progress>=.91) return "daytime"
    if (progress<.44) return "sunset"
    if (progress<.75) return night || "night"
    return "sunrise"
}

function ramp(value,low,high) {
    const step=Math.max(0,Math.min(1,(value-low)/(high-low)))
    return step*step*(3-2*step)
}

function sky(progress,night) {
    const dusk=ramp(progress,.22,.46), dawn=ramp(progress,.72,.94)
    const dark=dusk*(1-dawn)
    const warm=(ramp(progress,.22,.38)*(1-ramp(progress,.38,.53))
        + ramp(progress,.69,.82)*(1-ramp(progress,.82,.97)))
    const rise=progress>=.72
    const sun=rise ? ramp(progress,.75,.91) : 1-ramp(progress,.34,.48)
    const red=night==="bloodMoon" ? ramp(progress,.40,.50)*(1-ramp(progress,.71,.82)) : 0
    return {dark:dark,warm:warm,red:red,sun:sun,
        sunX:rise ? .27+(progress-.72)*.47 : .40+progress*.36,
        sunY:rise ? .46-ramp(progress,.75,1)*.22 : .24+ramp(progress,.02,.48)*.22,
        moon:ramp(progress,.39,.46)*(1-ramp(progress,.74,.81)),
        moonX:.54+(progress-.39)*.37,moonY:.33-Math.sin(Math.max(0,Math.min(1,(progress-.39)/.42))*Math.PI)*.064}
}

function fogVisibility(depth) {
    return .08+.92*(1-ramp(depth,270,1660))
}
