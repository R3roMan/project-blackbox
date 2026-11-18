.pragma library

var entries = {
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
        description:"Night rules apply as Abyss creatures arrive on any wallpaper. Seal the rift from the Abyss to halt later ordinary Void spawns."}
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
    return ["night","incursion","bloodMoon"].includes(condition)
}

function nightVariant(wave,seed) {
    return roll(wave,seed,0x760fea47)<.10 ? "bloodMoon" : "night"
}

function twilight(wave,seed) {
    if (wave<2 || [5,8,12,14,18,31].includes(wave))
        return ""
    const choice=roll(wave,seed,0x74ce32ab)
    return choice<.16 ? "sunrise" : choice<.32 ? "sunset" : ""
}
